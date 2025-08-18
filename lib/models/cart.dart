import 'package:flutter/material.dart';
import 'order.dart';
import 'product.dart';

class Cart extends ChangeNotifier {
  final List<CartItem> _items = [];
  final List<Order> _orderHistory = [];

  List<CartItem> get items => List.unmodifiable(_items);
  List<Order> get orderHistory => List.unmodifiable(_orderHistory);
  double get totalPrice => _calculateTotal();
  int get itemCount => _calculateItemCount();

  // Item Management
  void addItem(Product product, {int quantity = 1}) {
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + quantity,
      );
    } else {
      _items.add(CartItem(
        product: product,
        quantity: quantity,
      ));
    }
    notifyListeners();
  }

  void removeItem(Product product) {
    _items.removeWhere((item) => item.product.id == product.id);
    notifyListeners();
  }

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

  void updateQuantity(Product product, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(product);
      return;
    }

    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: newQuantity,
      );
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // Order Management
  Order createOrder({
    required ShippingAddress address,
    required String paymentMethod,
  }) {
    return Order(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      items: _items.map((item) => OrderItem(
        productId: item.product.id.toString(),
        productName: item.product.name,
        quantity: item.quantity,
        price: item.product.currentPrice,
        imageUrl: item.product.imageUrl,
      )).toList(),
      total: _calculateOrderTotal(),
      address: address,
      paymentMethod: paymentMethod,
      orderDate: DateTime.now(),
    );
  }

  Future<void> checkout(Order order) async {
    _orderHistory.insert(0, order);
    _items.clear();
    notifyListeners();
  }

  // Helpers
  double _calculateTotal() {
    return _items.fold(0, (sum, item) => sum + (item.product.currentPrice * item.quantity));
  }

  double _calculateOrderTotal() {
    final subtotal = _calculateTotal();
    return subtotal + (subtotal > 500 ? 0 : 50); // Delivery fee logic
  }

  int _calculateItemCount() {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  bool containsProduct(Product product) {
    return _items.any((item) => item.product.id == product.id);
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

  double get lineTotal => product.currentPrice * quantity;
}