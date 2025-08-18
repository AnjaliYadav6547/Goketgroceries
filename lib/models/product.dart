import 'package:flutter/material.dart';
import 'productdetail.dart';

class Product {
  final int id;
  final String name;
  final int category;
  final int brand;
  final String type;
  final bool isFeatured;
  final bool inStock;
  final double regularPrice;
  final double? salePrice;
  final String? sku;
  final bool published;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String imageUrl;
  final List<String> variantIds;
  final List<ProductVariation> variations;
  final List<Category> categories;
  final List<ProductImage> images;

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
    this.variations = const [],
    this.categories = const [],
    this.images = const [],
  });

  double get currentPrice => salePrice ?? regularPrice;
  bool get isOnSale => salePrice != null;
  int get salePercentage => isOnSale 
      ? (100 - (salePrice! / regularPrice * 100)).round() 
      : 0;

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
      'variations': variations.map((v) => v.toJson()).toList(),
      'categories': categories.map((c) => c.toJson()).toList(),
      'images': images.map((i) => i.toJson()).toList(),
    };
  }

  factory Product.fromMap(Map<String, dynamic>? map) {
    if (map == null) return Product.empty();

    String parseImageUrl(Map<String, dynamic> data) {
      try {
        if (data['images'] is List && data['images'].isNotEmpty) {
          final firstImage = data['images'].first;
          if (firstImage is String) return firstImage;
          if (firstImage is Map) {
            return firstImage['image']?.toString() ?? 
                  firstImage['url']?.toString() ?? 
                  firstImage['src']?.toString() ?? '';
          }
        }
        return data['image_url']?.toString() ?? 
              data['image']?.toString() ?? 
              '';
      } catch (e) {
        debugPrint('Image parsing error: $e');
        return '';
      }
    }

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
        if (salePrice == 0.0) salePrice = null;
      } else if (salePriceValue is num) {
        salePrice = salePriceValue.toDouble();
        if (salePrice == 0) salePrice = null;
      }
    }

    return Product(
      id: int.tryParse(map['id']?.toString() ?? '0') ?? 0,
      name: map['name']?.toString() ?? 'Unnamed Product',
      category: (map['category'] is int) ? map['category'] 
              : (map['category'] is Map) ? map['category']['id'] ?? 0 : 0,
      brand: (map['brand'] is int) ? map['brand'] 
            : (map['brand'] is Map) ? map['brand']['id'] ?? 0 : 0,
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
      variantIds: (map['variants'] as List?)?.map((v) => v['id'].toString()).toList() ?? [],
      variations: (map['variants'] as List?)?.map((v) {
        try {
          return ProductVariation.fromJson(v);
        } catch (e) {
          debugPrint('Error parsing variation: $e');
          return ProductVariation(
            id: 0,
            value: 'Unknown',
            price: 0.0,
            regularPrice: 0.0,
            salePrice: 0.0,
            attributeName: 'Size',
            visible: true,
            position: 0,
          );
        }
      }).toList() ?? [],
      categories: (map['categories'] as List?)?.map((c) {
        try {
          return Category.fromJson(c);
        } catch (e) {
          debugPrint('Error parsing category: $e');
          return Category(id: 0, name: 'Unknown');
        }
      }).toList() ?? [],
      images: (map['images'] as List?)?.map((i) {
        try {
          if (i is String) {
            return ProductImage(
              id: 0,
              image: i,
              optimized: i,
              thumbnail: i,
            );
          } else if (i is Map<String, dynamic>) {
            return ProductImage.fromJson(i);
          }
          return ProductImage(
            id: 0,
            image: '',
            optimized: '',
            thumbnail: '',
          );
        } catch (e) {
          debugPrint('Error parsing image: $e');
          return ProductImage(
            id: 0,
            image: '',
            optimized: '',
            thumbnail: '',
          );
        }
      }).toList() ?? [],
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) => Product.fromMap(json);

  static Product empty() => Product(
    id: 0,
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
    variations: [],
    categories: [],
    images: [],
  );

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
    if (categoryId != null && !categories.any((c) => c.id == categoryId)) {
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

  // Helper method to get the first available image URL
  String get displayImageUrl {
    if (images.isNotEmpty) {
      return images.first.image;
    }
    return imageUrl;
  }

  // Helper method to get the display price (considers variations)
  double get displayPrice {
    if (variations.isNotEmpty) {
      return variations.first.price;
    }
    return currentPrice;
  }

  // Helper method to get the display variation value if exists
  String? get displayVariation {
    if (variations.isNotEmpty) {
      return variations.first.value;
    }
    return null;
  }
}

extension CategoryExtension on Category {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
       
    };
  }
}

extension ProductImageExtension on ProductImage {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'optimized': optimized,
      'thumbnail': thumbnail,
    };
  }
}