import 'package:flutter/material.dart';
import '../../core/api_client.dart';

class CategoryProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  List<dynamic> _categories = [];
  bool _isLoading = false;

  List<dynamic> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> fetchCategories(int shopId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.get('/categories/shop/$shopId');
      _categories = response as List<dynamic>;
    } catch (e) {
      print('Fetch categories failed: $e');
      _categories = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<dynamic> createCategory(int shopId, String name) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = {'shop_id': shopId, 'name': name};
      final response = await _apiClient.post('/categories', data);
      _categories.add(response);
      return response;
    } catch (e) {
      print('Create category failed: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
