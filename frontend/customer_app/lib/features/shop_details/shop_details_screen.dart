import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/api_client.dart';
import '../cart/cart_provider.dart';

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
  List<dynamic> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _shop = widget.shopData;
    _fetchShopAndProducts();
  }

  Future<void> _fetchShopAndProducts() async {
    try {
      // If shop data wasn't passed, fetch it (omitted for now, assuming passed or we just fetch products)
      // Fetch products
      final products = await _apiClient.get('/products/shop/${widget.shopId}');
      if (mounted) {
        setState(() {
          _products = products ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching shop details: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_shop?['shop_name'] ?? 'Shop Menu')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
          ? const Center(child: Text('No products available.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return _buildProductItem(context, product);
              },
            ),
      floatingActionButton: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.itemCount == 0) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () {
              context.push('/checkout');
            },
            label: Text(
              '${cart.itemCount} items (\$' +
                  cart.totalAmount.toStringAsFixed(2) +
                  ')',
            ),
            icon: const Icon(Icons.shopping_cart),
          );
        },
      ),
    );
  }

  Widget _buildProductItem(BuildContext context, Map<String, dynamic> product) {
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
                        image: NetworkImage(product['image_url']),
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
                    '\$${product['price']}',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                final cart = context.read<CartProvider>();
                // Check if same shop
                if (!cart.isSameShop(product['shop_id'])) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Can only order from one shop at a time. Clear cart?',
                      ),
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
              icon: const Icon(
                Icons.add_circle,
                color: Colors.deepOrange,
                size: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
