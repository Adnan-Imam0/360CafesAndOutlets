import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../auth/auth_provider.dart';
import '../shops/shop_provider.dart';

class DashboardScreen extends StatefulWidget {
  final Widget child; // For nested navigation

  const DashboardScreen({super.key, required this.child});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndFetchShop();
    });
  }

  void _checkAndFetchShop() {
    final authProvider = context.read<AuthProvider>();
    final shopProvider = context.read<ShopProvider>();

    if (authProvider.isAuthenticated && shopProvider.shop == null) {
      shopProvider.fetchMyShop(authProvider.user!.uid).then((_) {
        // If still null after fetch, redirect to create shop
        if (mounted && context.read<ShopProvider>().shop == null) {
          // Check if we are already on create-shop to avoid loop (though ShellRoute usually handles this,
          // but create-shop is INSIDE shell route in my main.dart config.
          // Wait, create-shop should probably be ACCESSIBLE.
          // Let's check main.dart: /create-shop is defined.

          final currentLocation = GoRouterState.of(context).uri.toString();
          if (currentLocation != '/create-shop' &&
              currentLocation != '/create-profile') {
            context.go('/create-shop');
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>().shop;
    final shopName = shop?['shop_name'] ?? 'My Shop';

    final sidebarColor = Colors.teal.shade900;
    final textStyle = const TextStyle(color: Colors.white);
    final iconColor = Colors.white70;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          shopName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: sidebarColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: const HelperIcon(Icons.logout, color: Colors.white),
            onPressed: () {
              context.read<ShopProvider>().clear();
              context.read<AuthProvider>().logout();
              context.go('/login');
            },
          ),
        ],
      ),
      drawer: MediaQuery.of(context).size.width > 800
          ? null // No drawer (hamburger) on desktop as we have sidebar
          : Drawer(
              backgroundColor: sidebarColor,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(color: Colors.teal.shade800),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.storefront,
                            size: 48,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            shopName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildNavItem(
                    context,
                    Icons.dashboard,
                    'Overview',
                    '/',
                    textStyle,
                    iconColor,
                  ),
                  _buildNavItem(
                    context,
                    Icons.list_alt,
                    'Orders',
                    '/orders',
                    textStyle,
                    iconColor,
                  ),
                  _buildNavItem(
                    context,
                    Icons.store,
                    'My Shop',
                    '/my-shop',
                    textStyle,
                    iconColor,
                  ),
                  _buildNavItem(
                    context,
                    Icons.restaurant_menu,
                    'Menu',
                    '/menu',
                    textStyle,
                    iconColor,
                  ),
                  _buildNavItem(
                    context,
                    Icons.rate_review,
                    'Reviews',
                    '/reviews',
                    textStyle,
                    iconColor,
                  ),
                ],
              ),
            ),
      body: Row(
        children: [
          // Sidebar for desktop
          if (MediaQuery.of(context).size.width > 800)
            Container(
              width: 250,
              color: sidebarColor,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Logo/Title Area for Sidebar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.storefront,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Owner Panel',
                          style: textStyle.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white24),
                  _buildNavItem(
                    context,
                    Icons.dashboard,
                    'Overview',
                    '/',
                    textStyle,
                    iconColor,
                  ),
                  _buildNavItem(
                    context,
                    Icons.list_alt,
                    'Orders',
                    '/orders',
                    textStyle,
                    iconColor,
                  ),
                  _buildNavItem(
                    context,
                    Icons.store,
                    'My Shop',
                    '/my-shop',
                    textStyle,
                    iconColor,
                  ),
                  _buildNavItem(
                    context,
                    Icons.restaurant_menu,
                    'Menu',
                    '/menu',
                    textStyle,
                    iconColor,
                  ),
                  _buildNavItem(
                    context,
                    Icons.rate_review,
                    'Reviews',
                    '/reviews',
                    textStyle,
                    iconColor,
                  ),
                ],
              ),
            ),
          // Main content
          Expanded(
            child: Container(
              color: Colors.grey.shade50, // Light background for content
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String title,
    String path,
    TextStyle textStyle,
    Color iconColor,
  ) {
    // Simple way to highlight active route - checking if current location starts with path
    // Note: This is a basic check. GoRouter state provides better ways but this works for simple cases.
    final isSelected = GoRouterState.of(context).uri.toString() == path;

    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.white : iconColor),
      title: Text(
        title,
        style: textStyle.copyWith(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor: isSelected ? Colors.white.withOpacity(0.1) : null,
      onTap: () => context.go(path),
    );
  }
}

// Helper widget because IconTheme isn't applying directly in some contexts
class HelperIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  const HelperIcon(this.icon, {super.key, required this.color});
  @override
  Widget build(BuildContext context) => Icon(icon, color: color);
}
