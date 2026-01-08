import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../shops/shop_provider.dart';
import '../auth/auth_provider.dart';
import '../orders/order_provider.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final shopProvider = context.read<ShopProvider>();
      final orderProvider = context.read<OrderProvider>();
      final authProvider = context.read<AuthProvider>();

      // If no shop, we can't load stats.
      if (shopProvider.shop == null) {
        await shopProvider.fetchMyShop(authProvider.user?.uid);
        if (!mounted) return;
      }

      if (shopProvider.shop != null) {
        await Future.wait([
          shopProvider.fetchShopStats(shopProvider.shop!['shop_id']),
          orderProvider.fetchOrders(shopProvider.shop!['shop_id']),
        ]);
        if (!mounted) return;
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 64, color: Colors.orange),
              const SizedBox(height: 16),
              Text(
                'Connection Failed',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'The server is taking too long to wake up. Please try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry Connection'),
              ),
            ],
          ),
        ),
      );
    }

    final shopProvider = context.watch<ShopProvider>();
    final shop = shopProvider.shop;
    final stats = shopProvider.shopStats;

    if (shop == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.storefront, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'No Shop Profile Found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/create-shop'),
                child: const Text('Create Shop'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      shop['shop_name'] ?? 'Shop Owner',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          (shop['is_open'] ?? true) ? 'OPEN' : 'CLOSED',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: (shop['is_open'] ?? true)
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        Switch(
                          value: shop['is_open'] ?? true,
                          activeColor: Colors.green,
                          onChanged: (val) {
                            context.read<ShopProvider>().toggleShopStatus(val);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(
                        shop['profile_picture_url'] ??
                            'https://via.placeholder.com/150',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            // KPI Cards - Responsive Grid
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  // Mobile: Stack 1 per row
                  return Column(
                    children: [
                      _buildKpiCard(
                        context,
                        'Total Revenue',
                        'Rs. ${stats['revenue']}',
                        Icons.attach_money,
                        Colors.green,
                      ),
                      const SizedBox(height: 16),
                      _buildKpiCard(
                        context,
                        'Active Orders',
                        '${stats['activeOrders']}',
                        Icons.shopping_bag_outlined,
                        Colors.orange,
                      ),
                      const SizedBox(height: 16),
                      _buildKpiCard(
                        context,
                        'Total Orders',
                        '${stats['totalOrders']}',
                        Icons.receipt_long,
                        Colors.blue,
                      ),
                      const SizedBox(height: 16),
                      _buildKpiCard(
                        context,
                        'Pending',
                        '${stats['pendingOrders']}',
                        Icons.timer,
                        Colors.redAccent,
                      ),
                    ],
                  );
                } else {
                  // Tablet/Desktop: 2 per row
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildKpiCard(
                              context,
                              'Total Revenue',
                              'Rs. ${stats['revenue']}',
                              Icons.attach_money,
                              Colors.green,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildKpiCard(
                              context,
                              'Active Orders',
                              '${stats['activeOrders']}',
                              Icons.shopping_bag_outlined,
                              Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildKpiCard(
                              context,
                              'Total Orders',
                              '${stats['totalOrders']}',
                              Icons.receipt_long,
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildKpiCard(
                              context,
                              'Pending',
                              '${stats['pendingOrders']}',
                              Icons.timer,
                              Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }
              },
            ),

            const SizedBox(height: 32),

            // Quick Actions
            Text(
              'Quick Actions',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildActionBtn(
                  context,
                  'Manage Menu',
                  Icons.restaurant_menu,
                  () => context.go('/menu'),
                ),
                const SizedBox(width: 16),
                _buildActionBtn(
                  context,
                  'Shop Details',
                  Icons.store,
                  () => context.go('/my-shop'),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Recent Activity Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Orders',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/orders'),
                  child: const Text('View All'),
                ),
              ],
            ),

            const SizedBox(height: 16),
            _buildRecentOrders(context),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(
    BuildContext context,
    String title,
    dynamic value, // Accept int or String
    IconData icon,
    Color color,
  ) {
    // Determine if we need Expanded (for Row) or not (for Column)
    // Actually, safest is to return a Container and let parent use Expanded if needed.
    // But since we hardcoded separate logic for Row vs Column above, we can just make this Flex-agnostic
    // or pass IsExpanded param.
    // simpler: Return Container. In the Row version, wrap call in Expanded.

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1E1E1E), // Dark text
          elevation: 0,
          side: BorderSide(color: Colors.grey.shade300),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildRecentOrders(BuildContext context) {
    final orders = context.watch<OrderProvider>().orders;
    if (orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'No recent orders',
            style: TextStyle(color: Colors.grey[400]),
          ),
        ),
      );
    }

    // specific 5
    final recent = orders.take(5).toList();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: recent.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final order = recent[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            title: Text(
              'Order #${order['order_id']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${order['customer_name']} • ${order['items']?.length ?? 0} Items',
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Rs. ${order['total_amount']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                _buildStatusBadge(order['status']),
              ],
            ),
            onTap: () => context.go('/order-details/${order['order_id']}'),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'accepted':
        color = Colors.blue;
        break;
      case 'ready':
        color = Colors.purple;
        break;
      case 'delivered':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
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
