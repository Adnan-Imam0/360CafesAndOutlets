import 'package:flutter/material.dart';
import '../../core/api_client.dart';

class OrderProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  List<dynamic> _orders = [];
  bool _isLoading = false;

  List<dynamic> get orders => _orders;
  bool get isLoading => _isLoading;

  Future<void> fetchOrders(int shopId) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Backend expects /shop/:shopId (mounted at root of order-service)
      final response = await _apiClient.get('/orders/shop/$shopId');
      _orders = response as List<dynamic>;
    } catch (e) {
      print('Fetch orders failed: $e');
      _orders = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getOrderById(int orderId) async {
    try {
      final response = await _apiClient.get('/orders/$orderId');
      return response as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Fetch order failed: $e');
      rethrow;
    }
  }

  Future<void> updateStatus(int orderId, String status) async {
    try {
      // Backend expects PATCH /:id/status (mounted at root)
      await _apiClient.patch('/orders/$orderId/status', {'status': status});

      // Optimistic update
      final index = _orders.indexWhere((o) => o['order_id'] == orderId);
      if (index != -1) {
        _orders[index]['status'] = status;
        notifyListeners();
      }
    } catch (e) {
      print('Update status failed: $e');
      rethrow;
    }
  }
}
