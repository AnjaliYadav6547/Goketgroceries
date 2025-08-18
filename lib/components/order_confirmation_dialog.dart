// order_confirmation_dialog.dart
import 'package:flutter/material.dart';
import '../models/order.dart';

class OrderConfirmationDialog extends StatelessWidget {
  final Order order;

  const OrderConfirmationDialog({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Confirm Order',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total: Rs. ${order.total.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          const Text(
            'Shipping to:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(order.address.fullName),
          Text(order.address.addressLine1),
          if (order.address.addressLine2?.isNotEmpty ?? false)
            Text(order.address.addressLine2!),
          Text(order.address.city),
          Text(order.address.phoneNumber),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Confirm Order'),
        ),
      ],
    );
  }
}