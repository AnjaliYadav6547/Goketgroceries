import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:flutter_application/models/productdetail.dart';
import '../components/product_tile.dart';
import '../models/product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';


class ProductDetailPage extends StatefulWidget {
  final int productId;
  

  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  //product details state
  late Future<ProductDetail> _productFuture;
  late int _selectedVariationIndex;
  int _quantity = 1;

  //similar product state
  final _similarProductsCache = <int, List<Product>>{};
  bool _similarProductsLoading = false;
  bool _similarProductsInitialized = false;

  @override
  void initState() {
    super.initState();
    _selectedVariationIndex = 0;
    _productFuture = _fetchProductDetails();
  }

  Future<ProductDetail> _fetchProductDetails() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.goket.com.np/products/${widget.productId}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      debugPrint('Product details response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
          debugPrint('API Response: $jsonData');
        
        // Add null check before parsing
        if (jsonData == null) {
          throw Exception('API returned null response');
        }

        final product = ProductDetail.fromJson(jsonData);
        
        setState(() {
          _selectedVariationIndex = product.variations.isNotEmpty ? 0 : -1;
        });
        
        return product;
      } else {
        throw Exception('Failed to load product details: ${response.statusCode}');
      } 
    } catch (e) {
      debugPrint('Error loading product: $e');
      throw Exception('Failed to load product: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<ProductDetail>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Failed to load product details'),
                  Text(
                    '${snapshot.error}'.replaceAll('Exception: ', ''),
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _productFuture = _fetchProductDetails();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No product data available'));
          }

          final product = snapshot.data!;
          return _buildProductContent(product);
        },
      ),
    );
  }

  Widget _buildProductContent(ProductDetail product) {
    final primaryImageUrl = product.images.isNotEmpty 
        ? product.images[0].image
        : '';

    final isSimpleProduct = product.variations.isEmpty;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Container(
                  height: 250,
                  color: Colors.grey[100],
                  alignment: Alignment.center,
                  child: primaryImageUrl.isNotEmpty
                      ? Image.network(
                          primaryImageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => _buildPlaceholderWidget(),
                        )
                      : _buildPlaceholderWidget(),
                ),

                // Price for simple product
                if (isSimpleProduct) Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Rs ${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),

                // Product Info
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Stock Status
                      Row(
                        children: [
                          Icon(
                            product.inStock ? Icons.check_circle : Icons.cancel,
                            color: product.inStock ? Colors.green : Colors.red,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            product.inStock ? 'In Stock' : 'Out of Stock',
                            style: TextStyle(
                              color: product.inStock ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Variations Section
                      if (!isSimpleProduct) ...[
                        const Text(
                          'Select Unit',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 100,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: product.variations.map((variation) {
                              final isOnSale = variation.salePrice > 0 && 
                                              variation.salePrice < variation.regularPrice;
                              final discountPercent = isOnSale
                                  ? (100 - (variation.salePrice / variation.regularPrice * 100)).round()
                                  : 0;
                              
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedVariationIndex = product.variations.indexOf(variation);
                                  });
                                },
                                child: Container(
                                  width: 100,
                                  margin: const EdgeInsets.only(right: 12),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _selectedVariationIndex == product.variations.indexOf(variation)
                                        ? Colors.orange.withOpacity(0.1)
                                        : Colors.grey.withOpacity(0.05),
                                    border: Border.all(
                                      color: _selectedVariationIndex == product.variations.indexOf(variation)
                                          ? Colors.orange
                                          : Colors.grey.withOpacity(0.2),
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (isOnSale && discountPercent > 0)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.red[50],
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            '$discountPercent% OFF',
                                            style: TextStyle(
                                              color: Colors.red[800],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                      Text(
                                        variation.value,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            variation.salePrice > 0
                                                ? 'Rs ${variation.salePrice.toStringAsFixed(2)}'
                                                : 'Rs ${variation.regularPrice.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                          if (isOnSale && variation.salePrice > 0)
                                            Text(
                                              'Rs ${variation.regularPrice.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey[600],
                                                decoration: TextDecoration.lineThrough,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // View Full Details
                      GestureDetector(
                        onTap: () => _showProductDetailsDialog(product),
                        child: const Text(
                          'View full product details ▼',
                          style: TextStyle(
                            color: Colors.green,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Similar Products Section
                      _buildSimilarProductsSection(product),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildBottomBar(product),
      ],
    );
  }

  Widget buildVariationSelector(ProductDetail product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Unit',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...product.variations.map((variation) {
          final isOnSale = variation.salePrice < variation.regularPrice;
          final discountPercent = isOnSale
              ? (100 - (variation.salePrice / variation.regularPrice * 100)).round()
              : 0;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedVariationIndex = product.variations.indexOf(variation);
              });
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _selectedVariationIndex == product.variations.indexOf(variation)
                      ? Colors.orange
                      : Colors.grey.withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isOnSale)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '$discountPercent% OFF',
                            style: TextStyle(
                              color: Colors.red[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        variation.value,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Rs ${variation.salePrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        'MRP Rs ${variation.regularPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          decoration: isOnSale 
                              ? TextDecoration.lineThrough 
                              : TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildPlaceholderWidget() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, size: 50, color: Colors.grey[400]),
            SizedBox(height: 8),
            Text('Image not available', 
                style: TextStyle(color: Colors.grey[600])),
            Text('Product ID: ${widget.productId}',
                style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorWidget(dynamic error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 40),
          const SizedBox(height: 8),
          Text(
            'Error loading similar products',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 40, color: Colors.grey),
          SizedBox(height: 8),
          Text('No similar products found'),
        ],
      ),
    );
  }


  Widget _buildSimilarProductsSection(ProductDetail product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Similar Products',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10),
        FutureBuilder<List<Product>>(
          future: _fetchSimilarProducts(product),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('No similar products available'),
              );
            }

            final products = snapshot.data!;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.6,
                mainAxisSpacing: 12,
                crossAxisSpacing: 8,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product image
                      Container(
                        height: 80,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        child: Image.network(
                          product.imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(Icons.shopping_bag, size: 30),
                        ),
                      ),
                      // Product details
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Rs ${product.currentPrice.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: const Color.fromARGB(255, 47, 48, 47),
                                  ),
                                ),
                                _buildAddButton(
                                  product,
                                  () {
                                    final cart = Provider.of<CartProvider>(context, listen: false);
                                    cart.addItem(
                                      productId: product.id,
                                      variationId: product.variations.isNotEmpty 
                                          ? product.variations.first.id 
                                          : 0,
                                      name: product.name,
                                      price: product.currentPrice,
                                      quantity: 1,
                                      imageUrl: product.imageUrl,
                                      size: product.variations.isNotEmpty
                                          ? product.variations.first.value
                                          : '',
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildAddButton(Product product, VoidCallback onAddToCart) {
    return InkWell(
      onTap: product.inStock ? onAddToCart : null,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 40,
        height: 25,
        decoration: BoxDecoration(
          border: Border.all(
            color: product.inStock ? Colors.green : Colors.grey,
            width: 1.0,
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
    );
  }

  Future<List<Product>> _fetchSimilarProducts(ProductDetail product) async {
    try {
      debugPrint('Fetching similar products for product ${product.id}');
      
      // First try to get recommendations from the product detail response
      final productResponse = await http.get(
        Uri.parse('https://api.goket.com.np/products/${product.id}'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (productResponse.statusCode == 200) {
        final jsonData = jsonDecode(productResponse.body);
        debugPrint('Product detail response: ${productResponse.body}');

        // Try different possible keys for recommendations
        List<dynamic> recommendations = [];
        if (jsonData['recommendations'] != null) {
          recommendations = jsonData['recommendations'] as List;
        } else if (jsonData['related'] != null) {
          recommendations = jsonData['related'] as List;
        } else if (jsonData['similar'] != null) {
          recommendations = jsonData['similar'] as List;
        }

        debugPrint('Found ${recommendations.length} recommendations');

        // recommendation
        if (recommendations.isNotEmpty) {
          return recommendations
              .map((rec) => Product.fromJson(rec))
              .where((p) => p.id != product.id)
              .toList();
        }

        // Get products from the same category
        if (product.categories.isNotEmpty) {
          debugPrint('No recommendations found, falling back to category products');
          final categoryId = product.categories.first.id;
          final categoryResponse = await http.get(
            Uri.parse('https://api.goket.com.np/products?category=$categoryId'),
            headers: {'Accept': 'application/json'},
          ).timeout(const Duration(seconds: 10));

          if (categoryResponse.statusCode == 200) {
            final categoryData = jsonDecode(categoryResponse.body);
            final products = (categoryData['data'] as List?)
                ?.map((p) => Product.fromJson(p))
                .where((p) => p.id != product.id)
                .toList() ?? [];

            debugPrint('Found ${products.length} products in same category');
            return products;
          }
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error in _fetchSimilarProducts: $e');
      return [];
    }
  }


  Widget _buildSimilarProductItem(Product product) {
    return ProductTile(
      product: product, // Directly use the Product if models match
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(productId: product.id),
          ),
        );
      },
      onAddToCart: () {
        final cart = Provider.of<CartProvider>(context, listen: false);
        if (product.variations.isNotEmpty) {
          // For variable products, navigate to detail page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailPage(productId: product.id),
            ),
          );
        } else {
          // For simple products, add directly to cart
          cart.addItem(
            productId: product.id,
            variationId: 0,
            name: product.name,
            price: product.currentPrice,
            quantity: 1,
            imageUrl: product.imageUrl,
            size: '',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${product.name} added to cart'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
    );
  }
  

  Widget _buildBottomBar(ProductDetail product) {
    final hasVariations = product.variations.isNotEmpty;
    final canAddToCart = hasVariations && 
                       _selectedVariationIndex >= 0 && 
                       _selectedVariationIndex < product.variations.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Quantity Selector
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 20),
                  onPressed: () => setState(() => _quantity = _quantity > 1 ? _quantity - 1 : 1),
                ),
                Text(_quantity.toString(), style: const TextStyle(fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  onPressed: () => setState(() => _quantity++),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Add to cart button
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: canAddToCart ? Colors.orange : Colors.grey,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: canAddToCart ? () {
                _addToCart(
                  context,
                  product,
                  product.variations[_selectedVariationIndex],
                  _quantity
                );
              } : null,
              child: Text(
                canAddToCart 
                    ? 'Add to cart - Rs${(product.variations[_selectedVariationIndex].price * _quantity).toStringAsFixed(2)}'
                    : 'Unavailable',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }


  void _showProductDetailsDialog(ProductDetail product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Product Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text('SKU: ${product.sku}'),
              const SizedBox(height: 8),
              Text('Type: ${product.type}'),
              const SizedBox(height: 8),
              Text('Published: ${product.published ? 'Yes' : 'No'}'),
              const SizedBox(height: 8),
              Text('Featured: ${product.isFeatured ? 'Yes' : 'No'}'),
              const SizedBox(height: 8),
              Text('In Stock: ${product.inStock ? 'Yes' : 'No'}'), 
              const SizedBox(height: 8),
              Text('Regular Price: Rs ${product.regularPrice}'),
              const SizedBox(height: 8),
              Text('Sale Price: Rs ${product.salePrice}'),
              const SizedBox(height: 8),
              Text('Current Price: Rs ${product.price.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              if (product.brand != null) Text('Brand: ${product.brand}'),
              const SizedBox(height: 8),
              const Text('Categories:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...product.categories.map((c) => Text('- ${c.name}')).toList(), 
              const SizedBox(height: 8),
              const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(product.description),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _addToCart(
    BuildContext context,
    ProductDetail product,
    ProductVariation variation,
    int quantity,
  ) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    cart.addItem(
      productId: product.id,
      variationId: variation.id,
      name: product.name,
      price: variation.price,
      quantity: quantity,
      imageUrl: product.imageUrl,
      size: variation.value,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} (${variation.value}) added to cart'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// cartprovider 
class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => _items.fold(0, (sum, item) => sum + (item.price * item.quantity));

  void addItem({
    required int productId,
    required int variationId,
    required String name,
    required double price,
    required int quantity,
    required String imageUrl,
    required String size,
  }) {
    final existingIndex = _items.indexWhere((item) => 
        item.productId == productId && item.variationId == variationId);
    
    if (existingIndex >= 0) {
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + quantity,
      );
    } else {
      _items.add(CartItem(
        productId: productId,
        variationId: variationId,
        name: name,
        price: price,
        quantity: quantity,
        imageUrl: imageUrl,
        size: size,
      ));
    }
    notifyListeners();
  }

  void removeItem(int productId, int variationId) {
    _items.removeWhere((item) => 
        item.productId == productId && item.variationId == variationId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}

class CartItem {
  final int productId;
  final int variationId;
  final String name;
  final double price;
  final int quantity;
  final String imageUrl;
  final String size;

  CartItem({
    required this.productId,
    required this.variationId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    required this.size,
  });

  CartItem copyWith({
    int? productId,
    int? variationId,
    String? name,
    double? price,
    int? quantity,
    String? imageUrl,
    String? size,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      variationId: variationId ?? this.variationId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      size: size ?? this.size,
    );
  }
}