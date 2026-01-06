import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String? imageUrl;
  final int shopId;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl,
    required this.shopId,
  });

  double get total => price * quantity;
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  int get itemCount => _items.length;

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, item) {
      total += item.price * item.quantity;
    });
    return total;
  }

  void addToCart(Map<String, dynamic> product, {int quantity = 1}) {
    final productId = product['product_id'].toString();
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (existing) => CartItem(
          id: existing.id,
          name: existing.name,
          price: existing.price,
          quantity: existing.quantity + quantity,
          imageUrl: existing.imageUrl,
          shopId: existing.shopId,
        ),
      );
    } else {
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: productId,
          name: product['name'],
          price: double.parse(product['price'].toString()),
          quantity: quantity,
          imageUrl: product['image_url'],
          shopId: product['shop_id'],
        ),
      );
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  // simple check to ensure all items are from same shop
  bool isSameShop(int newShopId) {
    if (_items.isEmpty) return true;
    return _items.values.first.shopId == newShopId;
  }
}
