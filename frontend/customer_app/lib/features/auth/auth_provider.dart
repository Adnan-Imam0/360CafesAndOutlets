import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/api_client.dart';
import '../../core/socket_service.dart';
import '../../core/services/notification_service.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final ApiClient _apiClient = ApiClient();
  final SocketService _socketService = SocketService();

  User? _user;
  Map<String, dynamic>? _customerProfile;
  bool _isLoading = false;

  User? get user => _user;
  Map<String, dynamic>? get customerProfile => _customerProfile;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        _fetchCustomerProfile(user.uid);
        // Initialize Notifications (Request permission & save token)
        NotificationService().initialize(user.uid);
      } else {
        _customerProfile = null;
      }
      notifyListeners();
    });
  }

  // ... (signInWithGoogle implementation is fine as is, it calls _ensureCustomerRegistered)

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Trigger Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return; // User canceled
      }

      // 2. Obtain auth details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);

      // 5. Sync with Backend
      if (userCredential.user != null) {
        await _ensureCustomerRegistered(userCredential.user!);
      }
    } catch (e) {
      print('Google Sign In Error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _ensureCustomerRegistered(User user) async {
    try {
      // Check if customer exists in Postgres
      try {
        final profile = await _apiClient.get(
          '/users/customer/firebase/${user.uid}',
        );
        _customerProfile = profile;
        _initSocket();
      } catch (e) {
        // Customer not found, auto-register them using Google data
        final newCustomer = {
          'firebase_uid': user.uid,
          // Use dummy numeric phone because Google doesn't always provide one
          'phone_number': user.phoneNumber ?? '0${user.uid.substring(0, 10)}',
          'display_name': user.displayName ?? 'Google User',
          'email': user.email,
        };
        final profile = await _apiClient.post('/users/customer', newCustomer);
        _customerProfile = profile;
        _initSocket();
      }
    } catch (e) {
      print('Error syncing customer profile: $e');
    }
  }

  Future<void> _fetchCustomerProfile(String uid) async {
    try {
      final profile = await _apiClient.get('/users/customer/firebase/$uid');
      _customerProfile = profile;
      _initSocket();
      notifyListeners();
    } catch (e) {
      print('Fetch profile error or User not registered yet.');
    }
  }

  Future<void> registerCustomer(String name, {String? phoneNumber}) async {
    if (_user == null) {
      throw Exception('No user signed in');
    }
    _isLoading = true;
    notifyListeners();
    try {
      // Customer not found, auto-register them using Google data
      final newCustomer = {
        'firebase_uid': _user!.uid,
        'phone_number':
            phoneNumber ??
            _user!.phoneNumber ??
            '0${_user!.uid.substring(0, 10)}',
        'display_name': name.isNotEmpty
            ? name
            : (_user!.displayName ?? 'Google User'),
        'email': _user!.email,
      };
      final profile = await _apiClient.post('/users/customer', newCustomer);
      _customerProfile = profile;
      _initSocket();
      // Retry FCM Token save
      NotificationService().initialize(_user!.uid);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _initSocket() {
    if (_customerProfile != null) {
      final customerId = _customerProfile!['customer_id'];
      _socketService.joinRoom('user_$customerId');
    }
  }

  bool get isProfileComplete {
    if (_customerProfile == null) return false;
    final phone = _customerProfile!['phone_number'] as String?;
    if (phone == null) return false;

    // Heuristic: If it contains letters (from UID substring?) -> UID is usually alphanumeric.
    final hasLetters = phone.contains(RegExp(r'[a-zA-Z]'));
    if (hasLetters) return false;

    return true;
  }

  Future<void> updatePhoneNumber(String phone) async {
    // If profile is null (backend sync failed), try to REGISTER (Create) instead of Update
    if (_customerProfile == null) {
      if (_user != null) {
        await registerCustomer(
          _user!.displayName ?? 'Customer',
          phoneNumber: phone,
        );
        return;
      }
      throw Exception('No profile loaded and no user signed in');
    }

    _isLoading = true;
    notifyListeners();

    try {
      final customerId = _customerProfile!['customer_id'];
      final response = await _apiClient.put('/users/customer/$customerId', {
        'phone_number': phone,
      });
      _customerProfile = response;
      // Retry FCM Token save
      NotificationService().initialize(_user!.uid);
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(
    String name,
    String phone,
    XFile? imageFile,
  ) async {
    if (_customerProfile == null) return;
    try {
      final customerId = _customerProfile!['customer_id'];
      final fields = {'display_name': name, 'phone_number': phone};

      dynamic response;
      if (imageFile != null) {
        final bytes = await imageFile.readAsBytes();
        final file = http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: imageFile.name,
        );
        response = await _apiClient.putMultipart(
          '/users/customer/$customerId',
          fields,
          files: [file],
        );
      } else {
        response = await _apiClient.put('/users/customer/$customerId', fields);
      }

      if (response != null) {
        _customerProfile = response;
        // Retry FCM Token save in case it failed initially
        NotificationService().initialize(_user!.uid);
        notifyListeners();
      }
    } catch (e) {
      print('Update profile error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    _customerProfile = null;
    notifyListeners();
  }
}
