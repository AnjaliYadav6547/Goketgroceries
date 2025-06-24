import 'package:flutter/material.dart';
import '../components/bottom_nav_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'shop_page.dart';
import 'cart_page.dart';
import 'auth_page.dart';
import 'product_page.dart';
import '../models/product.dart'; // Make sure to import your Product model

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Product> cartItems = []; // Initialize cart items list
  List<Product> products = []; // Initialize products list

  // Method to add product to cart
  void _addToCart(Product product) {
    setState(() {
      cartItems.add(product);
    });
  }

  @override
  void initState() {
    super.initState();
    // Initialize your products here
    products = [
      // Add your products here
      Product(
        id: '1',
        name: 'Product 1',
        price: 10.99,
        imageUrl: 'product1.jpg',
        category: 'GROCERY & KITCHEN',
        sku: 'SKU001',
        inStock: true,
      ),
      // Add more products as needed
    ];
  }

  void navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Create pages list in build method to access current state
    final List<Widget> _pages = [
      const ShopPage(),
      const CartPage(),
      ProductPage(
        initialProducts: products,
        cartItems: cartItems,
        onAddToCart: _addToCart,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[300],
      bottomNavigationBar: MyBottomNavBar(
        onTabChange: (index) => navigateBottomBar(index),
      ),
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Padding(
              padding: EdgeInsets.only(left: 12.0),
              child: Icon(
                Icons.menu,
                color: Colors.black,
              ),
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.grey[900],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                DrawerHeader(
                  child: Image.asset(
                    'lib/images/nike.png',
                    color: Colors.black,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Divider(
                    color: Colors.grey[800],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 25.0),
                  child: ListTile(
                    leading: Icon(
                      Icons.home,
                      color: Colors.white,
                    ),
                    title: Text(
                      'Home',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 25.0),
                  child: ListTile(
                    leading: Icon(
                      Icons.info,
                      color: Colors.white,
                    ),
                    title: Text(
                      'About',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0, bottom: 25),
                  child: ListTile(
                    leading: const Icon(
                      Icons.logout,
                      color: Colors.white,
                    ),
                    title: const Text(
                      'logout',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const AuthPage()),
                      );
                    },
                  ),
                )
              ],
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}