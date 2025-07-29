import 'package:flutter/material.dart';
import 'my_button.dart';
import '../models/product.dart';

class ProductTile extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;
  final VoidCallback onTap;

  const ProductTile({
    super.key,
    required this.product,
    required this.onAddToCart,
    required this.onTap,
  });

  // Helper method to determine if strikethrough should be shown
  bool _shouldShowStrikethrough() {
    if (!product.isOnSale) return false;
    if (product.salePrice == null || product.salePrice == 0) return false;
    return product.regularPrice > product.currentPrice;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image with badges
            Stack(
              children: [
                Container(
                  height: 120, // Fixed height for the container
                  width: double.infinity, // Take full width
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    color: Colors.grey.shade200,
                  ),
                  child: product.imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: Image.network(
                              product.imageUrl,
                              width: MediaQuery.of(context).size.width, // Full width
                              height: 120, // Match container height
                              loadingBuilder: (context, child, loadingProgress) {
                                return child;
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.broken_image),
                                      Text(
                                        'Image not available',
                                        style: TextStyle(fontSize: 8),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        )

                    
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.image_not_supported, size:20),
                              const Text(
                                'No image URL provided',
                                style: TextStyle(fontSize: 10),
                                ),
                              Text(
                                'Check debug logs',
                                style: TextStyle(fontSize: 8, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                ),
                if (product.isOnSale && _shouldShowStrikethrough())
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${product.salePercentage}% OFF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 94, 93, 93)
                          .withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.timer, size: 12, color: Colors.white),
                        const SizedBox(width: 2),
                        Text(
                          product.inStock ? 'IN STOCK' : 'OUT OF STOCK',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (product.isFeatured)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'FEATURED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Product details
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // SKU and Type
                  Text(
                    '${product.sku ?? 'N/A'} | ${product.type.toUpperCase()}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Price and Add button
                  Row(
                    children: [
                      // Price with strike-through
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rs ${product.currentPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          if (_shouldShowStrikethrough())
                            Text(
                              'Rs ${product.regularPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),
                      const Spacer(),
                      // Add button (disabled if out of stock)
                      GestureDetector(
                        onTap: product.inStock ? onAddToCart : null,
                        child: Container(
                          width: 60,
                          height: 30,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: product.inStock ? Colors.green : Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              product.inStock ? 'ADD' : 'SOLD',
                              style: TextStyle(
                                color: product.inStock ? Colors.green : Colors.grey,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}