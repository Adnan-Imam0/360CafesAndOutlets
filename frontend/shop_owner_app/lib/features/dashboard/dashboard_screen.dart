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
      shopProvider.fetchMyShop(authProvider.user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cafe 360 Owner Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
              context.go('/login');
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Center(child: Text('Cafe 360'))),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Overview'),
              onTap: () => context.go('/'),
            ),
            ListTile(
              leading: const Icon(Icons.store),
              title: const Text('My Shop'),
              onTap: () => context.go('/my-shop'),
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('Orders'),
              onTap: () => context.go('/orders'),
            ),
            ListTile(
              leading: const Icon(Icons.restaurant_menu),
              title: const Text('Menu'),
              onTap: () => context.go('/menu'),
            ),
          ],
        ),
      ),
      body: Row(
        children: [
          // Sidebar for desktop
          if (MediaQuery.of(context).size.width > 800)
            SizedBox(
              width: 250,
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.dashboard),
                    title: const Text('Overview'),
                    onTap: () => context.go('/'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.store),
                    title: const Text('My Shop'),
                    onTap: () => context.go('/my-shop'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.list_alt),
                    title: const Text('Orders'),
                    onTap: () => context.go('/orders'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.restaurant_menu),
                    title: const Text('Menu'),
                    onTap: () => context.go('/menu'),
                  ),
                ],
              ),
            ),
          if (MediaQuery.of(context).size.width > 800)
            const VerticalDivider(width: 1),
          // Main content
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}

class OverviewView extends StatelessWidget {
  const OverviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Dashboard Overview'));
  }
}
