import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'order_provider.dart';
import '../shops/shop_provider.dart';

import '../../core/services/socket_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  StreamSubscription? _socketSubscription;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shop = context.read<ShopProvider>().shop;
      if (shop != null) {
        context.read<OrderProvider>().fetchOrders(shop['shop_id'] as int);
      }
    });

    // Listen to global stream instead of local .on()
    _socketSubscription = SocketService().orderStream.listen((data) {
      if (mounted) {
        final shop = context.read<ShopProvider>().shop;
        if (shop != null) {
          context.read<OrderProvider>().fetchOrders(shop['shop_id'] as int);
        }
        // Notification is handled globally by OrderNotificationWrapper
      }
    });
  }

  @override
  void dispose() {
    _socketSubscription?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final shop = context.watch<ShopProvider>().shop;

    if (shop == null) {
      return const Center(child: Text('Please set up your shop first.'));
    }

    if (orderProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final allOrders = orderProvider.orders;
    final pendingOrders = allOrders
        .where((o) => o['status'] == 'pending')
        .toList();
    final activeOrders = allOrders
        .where((o) => ['accepted', 'preparing', 'ready'].contains(o['status']))
        .toList();
    final pastOrders = allOrders
        .where(
          (o) => ['delivered', 'cancelled', 'rejected'].contains(o['status']),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Pending (${pendingOrders.length})"),
            Tab(text: "Active (${activeOrders.length})"),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          OrderList(orders: pendingOrders, showActions: true),
          OrderList(orders: activeOrders, showStatusUpdate: true),
          OrderList(orders: pastOrders),
        ],
      ),
    );
  }
}

class OrderList extends StatelessWidget {
  final List<dynamic> orders;
  final bool showActions;
  final bool showStatusUpdate;

  const OrderList({
    super.key,
    required this.orders,
    this.showActions = false,
    this.showStatusUpdate = false,
  });

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const Center(child: Text('No orders found.'));
    }

    return ListView.builder(
      itemCount: orders.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              context.push('/order-details/${order['order_id']}', extra: order);
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "#${order['order_id']} - ${order['customer_name']}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      tryParseDate(order['created_at']),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Status: ${(order['status'] as String).toUpperCase()}",
                    style: TextStyle(
                      color: _getStatusColor(order['status'] as String),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (order['items'] != null &&
                      (order['items'] as List).isNotEmpty) ...[
                    const Text(
                      "Items:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...(order['items'] as List).map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          children: [
                            Text(
                              "${item['quantity']}x ",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                item['name'] ?? 'Item',
                                style: const TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              "Rs. ${item['price']}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        order['customer_phone'] ?? 'No Phone',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          order['delivery_address'] ?? 'No Address',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  if (showActions || showStatusUpdate) ...[
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (showActions) ...[
                          OutlinedButton(
                            onPressed: () => _updateStatus(
                              context,
                              order['order_id'] as int,
                              'rejected',
                            ),
                            child: const Text('Reject'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _updateStatus(
                              context,
                              order['order_id'] as int,
                              'accepted',
                            ),
                            child: const Text('Accept'),
                          ),
                        ],
                        if (showStatusUpdate) ...[
                          DropdownButton<String>(
                            value:
                                [
                                  'accepted',
                                  'preparing',
                                  'ready',
                                  'delivered',
                                ].contains(order['status'])
                                ? order['status'] as String
                                : null,
                            hint: const Text('Update Status'),
                            items: const [
                              DropdownMenuItem(
                                value: 'accepted',
                                child: Text('Accepted'),
                              ),
                              DropdownMenuItem(
                                value: 'preparing',
                                child: Text('Preparing'),
                              ),
                              DropdownMenuItem(
                                value: 'ready',
                                child: Text('Ready for Pickup'),
                              ),
                              DropdownMenuItem(
                                value: 'delivered',
                                child: Text('Delivered'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null)
                                _updateStatus(
                                  context,
                                  order['order_id'] as int,
                                  val,
                                );
                            },
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget tryParseDate(dynamic dateStr) {
    try {
      return Text(
        DateFormat('MMM dd, hh:mm a').format(DateTime.parse(dateStr as String)),
      );
    } catch (e) {
      return const Text('Date error');
    }
  }

  void _updateStatus(BuildContext context, int orderId, String status) {
    context.read<OrderProvider>().updateStatus(orderId, status);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.black;
    }
  }
}
