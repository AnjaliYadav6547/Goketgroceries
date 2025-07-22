import 'package:flutter/material.dart';
import 'product.dart';

class Cart extends ChangeNotifier {
  // List of items in user cart with quantity tracking
  final List<CartItem> _items = [];

  // Get cart items
  List<CartItem> get items => _items;

  // Add item to cart or increment quantity if already exists
  void addItem(Product product) {
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + 1,
      );
    } else {
      _items.add(CartItem(
        product: product,
        quantity: 1,
      ));
    }
    notifyListeners();
  }

  // Remove item from cart completely
  void removeItem(Product product) {
    _items.removeWhere((item) => item.product.id == product.id);
    notifyListeners();
  }

  // Decrease item quantity, remove if quantity reaches 0
  void decreaseQuantity(Product product) {
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      if (_items[existingIndex].quantity > 1) {
        _items[existingIndex] = _items[existingIndex].copyWith(
          quantity: _items[existingIndex].quantity - 1,
        );
      } else {
        _items.removeAt(existingIndex);
      }
      notifyListeners();
    }
  }

  // Clear cart
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // Calculate total price including quantity
  double get totalPrice {
    return _items.fold(0, (sum, item) => sum + (item.product.currentPrice * item.quantity));
  }

  // Get total number of items in cart (counting quantities)
  int get itemCount {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }
}

class CartItem {
  final Product product;
  final int quantity;

  CartItem({
    required this.product,
    required this.quantity,
  });

  CartItem copyWith({
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}