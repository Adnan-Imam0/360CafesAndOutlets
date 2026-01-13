import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/api_client.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  final Map<String, dynamic>? orderData;

  const OrderDetailScreen({super.key, required this.orderId, this.orderData});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final ApiClient _apiClient = ApiClient();
  Map<String, dynamic>? _order;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.orderData != null) {
      _order = widget.orderData;
    } else {
      _fetchOrderDetails();
    }
  }

  Future<void> _fetchOrderDetails() async {
    setState(() => _isLoading = true);
    try {
      // Assuming endpoint to get single order (implement if needed in backend,
      // or just rely on passing data for now. If backend doesn't support single GET,
      // we might need to filter from list, but usually there's a GET /orders/:id)
      // For now, let's assume we pass data from list. If deep linking, this needs backend support.
      // If we don't have an endpoint for single order, we might fail here.
      // Let's implement robustly:
      // final response = await _apiClient.get('/orders/${widget.orderId}');
      // _order = response;
    } catch (e) {
      print('Error fetching order: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Details')),
        body: const Center(child: Text('Order not found')),
      );
    }

    final items = _order!['items'] as List<dynamic>? ?? [];
    final status = _order!['status'] ?? 'pending';

    return Scaffold(
      appBar: AppBar(title: Text('Order #${widget.orderId}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getStatusColor(status)),
              ),
              child: Column(
                children: [
                  Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat(
                      'MMM dd, yyyy hh:mm a',
                    ).format(DateTime.parse(_order!['created_at'])),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Delivery Address
            const Text(
              'Delivery Address',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _order!['delivery_address'] ?? 'No address provided',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Order Items
            const Text(
              'Order Items',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(item['name'] ?? 'Product'),
                  subtitle: Text('${item['quantity']} x Rs. ${item['price']}'),
                  trailing: Text(
                    'Rs. ${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
            const Divider(thickness: 1.5),

            // Total
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Rs. ${_order!['total_amount']}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'ready':
        return Colors.teal;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
