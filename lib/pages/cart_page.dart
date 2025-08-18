import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart.dart' hide CartItem;
import '../models/order.dart';
import '../pages/shipping_detail_page.dart';
import '../components/order_confirmation_dialog.dart';
import '../pages/order_success_page.dart';
import '../components/cart_item.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Cart>(
      builder: (context, cart, child) {
        if (cart.items.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined, size: 64),
                SizedBox(height: 16),
                Text('Your cart is empty'),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cart.items.length,
                itemBuilder: (context, index) {
                  final item = cart.items[index];
                  return CartItem(
                    product: item.product,
                    quantity: item.quantity,
                    onRemove: () => cart.removeItem(item.product),
                    onIncrease: () => cart.addItem(item.product),
                    onDecrease: () => cart.decreaseQuantity(item.product),
                  );
                },
              ),
            ),
            _buildCheckoutSection(context, cart),
          ],
        );
      },
    );
  }

  Widget _buildCheckoutSection(BuildContext context, Cart cart) {
    final deliveryFee = cart.totalPrice > 500 ? 0 : 50;
    final total = cart.totalPrice + deliveryFee;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildPriceRow('Subtotal', cart.totalPrice),
            _buildPriceRow('Delivery', deliveryFee.toDouble()),
            const Divider(),
            _buildPriceRow('Total', total, isTotal: true),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _proceedToCheckout(context, cart),
              child: const Text('PROCEED TO CHECKOUT'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            'Rs${amount.toStringAsFixed(2)}',
            style: isTotal 
                ? const TextStyle(fontWeight: FontWeight.bold)
                : null,
          ),
        ],
      ),
    );
  }

  Future<void> _proceedToCheckout(BuildContext context, Cart cart) async {
    final addressData = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const ShippingDetailsPage(),
    );

    if (addressData == null) return;

    final order = cart.createOrder(
      address: ShippingAddress(
        fullName: addressData['fullName']!,
        addressLine1: addressData['addressLine1']!,
        addressLine2: addressData['addressLine2'],
        city: addressData['city']!,
        phoneNumber: addressData['phoneNumber']!,
      ),
      paymentMethod: addressData['paymentMethod'] ?? 'cod',
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => OrderConfirmationDialog(order: order),
    );

    if (confirmed == true) {
      try {
        // Here you would typically call your OrderRepository to save the order
        cart.clearCart();
        
        if (!context.mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderSuccessPage(order: order),
          ),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Checkout failed: ${e.toString()}')),
        );
      }
    }
  }
}

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRemove;
  final ValueChanged<int> onQuantityChanged;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.product.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.image),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rs${item.product.currentPrice.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            QuantitySelector(
              quantity: item.quantity,
              onChanged: onQuantityChanged,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: () => onChanged(quantity - 1),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(quantity.toString()),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => onChanged(quantity + 1),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}