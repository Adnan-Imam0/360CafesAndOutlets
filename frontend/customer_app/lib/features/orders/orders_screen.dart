import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/api_client.dart';
import '../auth/auth_provider.dart';
import 'package:go_router/go_router.dart';

import '../../core/socket_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiClient _apiClient = ApiClient();
  List<dynamic> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchOrders();
    _initSocketListener();
  }

  void _initSocketListener() {
    SocketService().on('order_status_updated', (data) {
      if (mounted) {
        _fetchOrders();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Order #${data['order_id']} updated: ${data['status']}',
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    SocketService().off('order_status_updated');
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    try {
      final auth = context.read<AuthProvider>();
      if (auth.customerProfile == null) return;

      final customerId = auth.customerProfile!['customer_id'];
      final response = await _apiClient.get('/orders/customer/$customerId');

      if (mounted) {
        setState(() {
          _orders = response ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Fetch orders failed: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<dynamic> get _activeOrders {
    final activeStatuses = ['pending', 'accepted', 'preparing', 'ready'];
    return _orders.where((o) => activeStatuses.contains(o['status'])).toList();
  }

  List<dynamic> get _pastOrders {
    final pastStatuses = ['delivered', 'cancelled', 'rejected'];
    return _orders.where((o) => pastStatuses.contains(o['status'])).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'History'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => context.go('/home'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList(_activeOrders),
                _buildOrderList(_pastOrders),
              ],
            ),
    );
  }

  Widget _buildOrderList(List<dynamic> orders) {
    if (orders.isEmpty) {
      return const Center(child: Text('No orders found'));
    }
    return RefreshIndicator(
      onRefresh: _fetchOrders,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order #${order['order_id']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      _buildStatusChip(order['status']),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Total: \$${order['total_amount']}'),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat(
                      'MMM dd, yyyy hh:mm a',
                    ).format(DateTime.parse(order['created_at'])),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'accepted':
        color = Colors.blue;
        break;
      case 'preparing':
        color = Colors.blue;
        break;
      case 'ready':
        color = Colors.green;
        break;
      case 'delivered':
        color = Colors.green;
        break;
      case 'cancelled':
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
