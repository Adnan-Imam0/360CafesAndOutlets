import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_provider.dart';
import 'shop_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShopProvider>().fetchShops();
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      if (_selectedCategory == category) {
        _selectedCategory = null; // Toggle off if already selected
      } else {
        _selectedCategory = category;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Shops'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().signOut();
              context.go('/login');
            },
          ),
        ],
      ),
      body: Consumer<ShopProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Filter shops
          final filteredShops = _selectedCategory == null
              ? provider.shops
              : provider.shops.where((shop) {
                  final type = (shop['shop_type'] ?? '')
                      .toString()
                      .toLowerCase()
                      .trim();
                  final name = (shop['shop_name'] ?? '')
                      .toString()
                      .toLowerCase()
                      .trim();
                  final category = (_selectedCategory ?? '')
                      .toLowerCase()
                      .trim();

                  // Match if type OR name contains the category
                  return type.contains(category) || name.contains(category);
                }).toList();

          return Column(
            children: [
              // Category Selection
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildCategoryCard(
                        title: 'Cafes',
                        icon: Icons.local_cafe,
                        isSelected: _selectedCategory == 'Cafe',
                        onTap: () => _onCategorySelected('Cafe'),
                        color: Colors.brown.shade100,
                        selectedColor: Colors.brown,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildCategoryCard(
                        title: 'Outlets',
                        icon: Icons.store_mall_directory,
                        isSelected: _selectedCategory == 'Outlet',
                        onTap: () => _onCategorySelected('Outlet'),
                        color: Colors.blue.shade100,
                        selectedColor: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),

              // Divider or Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      _selectedCategory == null
                          ? 'All Places'
                          : '${_selectedCategory}s',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_selectedCategory != null) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => setState(() => _selectedCategory = null),
                        child: const Text(
                          '(Show All)',
                          style: TextStyle(color: Colors.blue, fontSize: 14),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Shop List
              Expanded(
                child: filteredShops.isEmpty
                    ? Center(
                        child: Text(
                          _selectedCategory == null
                              ? 'No shops found.'
                              : 'No ${_selectedCategory!.toLowerCase()}s found.',
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async => provider.fetchShops(),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredShops.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final shop = filteredShops[index];
                            return _buildShopCard(context, shop);
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
    required Color selectedColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: selectedColor.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
          border: isSelected
              ? Border.all(color: Colors.white, width: 2)
              : Border.all(color: Colors.transparent),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Colors.white : selectedColor,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShopCard(BuildContext context, Map<String, dynamic> shop) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push('/shop/${shop['shop_id']}', extra: shop);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shop Image
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                image:
                    shop['profile_picture_url'] != null &&
                        shop['profile_picture_url'].toString().isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(shop['profile_picture_url']),
                        fit: BoxFit.cover,
                        onError: (_, __) => const Icon(Icons.store, size: 50),
                      )
                    : null,
              ),
              child:
                  shop['profile_picture_url'] == null ||
                      shop['profile_picture_url'].toString().isEmpty
                  ? const Center(
                      child: Icon(Icons.store, size: 50, color: Colors.grey),
                    )
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        shop['shop_name'] ?? 'Unknown Shop',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          shop['shop_type'] ?? 'Cafe',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          shop['address'] ?? 'No address',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
