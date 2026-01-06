import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/api_client.dart';

class ProductProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  List<dynamic> _products = [];
  bool _isLoading = false;

  List<dynamic> get products => _products;
  bool get isLoading => _isLoading;

  Future<void> fetchProducts(int shopId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.get('/products/shop/$shopId');
      _products = response as List<dynamic>;
    } catch (e) {
      print('Fetch products failed: $e');
      _products = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct(Map<String, dynamic> data, XFile? imageFile) async {
    _isLoading = true;
    notifyListeners();
    try {
      dynamic response;
      if (imageFile != null) {
        final fields = data.map(
          (key, value) => MapEntry(key, value.toString()),
        );
        final bytes = await imageFile.readAsBytes();
        final file = http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: imageFile.name,
        );
        response = await _apiClient.postMultipart(
          '/products',
          fields,
          files: [file],
        );
      } else {
        response = await _apiClient.post('/products', data);
      }
      _products.add(response);
    } catch (e) {
      print('Add product failed: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProduct(
    int id,
    Map<String, dynamic> data,
    XFile? imageFile,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      dynamic response;
      if (imageFile != null) {
        final fields = data.map(
          (key, value) => MapEntry(key, value.toString()),
        );
        final bytes = await imageFile.readAsBytes();
        final file = http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: imageFile.name,
        );
        response = await _apiClient.putMultipart(
          '/products/$id',
          fields,
          files: [file],
        );
      } else {
        response = await _apiClient.put('/products/$id', data);
      }

      final index = _products.indexWhere((p) => p['product_id'] == id);
      if (index != -1) {
        _products[index] = response;
      }
    } catch (e) {
      print('Update product failed: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _apiClient.delete('/products/$id');
      _products.removeWhere((p) => p['product_id'] == id);
    } catch (e) {
      print('Delete product failed: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
