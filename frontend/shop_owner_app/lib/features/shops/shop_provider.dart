import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../core/services/socket_service.dart';

class ShopProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final SocketService _socketService = SocketService();
  Map<String, dynamic>? _shop;
  Map<String, dynamic> _shopStats = {
    'totalOrders': 0,
    'revenue': 0.0,
    'pendingOrders': 0,
    'activeOrders': 0,
  };
  bool _isLoading = false;

  Map<String, dynamic>? get shop => _shop;
  Map<String, dynamic> get shopStats => _shopStats;
  bool get isLoading => _isLoading;

  Future<void> registerOwner({
    required String firebaseUid,
    required String email,
    required String username,
    required String firstName,
    required String lastName,
    required String phone,
    required String cnic,
    required String address,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _apiClient.post('/users/owner', {
        'firebase_uid': firebaseUid,
        'email': email,
        'username': username,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'cnic': cnic,
        'permanent_address': address,
      });
      // After registration, fetch the shop (which will verify the owner exists)
      await fetchMyShop(firebaseUid);
    } catch (e) {
      debugPrint('Error registering owner: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyShop(dynamic firebaseUid) async {
    if (_isLoading) return; // Prevent concurrent fetches
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Get Owner ID from Firebase UID
      final owner = await _apiClient.get('/users/owner/firebase/$firebaseUid');

      if (owner != null && owner['owner_id'] != null) {
        final ownerId = owner['owner_id'];

        // 2. Get Shop by Owner ID
        try {
          final shopData = await _apiClient.get('/shops/owner/$ownerId');
          _shop = shopData;
          _initSocket(); // Connect to socket
        } catch (e) {
          // Owner exists but no shop yet
          _shop = null;
        }
      } else {
        _shop = null;
      }
    } catch (e) {
      debugPrint('Error fetching shop: $e');
      _shop = null;
      // We swallow the error here so the UI can show the "Create Shop" state
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ... (fetchShopStats and updateShop remain unchanged)

  Future<void> fetchShopStats(int shopId) async {
    try {
      final stats = await _apiClient.get('/orders/analytics/shop/$shopId');
      if (stats != null) {
        _shopStats = stats;
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching shop stats: $e');
    }
  }

  Future<void> updateShop(
    Map<String, dynamic> data,
    XFile? profileImage,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      final shopId = _shop!['shop_id'];
      dynamic response;

      if (profileImage != null) {
        final fields = data.map(
          (key, value) => MapEntry(key, value.toString()),
        );
        final bytes = await profileImage.readAsBytes();
        final file = http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: profileImage.name,
        ); // 'image' matches upload.single('image')
        response = await _apiClient.putMultipart(
          '/shops/$shopId',
          fields,
          files: [file],
        );
      } else {
        response = await _apiClient.put('/shops/$shopId', data);
      }

      if (response != null) {
        _shop = response;
      }
    } catch (e) {
      print('Update shop failed: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleShopStatus(bool isOpen) async {
    try {
      final shopId = _shop!['shop_id'];
      final response = await _apiClient.patch('/shops/$shopId/status', {
        'is_open': isOpen,
      });

      if (response != null && _shop != null) {
        _shop!['is_open'] = response['is_open'];
        notifyListeners();
      }
    } catch (e) {
      print('Toggle shop status failed: $e');
      rethrow;
    }
  }

  Future<void> createShop(
    Map<String, dynamic> data,
    XFile? profileImage,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      // 1. Register Owner
      int postgresOwnerId;
      try {
        final ownerData = {
          'firebase_uid': data['owner_id'],
          'email': data['email'],
          'first_name': data['first_name'],
          'last_name': data['last_name'],
          'cnic': data['cnic'],
          'phone': data['personal_phone'],
          'permanent_address': data['permanent_address'],
          'username':
              data['email'].split('@')[0] +
              '${DateTime.now().millisecondsSinceEpoch}',
        };

        final ownerResponse = await _apiClient.post('/users/owner', ownerData);

        if (ownerResponse == null || ownerResponse['owner_id'] == null) {
          throw Exception('Failed to register owner');
        }
        postgresOwnerId = ownerResponse['owner_id'];
      } catch (e) {
        // Handle "User already exists" (409)
        if (e.toString().contains('409') ||
            e.toString().contains('already exists')) {
          debugPrint('Owner already exists, fetching existing ID...');
          final existingOwner = await _apiClient.get(
            '/users/owner/firebase/${data['owner_id']}',
          );
          if (existingOwner != null && existingOwner['owner_id'] != null) {
            postgresOwnerId = existingOwner['owner_id'];
          } else {
            rethrow; // Cannot recover if we can't find the existing user
          }
        } else {
          rethrow;
        }
      }

      // 2. Create Shop
      final shopDataMap = {
        'owner_id': postgresOwnerId,
        'shop_name': data['shop_name'],
        'shop_type': data['shop_type'],
        'address': data['address'],
        'phone_number': data['phone_number'],
        // profile_picture_url is handled by backend if image is passed
      };

      dynamic shopResponse;
      if (profileImage != null) {
        final fields = shopDataMap.map(
          (key, value) => MapEntry(key, value.toString()),
        );
        final bytes = await profileImage.readAsBytes();
        final file = http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: profileImage.name,
        );
        shopResponse = await _apiClient.postMultipart(
          '/shops',
          fields,
          files: [file],
        );
      } else {
        shopDataMap['profile_picture_url'] =
            data['profile_picture_url']; // If passing URL string manually
        shopResponse = await _apiClient.post('/shops', shopDataMap);
      }

      _shop = shopResponse;
      _initSocket();
    } catch (e) {
      print('Create shop failed: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _shop = null;
    _shopStats = {
      'totalOrders': 0,
      'revenue': 0.0,
      'pendingOrders': 0,
      'activeOrders': 0,
    };
    _isLoading = false;
    _socketService.disconnect();
    notifyListeners();
  }

  void _initSocket() {
    if (_shop != null) {
      final shopId = _shop!['shop_id'].toString();
      _socketService.connect(shopId);
    }
  }
}
