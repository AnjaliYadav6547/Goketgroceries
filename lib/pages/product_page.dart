import 'package:flutter/material.dart';
import '../components/product_tile.dart';
import '../components/my_button.dart';
import '../components/my_textfield.dart';
import '../models/product.dart';

// Sample product data matching API structure
final List<Product> sampleProducts = [
  Product(
    id: '1',
    name: 'Organic Apples',
    category: 1, // Grocery & Kitchen category ID
    brand: 1, // Fresh Farms brand ID
    type: 'simple',
    isFeatured: true,
    inStock: true,
    regularPrice: 3.99,
    salePrice: 2.99,
    sku: 'APPLE001',
    published: true,
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    updatedAt: DateTime.now(),
    imageUrl: 'assets/fruits/apples.jpg',
    variantIds: [],
  ),
  Product(
    id: '2',
    name: 'Whole Grain Bread',
    category: 1, // Grocery & Kitchen category ID
    brand: 2, // Bakery Delight brand ID
    type: 'simple',
    isFeatured: false,
    inStock: true,
    regularPrice: 4.25,
    salePrice: 3.49,
    sku: 'BREAD001',
    published: true,
    createdAt: DateTime.now().subtract(const Duration(days: 15)),
    updatedAt: DateTime.now(),
    imageUrl: 'assets/bakery/bread.jpg',
    variantIds: [],
  ),
  Product(
    id: '3',
    name: 'Almond Milk',
    category: 2, // Snacks & Drink category ID
    brand: 3, // Nutty Goodness brand ID
    type: 'simple',
    isFeatured: true,
    inStock: true,
    regularPrice: 4.99,
    salePrice: null,
    sku: 'MILK001',
    published: true,
    createdAt: DateTime.now().subtract(const Duration(days: 10)),
    updatedAt: DateTime.now(),
    imageUrl: 'assets/drinks/almond_milk.jpg',
    variantIds: [],
  ),
  Product(
    id: '4',
    name: 'Dark Chocolate',
    category: 2, // Snacks & Drink category ID
    brand: 4, // Cocoa Delight brand ID
    type: 'variation',
    isFeatured: false,
    inStock: false,
    regularPrice: 7.50,
    salePrice: 5.99,
    sku: 'CHOC001',
    published: true,
    createdAt: DateTime.now().subtract(const Duration(days: 60)),
    updatedAt: DateTime.now(),
    imageUrl: 'assets/snacks/chocolate.jpg',
    variantIds: ['4a', '4b'],
  ),
];

class ProductPage extends StatefulWidget {
  final List<Product> cartItems;
  final Function(Product) onAddToCart;

  const ProductPage({
    super.key,
    required this.cartItems,
    required this.onAddToCart,
  });

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late List<Product> _products;
  String _searchQuery = '';
  int? _selectedCategoryId;
  int? _selectedBrandId;
  String? _selectedType;
  bool? _featuredOnly;
  bool? _inStockOnly;
  double? _minPrice;
  double? _maxPrice;

  final Map<int, String> _categories = {
    1: 'GROCERY & KITCHEN',
    2: 'SNACKS & DRINK',
  };

  final Map<int, String> _brands = {
    1: 'Fresh Farms',
    2: 'Bakery Delight',
    3: 'Nutty Goodness',
    4: 'Cocoa Delight',
  };

  @override
  void initState() {
    super.initState();
    _products = sampleProducts;
  }

