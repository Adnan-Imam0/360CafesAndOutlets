import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/api_client.dart';
import '../cart/cart_provider.dart';
import '../../core/utils/image_optimizer.dart';
import 'dart:async';

class ShopDetailsScreen extends StatefulWidget {
  final String shopId;
  final Map<String, dynamic>? shopData; // Optional, passed from list

  const ShopDetailsScreen({super.key, required this.shopId, this.shopData});

  @override
  State<ShopDetailsScreen> createState() => _ShopDetailsScreenState();
}

class _ShopDetailsScreenState extends State<ShopDetailsScreen> {
  final ApiClient _apiClient = ApiClient();
  Map<String, dynamic>? _shop;
  List<dynamic> _allProducts = []; // For categories
  List<dynamic> _displayedProducts = []; // For grid display
  bool _isLoading = true;
  Timer? _debounce;

  // Search & Filter State
  String _searchQuery = '';
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fetch initial full data
  Future<void> _fetchShopAndProducts() async {
    try {
      final shop = await _apiClient.get('/shops/${widget.shopId}');
      final products = await _apiClient.get('/products/shop/${widget.shopId}');

      if (mounted) {
        setState(() {
          _shop = shop;
          _allProducts = products ?? [];
          _displayedProducts = _allProducts; // Initially show all
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching shop details: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Server-Side Filter
  Future<void> _fetchFilteredProducts() async {
    // If no filter, reset to all (avoid API call if possible, or just call all)
    if (_searchQuery.isEmpty && _selectedCategory == null) {
      if (mounted) setState(() => _displayedProducts = _allProducts);
      return;
    }

    try {
      String endpoint = '/products/shop/${widget.shopId}';
      final params = <String>[];
      if (_searchQuery.isNotEmpty) {
        params.add('search=${Uri.encodeComponent(_searchQuery)}');
      }
      if (_selectedCategory != null) {
        params.add('category=${Uri.encodeComponent(_selectedCategory!)}');
      }

      if (params.isNotEmpty) {
        endpoint += '?${params.join('&')}';
      }

      final products = await _apiClient.get(endpoint);
      if (mounted) {
        setState(() {
          _displayedProducts = products ?? [];
        });
      }
    } catch (e) {
      print('Filter error: $e');
    }
  }

  List<String> _getUniqueCategories() {
    // Derive from ALL products so chips don't disappear
    final categories = _allProducts
        .map((p) => p['category'] as String?)
        .where((c) => c != null && c.isNotEmpty)
        .map((c) => c!)
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }

  Widget _buildCategoryChip(String label, String? categoryValue) {
    final isSelected = _selectedCategory == categoryValue;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool selected) {
          setState(() {
            // If selecting 'All' (null) or deselecting current
            if (categoryValue == null) {
              _selectedCategory = null;
            } else {
              _selectedCategory = selected ? categoryValue : null;
            }
          });
          _fetchFilteredProducts(); // Trigger fetch immediately
        },
        selectedColor: Theme.of(context).primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: Colors.grey[200],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        showCheckmark: false,
        side: BorderSide.none,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _shop = widget.shopData;
    _fetchShopAndProducts();
  }

  @override
  Widget build(BuildContext context) {
    final isOpen = _shop?['is_open'] ?? true;

    return Scaffold(
      appBar: AppBar(title: Text(_shop?['shop_name'] ?? 'Shop Menu')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async => _fetchShopAndProducts(),
              child: Column(
                children: [
                  if (!isOpen)
                    Container(
                      width: double.infinity,
                      color: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Text(
                        '⛔ This shop is currently closed.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  // Search and Filter Section
                  Column(
                    children: [
                      // Search Bar
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() => _searchQuery = value);
                            if (_debounce?.isActive ?? false)
                              _debounce!.cancel();
                            _debounce = Timer(
                              const Duration(milliseconds: 500),
                              () {
                                _fetchFilteredProducts();
                              },
                            );
                          },
                          decoration: InputDecoration(
                            hintText: 'Search menu...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.clear,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                      _fetchFilteredProducts();
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

                      // Category Chips
                      if (_allProducts.isNotEmpty)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              _buildCategoryChip('All', null),
                              ..._getUniqueCategories()
                                  .map((cat) => _buildCategoryChip(cat, cat))
                                  .toList(),
                            ],
                          ),
                        ),
                      const SizedBox(height: 8),
                    ],
                  ),

                  // Product List
                  Expanded(
                    child: _displayedProducts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.search_off,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? 'No items match "$_searchQuery"'
                                      : 'No items found.',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          )
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              int crossAxisCount = 1;
                              double aspectRatio = 2.5;

                              if (constraints.maxWidth > 900) {
                                crossAxisCount = 3;
                                aspectRatio = 1.0;
                              } else if (constraints.maxWidth > 600) {
                                crossAxisCount = 2;
                                aspectRatio = 1.2;
                              }

                              final filteredProducts = _displayedProducts;

                              return GridView.builder(
                                padding: const EdgeInsets.all(16),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: aspectRatio,
                                    ),
                                itemCount: filteredProducts.length,
                                itemBuilder: (context, index) {
                                  final product = filteredProducts[index];
                                  return _buildProductItem(
                                    context,
                                    product,
                                    isOpen,
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
      floatingActionButton: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.itemCount == 0) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () {
              context.push('/checkout');
            },
            label: Text(
              '${cart.itemCount} items (Rs. ' +
                  cart.totalAmount.toStringAsFixed(2) +
                  ')',
            ),
            icon: const Icon(Icons.shopping_cart),
            backgroundColor: !isOpen ? Colors.grey : null, // Grey out if closed
          );
        },
      ),
    );
  }

  Widget _buildProductItem(
    BuildContext context,
    Map<String, dynamic> product,
    bool isOpen,
  ) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Image
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                image:
                    product['image_url'] != null &&
                        product['image_url'].isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(
                          ImageOptimizer.optimize(
                            product['image_url'],
                            width: 200, // Optimize for list thumbnail
                          ),
                        ),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child:
                  product['image_url'] == null || product['image_url'].isEmpty
                  ? const Icon(Icons.fastfood, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product['description'] ?? '',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rs. ${product['price']}',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: !isOpen
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Shop is currently closed'),
                          backgroundColor: Colors.red,
                          duration: Duration(milliseconds: 1500),
                        ),
                      );
                    }
                  : () {
                      final cart = context.read<CartProvider>();
                      // Check if same shop
                      if (!cart.isSameShop(product['shop_id'])) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Different shop! Clear cart to add this item?',
                            ),
                            action: SnackBarAction(
                              label: 'CLEAR & ADD',
                              textColor: Colors.yellow,
                              onPressed: () {
                                cart.clear();
                                cart.addToCart(product);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${product['name']} added'),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                            duration: const Duration(seconds: 4),
                          ),
                        );
                        return;
                      }
                      cart.addToCart(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product['name']} added to cart'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
              icon: Icon(
                Icons.add_circle,
                color: isOpen ? Colors.deepOrange : Colors.grey,
                size: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
