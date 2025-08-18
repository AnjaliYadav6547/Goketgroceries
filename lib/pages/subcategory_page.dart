import 'package:flutter/material.dart';
import 'package:flutter_application/models/category.dart';
import 'package:flutter_application/models/cart.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application/models/product.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vegetables App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      
    );
  }
}

class SubCategoryPage extends StatefulWidget {
  const SubCategoryPage({super.key, required Category category});

  @override
  State<SubCategoryPage> createState() => _SubCategoryPageState();
}

class _SubCategoryPageState extends State<SubCategoryPage> {
  String? _selectedCategory;

  final List<Map<String, dynamic>> categories = [
    {'name': 'Fresh Vegetables', 'image': 'assets/vegetables.png'},
    {'name': 'Fresh Fruits', 'image': 'assets/fruits.png'},
    {'name': 'Mangoes & Melons', 'image': 'assets/mangoes.png'},
    {'name': 'Seasonal', 'image': 'assets/seasonal.png'},
    {'name': 'Exotics', 'image': 'assets/exotics.png'},
    {'name': 'Freshly Cut & Sprouts', 'image': 'assets/sprouts.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delivery in 8 minutes',
              style: TextStyle(fontSize: 14),
            ),
            Text(
              'Buy Fresh Vegetables Online',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      
      body: Row(
        children: [
          // Left side - Categories (30% width)
          Container(
            width: MediaQuery.of(context).size.width * 0.3,
            color: Colors.grey[50],
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return _buildCategoryItem(categories[index]);
              },
            ),
          ),

          // Right side - Products (70% width)
          Expanded(
            child: Column(
              children: [
                
                
                // Product Grid
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: [
                        // First product row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildProductCard(
                                product: Product(
                                  id: 1,
                                  name: 'Onion (Eerulli)',
                                  // weight: '(0.95-1.05) kg',
                                  regularPrice: 46,
                                  salePrice: 27,
                                  imageUrl: '',
                                  category: 1,
                                  brand: 1,
                                  type: 'simple',
                                  isFeatured: false,
                                  inStock: true,
                                  sku: 'ONION001',
                                  published: true,
                                  createdAt: DateTime.now(),
                                  updatedAt: DateTime.now(),
                                  variantIds: [],
                                ),
                                deliveryTime: '8 MINS',
                                name: 'Onion (Eerulli)',
                                weight: '(0.95-1.05) kg',
                                currentPrice: 27,
                                originalPrice: 46,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildProductCard(
                                product: Product(
                                  id: 2,
                                  name: 'Potato',
                                  // weight: '(0.95-1.05) kg',
                                  regularPrice: 48,
                                  salePrice: 30,
                                  imageUrl: '',
                                  category: 1,
                                  brand: 1,
                                  type: 'simple',
                                  isFeatured: false,
                                  inStock: true,
                                  sku: 'POTATO001',
                                  published: true,
                                  createdAt: DateTime.now(),
                                  updatedAt: DateTime.now(),
                                  variantIds: [],
                                ),
                                deliveryTime: '9 MINS',
                                name: 'Potato',
                                weight: '(0.95-1.05) kg',
                                currentPrice: 30,
                                originalPrice: 48,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Second product row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildProductCard(
                                product: Product(
                                  id: 3,
                                  name: 'Desi Tomato 500 g (Naati Tomato)',
                                  // weight: '500 g',
                                  regularPrice: 19,
                                  salePrice: 14,
                                  imageUrl: '',
                                  category: 1,
                                  brand: 1,
                                  type: 'simple',
                                  isFeatured: false,
                                  inStock: true,
                                  sku: 'TOMATO001',
                                  published: true,
                                  createdAt: DateTime.now(),
                                  updatedAt: DateTime.now(),
                                  variantIds: [],
                                ),
                                deliveryTime: '6 MINS',
                                name: 'Desi Tomato 500 g (Naati Tomato)',
                                weight: '500 g',
                                currentPrice: 14,
                                originalPrice: 19,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildProductCard(
                                product: Product(
                                  id: 4,
                                  name: 'Hybrid Tomato 500 g',
                                  // weight: '500 g',
                                  regularPrice: 22,
                                  salePrice: 16,
                                  imageUrl: '',
                                  category: 1,
                                  brand: 1,
                                  type: 'simple',
                                  isFeatured: false,
                                  inStock: true,
                                  sku: 'TOMATO002',
                                  published: true,
                                  createdAt: DateTime.now(),
                                  updatedAt: DateTime.now(),
                                  variantIds: [],
                                ),
                                deliveryTime: '9 MINS',
                                name: 'Hybrid Tomato 500 g',
                                weight: '500 g',
                                currentPrice: 16,
                                originalPrice: 22,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
    

  Widget _buildCategoryItem(Map<String, dynamic> category) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedCategory = category['name'];
        });
      },
      child: Container(
        color: _selectedCategory == category['name'] ? Colors.white : Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image placeholder
            Container(
              width: 50,
              height: 50,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                image: const DecorationImage(
                  image: AssetImage('lib/placeholder.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Category name
          Center(
            child: Text(
              category['name'],
              style: TextStyle(
                fontSize: 12,
                fontWeight: _selectedCategory == category['name'] 
                    ? FontWeight.bold 
                    : FontWeight.normal,
                color: _selectedCategory == category['name'] 
                    ? Colors.green[800] 
                    : Colors.black87,
              ),
                
            ),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard({
    required Product product,
    required String? deliveryTime,
    required String? name,
    required String? weight,
    required int currentPrice,
    required int originalPrice,
  }) {
  return Container(
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
              height: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                color: Colors.grey[200], 
              ),
              child: Center(child: Icon(Icons.image, size: 50, color: Colors.grey[400])),
            ),
            // Sale badge
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '25% OFF',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Delivery time badge
            if (deliveryTime != null)
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 94, 93, 93).withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer, size: 12, color: Colors.white),
                      const SizedBox(width: 2),
                      Text(
                        deliveryTime,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ],
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
              if (name != null) ...[
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
              ],
              // Weight
              if (weight != null) ...[
                Text(
                  weight,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 10),
              ],
              // Price and Add button
              Row(
                children: [
                  // Price with strike-through
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rs $currentPrice',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Rs $originalPrice',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Add button
                  GestureDetector(
                    onTap: () {
                      Provider.of<Cart>(context, listen: false).addItem(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.name} added to cart'),
                          duration: const Duration(seconds: 1),
                        ),
                      );

                    },
                    child: Container(
                      width: 40,
                      height: 20,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Center(
                        child: Text(
                          'ADD',
                          style: TextStyle(
                            color: Colors.green,
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
  );
}
}