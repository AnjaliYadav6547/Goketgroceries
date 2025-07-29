import 'dart:math';

import 'package:flutter/material.dart';
import '../components/product_tile.dart';
import '../components/my_button.dart';
import '../components/my_textfield.dart';
import '../models/product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

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
  late List<Product> _products = [];
  String _searchQuery = '';
  int? _selectedCategoryId;
  int? _selectedBrandId;
  String? _selectedType;
  bool? _featuredOnly;
  bool? _inStockOnly;
  double? _minPrice;
  double? _maxPrice;

  Map<int, String> _categories = {};
  Map<int, String> _brands = {};
  bool _isLoading = false;
  String? _error;
  Timer? _searchDebounce;

  //pagination variables
  int _currentPage = 1;
  int _totalPages = 1;
  final int _perPage = 50; 
  bool _hasNextPage = false;
  bool _hasPrevPage = false;
  int _totalProducts = 0;
  String? _nextPageUrl;
  String? _prevPageUrl;


  Future<List<Product>> fetchProducts() async {
    try {
      final params = <String, String>{
        'page': _currentPage.toString(),
        'per_size': _perPage.toString(),

      };
      if (_searchQuery.isNotEmpty) params['search'] = _searchQuery;
      if (_selectedCategoryId != null) params['category'] = _selectedCategoryId.toString();
      if (_selectedBrandId != null) params['brand'] = _selectedBrandId.toString();
      if (_selectedType != null) params['type'] = _selectedType!;
      if (_featuredOnly != null) params['featured'] = _featuredOnly.toString();
      if (_inStockOnly != null) params['in_stock'] = _inStockOnly.toString();
      if (_minPrice != null) params['min_price'] = _minPrice!.toStringAsFixed(2);
      if (_maxPrice != null) params['max_price'] = _maxPrice!.toStringAsFixed(2);

      final response = await http.get(
        Uri.parse('https://api.goket.com.np/products')
          .replace(queryParameters: params),

        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        
        // Update pagination state (DON'T call setState here)
        _currentPage = decoded['current_page'] ?? 1;
        _totalProducts = decoded['count'] ?? 0;
        _totalPages = decoded['total_pages'] ?? 1;
        _nextPageUrl = decoded['links']['next'];
        _prevPageUrl = decoded['links']['previous'];
        _hasNextPage = _nextPageUrl != null;
        _hasPrevPage = _prevPageUrl != null;

        debugPrint('Pagination: Page $_currentPage/$_totalPages');
        
        if (decoded['data'] is List) {
          return (decoded['data'] as List).map((json) => Product.fromMap(json)).toList();
        }
        throw Exception("Unexpected data format");
      } else {
        throw Exception("Failed to load products: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint('Fetch products error: $e');
      throw Exception("Failed to load products");
    }
  }

  Future<List<Category>> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.goket.com.np/categories/'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load categories: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Categories error: ${e.toString()}");
    }
  }

  Future<List<Brand>> fetchBrands() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.goket.com.np/brands/'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((json) => Brand.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load brands: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Brands error: ${e.toString()}");
    }
  }
  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final products = await fetchProducts();
      setState(() {
        _products = products;
        
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load products: ${e.toString()}';
        _hasNextPage = false;
        _hasPrevPage = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _goToPage(int page) async {
    if (page < 1 || page > _totalPages || page == _currentPage) return;
    
    setState(() {
      _currentPage = page;
      _isLoading = true; // Show loading indicator
    });

    try {
      await _fetchProducts(); // Make sure this is awaited
    } catch (e) {
      setState(() {
        _error = 'Failed to load page: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _goToPrevPage() => _goToPage(_currentPage - 1);
  void _goToNextPage() => _goToPage(_currentPage + 1);


  
  void _searchProducts(String query) {
    if (_searchDebounce?.isActive ?? false) _searchDebounce?.cancel();
    
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query;
      });
      _fetchProducts();
    });
  }

  void _toggleFeaturedFilter() {
    setState(() {
      _featuredOnly = _featuredOnly == null ? true : !_featuredOnly!;
    });
    _fetchProducts();
  }

  void _toggleInStockFilter() {
    setState(() {
      _inStockOnly = _inStockOnly == null ? true : !_inStockOnly!;
    });
    _fetchProducts();
  }

  void _filterByCategory(int? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });
    _fetchProducts();
  }

  void _filterByBrand(int? brandId) {
    setState(() {
      _selectedBrandId = brandId;
    });
    _fetchProducts();
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        fetchCategories(),
        fetchBrands(),
        fetchProducts(),
      ]);
      
      final categories = results[0] as List<Category>;
      final brands = results[1] as List<Brand>;
      final products = results[2] as List<Product>;

      setState(() {
        _categories = {for (var c in categories) c.id: c.name};
        _brands = {for (var b in brands) b.id: b.name};
        _products = products;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load data: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadInitialData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
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
          _buildFilterChips(),

          // Product count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Showing ${_products.length} products',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 8),
          
          _products.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('No products found'),
                  ),
                )
              : _buildProductGrid(),
              // Add pagination controls here
               if (_products.isNotEmpty) _buildPaginationControls(),

              
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          FilterChip(
            label: const Text('Featured'),
            selected: _featuredOnly ?? false,
            onSelected: (_) => _toggleFeaturedFilter(),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('In Stock'),
            selected: _inStockOnly ?? false,
            onSelected: (_) => _toggleInStockFilter(),
          ),
          const SizedBox(width: 8),
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
    );
  }

  Widget _buildProductGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return ProductTile(
          product: product,
          onAddToCart: () {
            widget.onAddToCart(product);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${product.name} added to cart'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          onTap: () {
            // Handle product detail view
          },
        );
      },
    );
  }

  void _showAdvancedFilters() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Advanced Filters'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  

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
                  _fetchProducts();
                },
                child: const Text('Reset'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _fetchProducts();
                },
                child: const Text('Apply'),
              ),
            ],
          );
        },
      ),
    );
  }

  double _calculateMaxPrice() {
    if (_products.isEmpty) return 100; // Default max if no products
    return _products.map((p) => p.currentPrice).reduce((a, b) => a > b ? a : b);
  }
  
  Widget _buildPaginationControls() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous Button
          ElevatedButton(
            onPressed: _hasPrevPage ? _goToPrevPage : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _hasPrevPage ? Colors.green : Colors.grey,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              side: BorderSide(
                color: _hasPrevPage ? Colors.green : Colors.grey,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Previous'),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Page $_currentPage of $_totalPages',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
          
          // Next Button
          ElevatedButton(
            onPressed: _hasNextPage ? _goToNextPage : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _hasNextPage ? Colors.green : Colors.grey,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              side: BorderSide(
                color: _hasNextPage ? Colors.green : Colors.grey,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }

  // // Navigation methods - add these to your _ProductPageState class
  // void _goToPage(int page) {
  //   if (page >= 1 && page <= _totalPages && page != _currentPage) {
  //     setState(() {
  //       _currentPage = page;
  //     });
  //     _fetchProducts();
  //   }
  // }

  // void _goToPrevPage() => _goToPage(_currentPage - 1);
  // void _goToNextPage() => _goToPage(_currentPage + 1);

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
             (product.sku?.toLowerCase().contains(query.toLowerCase()) ?? false
             );
    }).toList();

    return _buildSearchResults(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }

  Widget _buildSearchResults(List<Product> results) {
    if (results.isEmpty) {
      return const Center(child: Text('No products found'));
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final product = results[index];
        return ListTile(
          leading: product.imageUrl.isNotEmpty
              ? Image.network(
                  product.imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => 
                    const Icon(Icons.image_not_supported),
                )
              : const Icon(Icons.image_not_supported),
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

class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Brand {
  final int id;
  final String name;

  Brand({required this.id, required this.name});

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'],
      name: json['name'],
    );
  }
}

