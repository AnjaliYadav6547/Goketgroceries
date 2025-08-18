import 'package:flutter/material.dart';
import '../models/product.dart' as model;
import '../pages/product_detail.dart';

class ProductTile extends StatelessWidget {
  final model.Product product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  

  const ProductTile({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAddToCart,
    
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
      onTap: () {
        // Call the provided onTap callback if it exists
        if (onTap != null) {
          onTap();
        } else {
          // Default navigation behavior
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailPage(productId: product.id),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image with badges
            Stack(
              children: [
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    color: Colors.grey.shade200,
                  ),
                  child: product.imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                          child: Image.network(
                            product.imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.broken_image, size: 30),
                                    Text(
                                      'Image not available',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 30,
                            color: Colors.grey.shade400,
                          ),
                        ),
                ),
                // Sale badge
                if (product.isOnSale && _shouldShowStrikethrough())
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                // Stock status badge
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: product.inStock 
                          ? Colors.green.withOpacity(0.8)
                          : Colors.red.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          product.inStock ? Icons.check : Icons.close,
                          size: 12,
                          color: Colors.white,
                        ),
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
                // Featured badge
                if (product.isFeatured)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name - single line with ellipsis
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Price and Add button
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rs ${product.currentPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          if (_shouldShowStrikethrough())
                            Text(
                              'Rs ${product.regularPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey[600],
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),
                      const Spacer(),
                      // Add button
                      InkWell(
                        onTap: product.inStock ? onAddToCart : null,
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          width: 40,
                          height: 25,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: product.inStock ? Colors.green : Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(4),
                            color: product.inStock 
                                ? Colors.green.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                          ),
                          child: Center(
                            child: Text(
                              product.inStock ? 'ADD' : 'SOLD',
                              style: TextStyle(
                                color: product.inStock ? Colors.green : Colors.grey,
                                fontSize: 12,
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