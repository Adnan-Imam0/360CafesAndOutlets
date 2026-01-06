import 'package:flutter/material.dart';
import '../../core/api_client.dart';

class ShopProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  List<dynamic> _shops = [];
  bool _isLoading = false;

  List<dynamic> get shops => _shops;
  bool get isLoading => _isLoading;

  Future<void> fetchShops() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.get('/shops');
      if (response != null && response is List) {
        _shops = response;
      }
    } catch (e) {
      print('Fetch shops failed: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
