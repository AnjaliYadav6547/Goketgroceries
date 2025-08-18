// order_summary_page.dart
import 'package:flutter/material.dart';
import '../models/order.dart';

class OrderSummaryPage extends StatelessWidget {
  final Order order;

  const OrderSummaryPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Summary'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderHeader(),
            const SizedBox(height: 24),
            _buildShippingInfo(),
            const SizedBox(height: 24),
            _buildOrderItems(),
            const SizedBox(height: 24),
            _buildOrderTotals(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order #${order.id}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Status: ${order.status.toUpperCase()}'),
            Text('Date: ${_formatDate(order.orderDate)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shipping Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
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
      ),
    );
  }

  Widget _buildOrderItems() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Items',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...order.items.map((item) => _buildOrderItem(item)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (item.imageUrl.isNotEmpty)
            Image.network(
              item.imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Qty: ${item.quantity}'),
                Text('Rs ${item.price.toStringAsFixed(2)} each'),
              ],
            ),
          ),
          Text(
            'Rs ${(item.price * item.quantity).toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTotals() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTotalRow('Subtotal', _calculateSubtotal()),
            _buildTotalRow('Delivery Fee', _getDeliveryFee()),
            const Divider(),
            _buildTotalRow(
              'Total',
              order.total,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, double value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            'Rs ${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateSubtotal() {
    return order.items.fold(
        0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  double _getDeliveryFee() {
    return order.total > 0 ? (order.total - _calculateSubtotal()) : 0.0;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}