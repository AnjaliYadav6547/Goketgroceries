import 'package:flutter/material.dart';

class Product {
  final String id;
  final String name;
  final int category; // Changed from mainCategory to match API (category ID)
  final int brand; // Changed to brand ID to match API
  final String type; // 'simple' or 'variation'
  final bool isFeatured;
  final bool inStock;
  final double regularPrice;
  final double? salePrice;
  final String? sku;
  final bool published;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String imageUrl; // Assuming this comes from ProductImage relationship
  final List<String> variantIds; // Assuming these come from ProductVariant relationship

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.brand,
    this.type = 'simple',
    this.isFeatured = false,
    this.inStock = true,
    required this.regularPrice,
    this.salePrice,
    this.sku,
    this.published = true,
    required this.createdAt,
    required this.updatedAt,
    required this.imageUrl,
    this.variantIds = const [],
  });

  // Getters
  double get currentPrice => salePrice ?? regularPrice;
  bool get isOnSale => salePrice != null;
  int get salePercentage => isOnSale 
      ? (100 - (salePrice! / regularPrice * 100)).round() 
      : 0;

  // Convert to Map for API/database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'brand': brand,
      'type': type,
      'is_featured': isFeatured,
      'in_stock': inStock,
      'regular_price': regularPrice,
      'sale_price': salePrice,
      'sku': sku,
      'published': published,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'image_url': imageUrl,
      'variant_ids': variantIds,
    };
  }

  // Create Product from API/database Map
  factory Product.fromMap(Map<String, dynamic>? map) {
    if (map == null) return Product.empty();

    // Debug print to see actual API response structure
      // Debug print the entire image-related data
    debugPrint('Image data from API: ${map['image']}');
    debugPrint('Images array from API: ${map['images']}');
    debugPrint('Image URL from API: ${map['image_url']}');

    // Enhanced image URL extraction
    String parseImageUrl(Map<String, dynamic> data) {
      // Debug the entire data structure for images
      debugPrint('Full image data structure: ${data['images']}');
      
      // Check direct image_url field first
      if (data['image_url'] is String && (data['image_url'] as String).isNotEmpty) {
        return data['image_url'];
      }

      // Handle images array - this is the main fix
      if (data['images'] is List && (data['images'] as List).isNotEmpty) {
        final firstImage = (data['images'] as List).first;
        
        if (firstImage is Map) {
          // Check for image_url in the first image object
          if (firstImage['image_url'] is String && 
              (firstImage['image_url'] as String).isNotEmpty) {
            return firstImage['image_url'];
          }
          // Fallback to other common field names
          if (firstImage['url'] is String && (firstImage['url'] as String).isNotEmpty) {
            return firstImage['url'];
          }
          if (firstImage['src'] is String && (firstImage['src'] as String).isNotEmpty) {
            return firstImage['src'];
          }
        }
        
        // Handle case where images array contains direct URLs
        if (firstImage is String && firstImage.isNotEmpty) {
          return firstImage;
        }
      }

      // Fallback to other possible locations
      if (data['image'] is String && (data['image'] as String).isNotEmpty) {
        return data['image'];
      }
      
      if (data['image'] is Map) {
        final imageMap = data['image'] as Map;
        if (imageMap['url'] is String) return imageMap['url'];
        if (imageMap['src'] is String) return imageMap['src'];
      }

      debugPrint('No valid image URL found in product data');
      return ''; // Return empty string if no image found
    }

    // Handle price parsing (some APIs return strings)
    double parsePrice(dynamic price) {
      if (price == null) return 0;
      if (price is num) return price.toDouble();
      if (price is String) {
        return double.tryParse(price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
      }
      return 0;
    }
    dynamic salePriceValue = map['sale_price'];
    double? salePrice;
    
    if (salePriceValue != null) {
      if (salePriceValue is String) {
        salePrice = double.tryParse(salePriceValue);
        // Treat "0.00" as null (no sale)
        if (salePrice == 0.0) salePrice = null;
      } else if (salePriceValue is num) {
        salePrice = salePriceValue.toDouble();
        if (salePrice == 0) salePrice = null;
      }
    }


    return Product(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Unnamed Product',
      category: (map['category'] is int) ? map['category'] : 
              (map['category'] is Map) ? map['category']['id'] ?? 0 : 0,
      brand: (map['brand'] is int) ? map['brand'] : 
            (map['brand'] is Map) ? map['brand']['id'] ?? 0 : 0,
      type: map['type']?.toString() ?? 'simple',
      isFeatured: map['featured'] ?? map['is_featured'] ?? false,
      inStock: map['in_stock'] ?? map['stock_status'] == 'instock' ?? true,
      regularPrice: parsePrice(map['regular_price'] ?? map['price']),
      salePrice: salePrice,
      sku: map['sku']?.toString(),
      published: map['status'] == 'publish' ?? map['published'] ?? true,
      createdAt: DateTime.tryParse(map['date_created'] ?? 
                map['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['date_modified'] ?? 
                map['updated_at'] ?? '') ?? DateTime.now(),
      imageUrl: parseImageUrl(map),
      variantIds: (map['variations'] as List?)?.map((v) => v.toString()).toList() ?? [],
    );
  }

  static Product empty() => Product(
    id: '',
    name: 'Empty Product',
    category: 0,
    brand: 0,
    type: 'simple',
    isFeatured: false,
    inStock: true,
    regularPrice: 0,
    salePrice: null,
    sku: '',
    published: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    imageUrl: 'assets/default.png',
    variantIds: [],
  );

  // For filtering
  bool matchesFilters({
    String? nameQuery,
    int? categoryId,
    int? brandId,
    String? productType,
    bool? featuredOnly,
    bool? inStockOnly,
    double? minPrice,
    double? maxPrice,
  }) {
    if (nameQuery != null && !name.toLowerCase().contains(nameQuery.toLowerCase())) {
      return false;
    }
    if (categoryId != null && category != categoryId) {
      return false;
    }
    if (brandId != null && brand != brandId) {
      return false;
    }
    if (productType != null && type != productType) {
      return false;
    }
    if (featuredOnly == true && !isFeatured) {
      return false;
    }
    if (inStockOnly == true && !inStock) {
      return false;
    }
    final price = currentPrice;
    if (minPrice != null && price < minPrice) {
      return false;
    }
    if (maxPrice != null && price > maxPrice) {
      return false;
    }
    return true;
  }
}