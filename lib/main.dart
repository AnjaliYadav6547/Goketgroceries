import 'package:flutter/material.dart';
import 'package:flutter_application/models/userprofile.dart';
import 'package:flutter_application/pages/home_page.dart';
import 'package:flutter_application/pages/product_page.dart';
import 'package:flutter_application/pages/cart_page.dart';
import 'package:flutter_application/pages/profile_page.dart';
import 'package:flutter_application/pages/category_page.dart';
import 'package:flutter_application/models/cart.dart';
import 'package:flutter_application/pages/subcategory_page.dart';
import 'package:provider/provider.dart';
import 'models/category.dart' as models;


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Cart()),
        ChangeNotifierProvider(create: (_) => UserProfile()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const MainWrapper(initialIndex: 0),
        '/home': (context) => const MainWrapper(initialIndex: 0),
        '/categories': (context) => const MainWrapper(initialIndex: 1),
        '/products': (context) => const MainWrapper(initialIndex: 2),
        '/cart': (context) => const MainWrapper(initialIndex: 3),
        '/subcategory': (context) => SubCategoryPage(
              category: ModalRoute.of(context)!.settings.arguments as models.Category,
            ),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}

class MainWrapper extends StatefulWidget {
  final int initialIndex;
  const MainWrapper({super.key, required this.initialIndex});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  final List<Widget> _pages = [
    HomePage(),
    CategoryPage(),
    Consumer<Cart>(
      builder: (context, cart, child) {
        return ProductPage(
        cartItems: cart.items.map((item) => item.product).toList(),
        onAddToCart: (product) {
          cart.addItem(product);
        },
      );
      },
    ),
    Consumer<Cart>(
      builder: (context, cart, child) {
        return const CartPage();
      },
    ),
  ];

  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _navigateBottomBar,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
        ],
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}