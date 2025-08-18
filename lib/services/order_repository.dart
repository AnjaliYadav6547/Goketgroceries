import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order.dart';

class OrderRepository {
  static const String _baseUrl = 'https://api.goket.com.np/';

  // Store cart items temporarily
  List<Map<String, dynamic>> _cartItems = [];

  Future<Map<String, dynamic>> fetchCartItems() async {
    try {
      // Replace this with your actual data fetching logic
      // For example, this could be from an API or local storage
      final response = await _getCartItemsFromAPI(); // Your API call method
      
      _cartItems = List<Map<String, dynamic>>.from(response['items']);
      
      return {
        'items': _cartItems,
        'subtotal': response['subtotal'] ?? _calculateSubtotal(_cartItems),
        'delivery_fee': response['delivery_fee'] ?? 0.0,
        'total': response['total'] ?? _calculateTotal(_cartItems, response['delivery_fee'] ?? 0.0),
      };
    } catch (e) {
      // Return the stored cart items even if fetch fails
      return {
        'items': _cartItems,
        'subtotal': _calculateSubtotal(_cartItems),
        'delivery_fee': 0.0,
        'total': _calculateTotal(_cartItems, 0.0),
      };
    }
  }

  double _calculateSubtotal(List<Map<String, dynamic>> items) {
    return items.fold(0.0, (sum, item) => sum + (item['price'] * item['quantity']));
  }

  double _calculateTotal(List<Map<String, dynamic>> items, double deliveryFee) {
    return _calculateSubtotal(items) + deliveryFee;
  }

  // Example method - replace with your actual API call
  Future<Map<String, dynamic>> _getCartItemsFromAPI() async {
    // This would be your actual API call implementation
    return {
      'items': [
        {
          'id': '1',
          'name': 'Apples',
          'price': 20.0,
          'quantity': 1,
          'image_url': '',
        },
        {
          'id': '2',
          'name': 'Bananas',
          'price': 30.0,
          'quantity': 2,
          'image_url': '',
        },
      ],
      'subtotal': 80.0,
      'delivery_fee': 0.0,
      'total': 80.0,
    };
  }
  

  // Future<List<Order>> fetchOrderHistory() async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse('${_baseUrl}orders/'),
  //       headers: {'Content-Type': 'application/json'},
  //     );

  //     if (response.statusCode == 200) {
  //       final List<dynamic> data = json.decode(response.body);
  //       return data.map((json) => _parseOrderFromJson(json)).toList();
  //     } else {
  //       throw Exception('Failed to load orders (Status: ${response.statusCode})');
  //     }
  //   } catch (e) {
  //     throw Exception('Failed to fetch order history: ${e.toString().replaceAll('Exception: ', '')}');
  //   }
  // }


  Order _parseOrderFromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'].toString(),
      items: _parseOrderItems(json['items']),
      total: double.tryParse(json['total'].toString()) ?? 0.0,
      address: json['shipping_address'] != null 
          ? ShippingAddress.fromJson(json['shipping_address'])
          : ShippingAddress(
              fullName: 'N/A',
              addressLine1: 'N/A',
              city: 'N/A',
              phoneNumber: 'N/A',
            ),
      paymentMethod: 'cod', // Default since API doesn't provide
      orderDate: DateTime.parse(json['created_at']),
      status: json['status'] ?? 'pending',
    );
  }

  List<OrderItem> _parseOrderItems(List<dynamic> items) {
    return items.map((item) {
      final product = item['product'] ?? {};
      return OrderItem(
        productId: product['id']?.toString() ?? '',
        productName: product['name']?.toString() ?? 'Unknown Product',
        quantity: (item['quantity'] as num?)?.toInt() ?? 0,
        price: double.tryParse(item['price'].toString()) ?? 0.0,
        imageUrl: product['images'] != null && product['images'].isNotEmpty
            ? product['images'][0]['thumbnail'] ?? ''
            : '',
      );
    }).toList();
  }
  

  //Add this method to your OrderRepository class
  // Future<Map<String, dynamic>> fetchCartOrder() async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse('${_baseUrl}cart/'), // Adjust endpoint as needed
  //       headers: {'Content-Type': 'application/json'},
  //     );

  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       return {
  //         'subtotal': data['subtotal'] ?? 0.0,
  //         'delivery_fee': data['delivery_fee'] ?? 0.0,
  //         'total': data['total'] ?? 0.0,
  //         'items': data['items'] ?? [],
  //       };
  //     } else {
  //       throw Exception('Failed to load cart: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     throw Exception('Failed to fetch cart: ${e.toString()}');
  //   }
  // }
  
}