  void _filterByCategory(int? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
      _selectedBrandId = null; // Reset brand filter when category changes
    });
  }

  void _filterByBrand(int? brandId) {
    setState(() {
      _selectedBrandId = brandId;
    });
  }

  void _searchProducts(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _toggleFeaturedFilter() {
    setState(() {
      _featuredOnly = _featuredOnly == null ? true : !_featuredOnly!;
    });
  }

  void _toggleInStockFilter() {
    setState(() {
      _inStockOnly = _inStockOnly == null ? true : !_inStockOnly!;
    });
  }

  List<Product> get _filteredProducts {
    return _products.where((product) {
      // Search filter
      final matchesSearch = _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase());

      // API parameter filters
      final matchesCategory = _selectedCategoryId == null || 
          product.category == _selectedCategoryId;
      
      final matchesBrand = _selectedBrandId == null || 
          product.brand == _selectedBrandId;
      
      final matchesType = _selectedType == null || 
          product.type == _selectedType;
      
      final matchesFeatured = _featuredOnly == null || 
          product.isFeatured == _featuredOnly;
      
      final matchesStock = _inStockOnly == null || 
          product.inStock == _inStockOnly;
      
      final price = product.currentPrice;
      final matchesPrice = (_minPrice == null || price >= _minPrice!) &&
          (_maxPrice == null || price <= _maxPrice!);

      return matchesSearch && 
          matchesCategory && 
          matchesBrand && 
          matchesType && 
          matchesFeatured && 
          matchesStock && 
          matchesPrice;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ProductSearchDelegate(products: _products),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _showAdvancedFilters,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: MyTextfield(
                hintText: 'Search for products...',
                obscureText: false,
                onChanged: _searchProducts,
              ),
            ),

            // Quick filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  // Featured filter
                  FilterChip(
                    label: const Text('Featured'),
                    selected: _featuredOnly ?? false,
                    onSelected: (_) => _toggleFeaturedFilter(),
                  ),
                  const SizedBox(width: 8),
                  
                  // In Stock filter
                  FilterChip(
                    label: const Text('In Stock'),
                    selected: _inStockOnly ?? false,
                    onSelected: (_) => _toggleInStockFilter(),
                  ),
                  const SizedBox(width: 8),
                  
                  // Category filters
                  ..._categories.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(entry.value),
                        selected: _selectedCategoryId == entry.key,
                        onSelected: (_) => _filterByCategory(
                          _selectedCategoryId == entry.key ? null : entry.key
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Product grid
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Showing ${_filteredProducts.length} products',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),
            
            if (_filteredProducts.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('No products found'),
                ),
              )
            else
              GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _filteredProducts.length,
                itemBuilder: (context, index) {
                  return ProductTile(
                    product: _filteredProducts[index],
                    onAddToCart: () {
                      widget.onAddToCart(_filteredProducts[index]);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${_filteredProducts[index].name} added to cart'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    onTap: () {
                      // Handle product detail view
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showAdvancedFilters() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Advanced Filters'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Price range filter
              const Text('Price Range'),
              RangeSlider(
                values: RangeValues(
                  _minPrice ?? 0,
                  _maxPrice ?? _products.fold(0, (max, p) => 
                    p.currentPrice > max ? p.currentPrice : max),
                ),
                min: 0,
                max: _products.fold(0, (max, p) => 
                  p.currentPrice > max ? p.currentPrice : max),
                onChanged: (values) {
                  setState(() {
                    _minPrice = values.start;
                    _maxPrice = values.end;
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Min: \$${_minPrice?.toStringAsFixed(2) ?? '0'}'),
                  Text('Max: \$${_maxPrice?.toStringAsFixed(2) ?? 'Any'}'),
                ],
              ),

              const Divider(),
              
              // Product type filter
              const Text('Product Type'),
              DropdownButton<String>(
                value: _selectedType,
                hint: const Text('All Types'),
                items: const [
                  DropdownMenuItem(value: null, child: Text('All Types')),
                  DropdownMenuItem(value: 'simple', child: Text('Simple')),
                  DropdownMenuItem(value: 'variation', child: Text('Variation')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                },
              ),

              const Divider(),
              
              // Brand filter
              const Text('Brand'),
              DropdownButton<int>(
                value: _selectedBrandId,
                hint: const Text('All Brands'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Brands')),
                  ..._brands.entries.map((entry) => 
                    DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedBrandId = value;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedCategoryId = null;
                _selectedBrandId = null;
                _selectedType = null;
                _featuredOnly = null;
                _inStockOnly = null;
                _minPrice = null;
                _maxPrice = null;
              });
              Navigator.pop(context);
            },
            child: const Text('Reset'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}

class ProductSearchDelegate extends SearchDelegate {
  final List<Product> products;

  ProductSearchDelegate({required this.products});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = products.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase()) ||
             product.sku!.toLowerCase().contains(query.toLowerCase()) ?? false;
    }).toList();

    return _buildSearchResults(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }

  Widget _buildSearchResults(List<Product> results) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final product = results[index];
        return ListTile(
          leading: Image.asset(
            product.imageUrl,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
          title: Text(product.name),
          subtitle: Text('\$${product.currentPrice.toStringAsFixed(2)}'),
          trailing: product.isOnSale
              ? Chip(
                  label: Text('${product.salePercentage}% OFF'),
                  backgroundColor: Colors.red,
                  labelStyle: const TextStyle(color: Colors.white),
                )
              : null,
          onTap: () {
            close(context, product);
          },
        );
      },
    );
  }
}