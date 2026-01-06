import 'package:flutter/material.dart';
import '../../core/api_client.dart';

class AddressProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  List<dynamic> _addresses = [];
  bool _isLoading = false;

  List<dynamic> get addresses => _addresses;
  bool get isLoading => _isLoading;

  Future<void> fetchAddresses(int customerId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.get(
        '/users/address/customer/$customerId',
      );
      if (response != null) {
        _addresses = response as List<dynamic>;
      }
    } catch (e) {
      print('Error fetching addresses: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAddress(Map<String, dynamic> addressData) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.post('/users/address', addressData);
      if (response != null) {
        _addresses.insert(0, response); // Add to top
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
