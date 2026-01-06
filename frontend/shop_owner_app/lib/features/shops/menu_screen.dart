import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'shop_provider.dart';
import 'product_provider.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shop = context.read<ShopProvider>().shop;
      if (shop != null) {
        context.read<ProductProvider>().fetchProducts(shop['shop_id'] as int);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final shop = context.watch<ShopProvider>().shop;

    if (shop == null)
      return const Center(child: Text('Please set up your shop first.'));

    return Scaffold(
      appBar: AppBar(title: const Text('Menu Management')),
      body: productProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : productProvider.products.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your menu is empty',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => context.push('/add-product'),
                    child: const Text('Add First Item'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: productProvider.products.length,
              itemBuilder: (context, index) {
                final product = productProvider.products[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    onTap: () {
                      context.push('/add-product', extra: product);
                    },
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        image: product['image_url'] != null
                            ? DecorationImage(
                                image: NetworkImage(product['image_url']),
                                fit: BoxFit.cover,
                                onError: (_, __) => const Icon(
                                  Icons.fastfood,
                                  color: Colors.grey,
                                ),
                              )
                            : null,
                      ),
                      child: product['image_url'] == null
                          ? const Icon(Icons.fastfood, color: Colors.grey)
                          : null,
                    ),
                    title: Text(
                      product['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      product['description'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      '\$${product['price']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-product'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
