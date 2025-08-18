import 'package:flutter/material.dart';

class Order {
  final String id;
  final List<OrderItem> items;
  final double total;
  final ShippingAddress address;
  final String paymentMethod;
  final DateTime orderDate;
  final String status;

  Order({
    required this.id,
    required this.items,
    required this.total,
    required this.address,
    required this.paymentMethod,
    required this.orderDate,
    this.status = 'pending',
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? '',
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      total: (json['total'] as num).toDouble(),
      address: ShippingAddress.fromJson(json['address']),
      paymentMethod: json['payment_method'] ?? 'cod',
      orderDate: DateTime.parse(json['order_date']),
      status: json['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((item) => item.toJson()).toList(),
      'total': total,
      'address': address.toJson(),
      'payment_method': paymentMethod,
      'order_date': orderDate.toIso8601String(),
      'status': status,
    };
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final String imageUrl;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.imageUrl,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product_id']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['image_url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'price': price,
      'image_url': imageUrl,
    };
  }
}

class ShippingAddress {
  final String fullName;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String phoneNumber;

  ShippingAddress({
    required this.fullName,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.phoneNumber,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      fullName: json['full_name']?.toString() ?? '',
      addressLine1: json['address_line1']?.toString() ?? '',
      addressLine2: json['address_line2']?.toString(),
      city: json['city']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'address_line1': addressLine1,
      'address_line2': addressLine2 ?? '',
      'city': city,
      'phone_number': phoneNumber,
    };
  }
}