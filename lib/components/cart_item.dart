import 'package:flutter/material.dart';
import '../models/product.dart';

class CartItem extends StatelessWidget {
  final Product product;
  final int quantity;
  final VoidCallback onRemove;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const CartItem({
    super.key,
    required this.product,
    required this.quantity,
    required this.onRemove,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Product Image
            _buildProductImage(),
            const SizedBox(width: 16),
            
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductName(),
                  const SizedBox(height: 4),
                  _buildProductSku(),
                  const SizedBox(height: 8),
                  _buildPriceAndQuantityControls(),
                ],
              ),
            ),
            
            // Remove Button
            _buildRemoveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        product.imageUrl,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 80,
          height: 80,
          color: Colors.grey[200],
          child: const Icon(Icons.image, size: 40),
        ),
      ),
    );
  }

  Widget _buildProductName() {
    return Text(
      product.name,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildProductSku() {
    return Text(
      'SKU: ${product.sku ?? 'N/A'}',
      style: TextStyle(
        color: Colors.grey[600],
        fontSize: 12,
      ),
    );
  }

  Widget _buildPriceAndQuantityControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Price Column
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rs${product.currentPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (product.isOnSale)
              Text(
                'Was Rs${product.regularPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  decoration: TextDecoration.lineThrough,
                ),
              ),
          ],
        ),
        
        // Quantity Controls
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove, size: 20),
              onPressed: onDecrease,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                quantity.toString(),
                style: const TextStyle(fontSize: 16),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, size: 20),
              onPressed: onIncrease,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRemoveButton() {
    return IconButton(
      icon: const Icon(Icons.delete_outline, color: Colors.red),
      onPressed: onRemove,
    );
  }
}