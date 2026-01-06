import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../cart/cart_provider.dart';
import '../auth/auth_provider.dart';
import '../../core/api_client.dart';
import '../address/address_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressController = TextEditingController();
  final _apiClient = ApiClient();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.customerProfile != null) {
        final customerId = auth.customerProfile!['customer_id'];
        context.read<AddressProvider>().fetchAddresses(customerId);
      }
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a delivery address')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final cart = context.read<CartProvider>();
      final auth = context.read<AuthProvider>();

      if (auth.customerProfile == null) {
        throw Exception('User profile not loaded');
      }

      final customerId = auth.customerProfile!['customer_id'];
      // Assuming all items from same shop, get shopId from first item
      final shopId = cart.items.values.first.shopId;

      final orderItems = cart.items.values
          .map(
            (item) => {
              'product_id': item.id,
              'quantity': item.quantity,
              'price': item.price,
              'name': item.name,
            },
          )
          .toList();

      final orderData = {
        'customer_id': customerId,
        'shop_id': shopId,
        'delivery_address': _addressController.text,
        'total_amount': cart.totalAmount,
        'customer_name': auth.customerProfile!['display_name'],
        'customer_phone': auth.customerProfile!['phone_number'],
        'items': orderItems,
      };

      await _apiClient.post('/orders', orderData);

      if (mounted) {
        cart.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!')),
        );
        context.go('/orders');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to place order: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.itemCount == 0) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Your cart is empty'),
                  TextButton(
                    onPressed: () => context.go('/home'),
                    child: const Text('Go Shopping'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Items List
                ...cart.items.values.map(
                  (item) => ListTile(
                    title: Text(item.name),
                    subtitle: Text('${item.quantity} x \$${item.price}'),
                    trailing: Text('\$${item.total.toStringAsFixed(2)}'),
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        '\$${cart.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Address Field
                const Text(
                  'Delivery Address',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // Saved Addresses
                Consumer<AddressProvider>(
                  builder: (context, addressProvider, _) {
                    if (addressProvider.addresses.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Container(
                      height: 50,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: addressProvider.addresses.length,
                        itemBuilder: (context, index) {
                          final addr = addressProvider.addresses[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ActionChip(
                              avatar: Icon(
                                _getIconForLabel(addr['address_label']),
                                size: 16,
                              ),
                              label: Text(addr['address_label'] ?? 'Addr'),
                              onPressed: () {
                                _addressController.text =
                                    addr['full_address'] ?? '';
                              },
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),

                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    hintText: 'Enter full address...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 32),

                // Submit Button
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _placeOrder,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Place Order',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  IconData _getIconForLabel(String? label) {
    switch (label?.toLowerCase()) {
      case 'home':
        return Icons.home;
      case 'work':
        return Icons.work;
      default:
        return Icons.location_on;
    }
  }
}
