import 'package:flutter/material.dart';
import 'package:flutter_application/models/category.dart';

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
              style: TextStyle(fontSize: 16),
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildProductCard(
                    deliveryTime: '8 MINS',
                    name: 'Onion (Eerulli)',
                    weight: '(0.95-1.05) kg',
                    currentPrice: 27,
                    originalPrice: 96,
                  ),
                  _buildProductCard(
                    deliveryTime: '9 MINS',
                    name: 'Potato (Alugadde)',
                    weight: '(0.95-1.05) kg',
                    currentPrice: 30,
                    originalPrice: 99,
                  ),
                  const Divider(height: 24),
                  _buildProductCard(
                    deliveryTime: null,
                    name: null,
                    weight: null,
                    currentPrice: 31,
                    originalPrice: 94,
                  ),
                  const Divider(height: 24),
                  _buildProductCard(
                    deliveryTime: '6 MINS',
                    name: 'Desi Tomato 500 g (Naati Tomato)',
                    weight: '500 g',
                    currentPrice: 14,
                    originalPrice: 19,
                  ),
                  const Divider(height: 24),
                  _buildProductCard(
                    deliveryTime: '9 MINS',
                    name: 'Hybrid Tomato 500 g',
                    weight: '500 g',
                    currentPrice: 16,
                    originalPrice: 22,
                  ),
                ],
              ),
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
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Row(
          children: [
            // Image placeholder
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                image: const DecorationImage(
                  image: AssetImage('assets/placeholder.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Category name
            Expanded(
              child: Text(
                category['name'],
                style: TextStyle(
                  fontSize: 14,
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
    required String? deliveryTime,
    required String? name,
    required String? weight,
    required int currentPrice,
    required int originalPrice,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (deliveryTime != null && name != null && weight != null) ...[
          // Delivery time badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.green),
            ),
            child: Text(
              deliveryTime,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 8),
          
          // Product name
          Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          // Weight
          Text(
            weight,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
        ],
        
        // Price and add button
        Row(
          children: [
            // Price column
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '₹$currentPrice',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '₹$originalPrice',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ),
            const Spacer(),
            
            // Add button
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'ADD',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '2 options',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}