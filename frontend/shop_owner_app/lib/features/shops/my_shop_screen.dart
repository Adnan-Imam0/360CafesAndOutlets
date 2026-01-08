import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'shop_provider.dart';

class MyShopScreen extends StatefulWidget {
  const MyShopScreen({super.key});

  @override
  State<MyShopScreen> createState() => _MyShopScreenState();
}

class _MyShopScreenState extends State<MyShopScreen> {
  @override
  void initState() {
    super.initState();
    // Shop data is managed by DashboardScreen (ShellRoute)
    // We only need to fetch stats if shop exists and stats are empty
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shopProvider = context.read<ShopProvider>();
      if (shopProvider.shop != null) {
        shopProvider.fetchShopStats(shopProvider.shop!['shop_id']);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final shopProvider = context.watch<ShopProvider>();

    if (shopProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final shop = shopProvider.shop;
    final stats = shopProvider.shopStats;

    if (shop == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.store_outlined, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 24),
              Text(
                'No Shop Found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Get started by creating your business profile',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.go('/create-shop'),
                icon: const Icon(Icons.add_business),
                label: const Text('Create Shop'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomLeft,
              children: [
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://via.placeholder.com/800x400',
                      ), // Placeholder Cover
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -40,
                  left: 24,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(
                        shop['profile_picture_url'] as String? ??
                            'https://via.placeholder.com/150',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),

            // Shop Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shop['shop_name'] as String,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            Text(
                              shop['shop_type'] as String,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => context.push('/edit-shop'),
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          shop['address'] as String,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Text(
                      '● Active', // Mock status
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Stats Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _buildStatCard(
                    context,
                    'Orders',
                    stats['totalOrders'].toString(),
                    Icons.shopping_bag_outlined,
                    Colors.blue,
                  ),
                  const SizedBox(width: 16),
                  _buildStatCard(
                    context,
                    'Revenue',
                    'Rs. ${stats['revenue']}',
                    Icons.attach_money,
                    Colors.green,
                  ),
                  const SizedBox(width: 16),
                  _buildStatCard(
                    context,
                    'Active',
                    stats['activeOrders'].toString(),
                    Icons.restaurant,
                    Colors.orange,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Menu Section Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Quick Actions List
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                _buildActionTile(
                  context,
                  'Manage Menu',
                  'Add or edit items',
                  Icons.restaurant_menu,
                ),
                const SizedBox(height: 12),
                _buildActionTile(
                  context,
                  'Order History',
                  'View past orders',
                  Icons.history,
                ),
                const SizedBox(height: 12),
                _buildActionTile(
                  context,
                  'Settings',
                  'Shop preferences',
                  Icons.settings_outlined,
                ),
              ],
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
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
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.black87),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          if (title == 'Manage Menu') {
            context.push('/menu');
          } else if (title == 'Settings') {
            context.push('/edit-shop');
          } else if (title == 'Order History') {
            // Navigate to Orders tab (via ShellRoute usually handles this,
            // but if we are on dashboard tab, we might need to switch tabs via state.
            // For now let's just push /orders if mapped)
            context.go('/orders');
          }
        },
      ),
    );
  }
}
