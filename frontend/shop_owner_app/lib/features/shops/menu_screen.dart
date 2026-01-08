import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'shop_provider.dart';
import 'product_provider.dart';
import 'category_provider.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shop = context.read<ShopProvider>().shop;
      if (shop != null) {
        context.read<ProductProvider>().fetchProducts(shop['shop_id'] as int);
        // Also fetch categories for the filter
        context.read<CategoryProvider>().fetchCategories(
          shop['shop_id'] as int,
        );
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final shop = context.watch<ShopProvider>().shop;

    if (shop == null) {
      return const Center(child: Text('Please set up your shop first.'));
    }

    // Filter Logic
    final allProducts = productProvider.products;
    final categoryProvider = context.watch<CategoryProvider>();

    final filteredProducts = allProducts.where((product) {
      final matchesSearch = product['name'].toString().toLowerCase().contains(
        _searchController.text.toLowerCase(),
      );

      // Robust Category Matching
      String productCategory = product['category'] ?? 'Others';
      // If category name is missing/null, try to find it by ID from the provider
      if (product['category'] == null && product['category_id'] != null) {
        final cat = categoryProvider.categories.firstWhere(
          (c) =>
              c['category_id'].toString() == product['category_id'].toString(),
          orElse: () => {'name': 'Others'},
        );
        productCategory = cat['name'];
      }

      final matchesCategory =
          _selectedCategory == 'All' || productCategory == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Menu Management')),
      body: productProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filter Section
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Row(
                    children: [
                      // Search Bar
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search products...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {});
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                          ),
                          onChanged: (value) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Category Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.3),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategory,
                            icon: Icon(
                              Icons.filter_list,
                              color: Theme.of(context).primaryColor,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            items: [
                              const DropdownMenuItem<String>(
                                value: 'All',
                                child: Text('All Categories'),
                              ),
                              ...context
                                  .watch<CategoryProvider>()
                                  .categories
                                  .map((c) => c['name'].toString())
                                  .toSet() // Ensure uniqueness
                                  .map((category) {
                                    return DropdownMenuItem<String>(
                                      value: category,
                                      child: Text(
                                        category,
                                        style: TextStyle(
                                          color: _selectedCategory == category
                                              ? Theme.of(context).primaryColor
                                              : Colors.black87,
                                          fontWeight:
                                              _selectedCategory == category
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    );
                                  }),
                            ].toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedCategory = value);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Product Grid
                Expanded(
                  child: filteredProducts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No products found',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 200,
                                childAspectRatio:
                                    0.68, // Taller cards to prevent overflow
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            return GestureDetector(
                              onTap: () =>
                                  context.push('/add-product', extra: product),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 10, // 50% height approx
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(16),
                                              ),
                                          image: product['image_url'] != null
                                              ? DecorationImage(
                                                  image: NetworkImage(
                                                    product['image_url'],
                                                  ),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                        ),
                                        child: product['image_url'] == null
                                            ? Center(
                                                child: Icon(
                                                  Icons.fastfood,
                                                  size: 40,
                                                  color: Colors.grey[400],
                                                ),
                                              )
                                            : null,
                                      ),
                                    ),
                                    Expanded(
                                      flex:
                                          9, // 45% height approx - more space for text
                                      child: Padding(
                                        padding: const EdgeInsets.all(
                                          10.0,
                                        ), // Reduced padding
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  product['name'],
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  product['description'] ?? '',
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize:
                                                        11, // Smaller font
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              'Rs. ${product['price']}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Theme.of(
                                                  context,
                                                ).primaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-product'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
