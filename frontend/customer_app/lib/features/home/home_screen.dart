import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'shop_provider.dart';
import 'widgets/shop_card_skeleton.dart';
import '../../core/utils/image_optimizer.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedCategory;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchShops();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _fetchShops() {
    context.read<ShopProvider>().fetchShops(
      searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
      category: _selectedCategory,
    );
  }

  void _onCategorySelected(String category) {
    setState(() {
      if (_selectedCategory == category) {
        _selectedCategory = null;
      } else {
        _selectedCategory = category;
      }
    });
    _fetchShops(); // Fetch immediately on chip tap
  }

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchShops();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover Shops'), actions: const []),
      body: Consumer<ShopProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = 1;
                if (constraints.maxWidth > 900) {
                  crossAxisCount = 3;
                } else if (constraints.maxWidth > 600) {
                  crossAxisCount = 2;
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) => const ShopCardSkeleton(),
                );
              },
            );
          }

          // Use provider.shops directly (Server-Side Filtered)
          final filteredShops = provider.shops;

          return LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = 1;
              if (constraints.maxWidth > 900) {
                crossAxisCount = 3;
              } else if (constraints.maxWidth > 600) {
                crossAxisCount = 2;
              }

              return Column(
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search for cafes, outlets...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged(''); // Triggers fetch
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 0,
                        ),
                      ),
                    ),
                  ),

                  // Category Selection
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                            onTap: () =>
                                setState(() => _selectedCategory = null),
                            child: const Text(
                              '(Show All)',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Shop List (Responsive Grid/List)
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
                            onRefresh: () async => _fetchShops(),
                            child: GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio:
                                        1.1, // Adjust for card height
                                  ),
                              itemCount: filteredShops.length,
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
    final rating =
        double.tryParse(shop['average_rating']?.toString() ?? '0') ?? 0.0;
    final reviewCount =
        int.tryParse(shop['review_count']?.toString() ?? '0') ?? 0;

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
                        image: NetworkImage(
                          ImageOptimizer.optimize(
                            shop['profile_picture_url'],
                            width: 400, // Optimize for card width
                          ),
                        ),
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
                      Expanded(
                        child: Text(
                          shop['shop_name'] ?? 'Unknown Shop',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        rating > 0 ? rating.toStringAsFixed(1) : 'New',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (reviewCount > 0) ...[
                        const SizedBox(width: 4),
                        Text(
                          '($reviewCount)',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(width: 16),
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
