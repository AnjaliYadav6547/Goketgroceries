import 'package:flutter/material.dart';
import 'package:flutter_application/models/product.dart';
import '../models/category.dart';
import 'package:provider/provider.dart';
import '../models/cart.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with delivery info
            _buildHeaderSection(),
            
            // Search Bar
            _buildSearchBar(),
            
            // Shop by Category
            _buildCategorySection(context),
            
            // Shop by Store
            _buildStoreSection(),
            
            // Hot Deals
            _buildHotDealsSection(context),
            
            // Daily Fresh Needs
            _buildDailyFreshSection(context),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery in 15 minutes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Buddhanagar, Kathmandu, Nepal',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search groceries...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context) {
    final categories = [
      {'name': 'Vegetables & Fruits', 'image': 'assets/categories/vegetables.png'},
      {'name': 'Dairy & Breakfast', 'image': 'assets/categories/dairy.png'},
      {'name': 'Munchies', 'image': 'assets/categories/snacks.png'},
      {'name': 'Home & Office', 'image': 'assets/categories/home.png'},
      {'name': 'Personal Care', 'image': 'assets/categories/personal_care.png'},
      {'name': 'Pet Care', 'image': 'assets/categories/pet_care.png'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Shop by category',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.9,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return _buildCategoryItem(
              context,
              categories[index]['name'] as String,
              categories[index]['image'] as String,
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCategoryItem(BuildContext context, String name, String imagePath) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/subcategory',
          arguments: Category(
            id: name.toLowerCase().replaceAll(' ', '_'),
            name: name, subCategories: [],
          ),
        );
      },
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildStoreSection() {
    final stores = [
      {'name': 'Pet Store', 'image': 'assets/stores/pet_store.png'},
      {'name': 'Stationery', 'image': 'assets/stores/stationery.png'},
      {'name': 'Kids Store', 'image': 'assets/stores/kids.png'},
      {'name': 'Pharmacy', 'image': 'assets/stores/pharmacy.png'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Shop by store',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: stores.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: AssetImage(stores[index]['image'] as String),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stores[index]['name'] as String,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildHotDealsSection(BuildContext context) {
    final hotDeals = [
      Product(
        id: '1',
        name: 'Whole Farm Grocery Sugar',
        category: 1, // Grocery
        brand: 1, // Whole Farm
        type: 'simple',
        isFeatured: true,
        inStock: true,
        regularPrice: 75,
        salePrice: 53,
        sku: 'SUGAR001',
        published: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
        imageUrl: 'assets/products/sugar.png',
        variantIds: [],
      ),
      Product(
        id: '2',
        name: 'Catch Cumin Seeds',
        category: 2, // Spices
        brand: 2, // Catch
        type: 'simple',
        isFeatured: true,
        inStock: true,
        regularPrice: 65,
        salePrice: 38,
        sku: 'CUMIN001',
        published: true,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
        imageUrl: 'assets/products/cumin.png',
        variantIds: [],
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Hot deals',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: hotDeals.length,
            itemBuilder: (context, index) {
              return Container(
                width: 160,
                margin: EdgeInsets.only(
                  right: index == hotDeals.length - 1 ? 0 : 16,
                ),
                child: _buildProductCard(hotDeals[index], context),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDailyFreshSection(BuildContext context) {
    final dailyItems = [
      Product(
        id: '3',
        name: 'Fresh Tomatoes',
        category: 3, // Vegetables
        brand: 3, // Farm Fresh
        type: 'simple',
        isFeatured: false,
        inStock: true,
        regularPrice: 32,
        salePrice: 25,
        sku: 'TOMATO001',
        published: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now(),
        imageUrl: 'assets/products/tomato.png',
        variantIds: [],
      ),
      Product(
        id: '4',
        name: 'Bitter Gourd',
        category: 3, // Vegetables
        brand: 3, // Farm Fresh
        type: 'simple',
        isFeatured: false,
        inStock: true,
        regularPrice: 45,
        salePrice: 30,
        sku: 'GOURD001',
        published: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now(),
        imageUrl: 'assets/products/gourd.png',
        variantIds: [],
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Daily fresh needs',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: dailyItems.length,
          itemBuilder: (context, index) {
            return _buildProductCard(dailyItems[index], context);
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildProductCard(Product product, BuildContext context) {
    final cart = Provider.of<Cart>(context, listen: false);

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
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8)),
                  image: DecorationImage(
                    image: AssetImage(product.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              if (product.isOnSale)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red[600],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${product.salePercentage}% OFF',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
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
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Price and Add button
                Row(
                  children: [
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
                            'Rs${product.regularPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 12,
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
                        cart.addItem(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.name} added to cart'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Container(
                        width: 60,
                        height: 30,
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