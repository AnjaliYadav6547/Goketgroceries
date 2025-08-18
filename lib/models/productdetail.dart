import 'package:flutter/material.dart';

class ProductDetail {
  final int id;
  final String name;
  final String? brand;
  final String subtitle;
  final String imageUrl;
  final String description;
  final int categoryId;
  final List<ProductVariation> variations;
  final String sku;
  final String type;
  final bool published;
  final bool isFeatured;
  final bool inStock;
  final double regularPrice;
  final double salePrice;
  final double price;
  final List<Category> categories;
  final List<ProductImage> images;

  ProductDetail({
    required this.id,
    required this.name,
    this.brand,
    required this.subtitle,
    required this.imageUrl,
    required this.description,
    required this.categoryId,
    required this.variations,
    required this.sku,
    required this.type,
    required this.published,
    required this.isFeatured,
    required this.inStock,
    required this.regularPrice,
    required this.salePrice,
    required this.price,
    required this.categories,
    required this.images,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    // Handle both direct product and nested "product" object
    final productData = json['product'] ?? json;
    
    final variants = (productData['variants'] as List?)?.map((v) {
      try {
        return ProductVariation(
          id: v['id'] ?? 0,
          value: v['value'] ?? '',
          price: double.tryParse(v['sale_price']?.toString() ?? v['regular_price']?.toString() ?? '0') ?? 0.0,
          regularPrice: double.tryParse(v['regular_price']?.toString() ?? '0') ?? 0.0,
          salePrice: double.tryParse(v['sale_price']?.toString() ?? '0') ?? 0.0,
          attributeName: v['attribute']?['name'] ?? 'Size',
          visible: v['visible'] ?? true,
          position: v['position'] ?? 0,
        );
      } catch (e) {
        debugPrint('Error parsing variant: $e');
        return ProductVariation.empty(); // Now this will work
      }
    }).toList() ?? [];

    final effectivePrice = variants.isNotEmpty 
        ? variants.first.price 
        : double.tryParse(productData['price']?.toString() ?? '0') ?? 0.0;

    return ProductDetail(
      id: productData['id'] as int? ?? 0,
      name: productData['name'] as String? ?? 'Unnamed Product',
      brand: productData['brand']?.toString(),
      subtitle: productData['subtitle'] as String? ?? '',
      imageUrl: _parseImageUrl(productData),
      description: productData['description'] as String? ?? 'No description available',
      categoryId: (productData['categories'] as List?)?.firstOrNull?['id'] ?? 0,
      variations: variants,
      sku: productData['sku'] as String? ?? '',
      type: productData['type'] as String? ?? 'simple',
      published: productData['published'] as bool? ?? false,
      isFeatured: productData['is_featured'] as bool? ?? false,
      inStock: productData['in_stock'] as bool? ?? false,
      regularPrice: double.tryParse(productData['regular_price']?.toString() ?? '0') ?? 0.0,
      salePrice: double.tryParse(productData['sale_price']?.toString() ?? '0') ?? 0.0,
      price: effectivePrice,
      categories: _parseCategories(productData),
      images: _parseImages(productData),
    );
  }

  static String _parseImageUrl(Map<String, dynamic> json) {
    try {
      // Try direct image fields first
      if (json['image'] is String && json['image'].isNotEmpty) {
        return json['image'];
      }
      if (json['image_url'] is String && json['image_url'].isNotEmpty) {
        return json['image_url'];
      }

      // Try images array
      if (json['images'] is List && json['images'].isNotEmpty) {
        final firstImage = json['images'].first;
        if (firstImage is String) return firstImage;
        if (firstImage is Map) {
          return firstImage['src']?.toString() ?? 
                firstImage['url']?.toString() ?? 
                firstImage['image']?.toString() ?? '';
        }
      }

      return ''; // Default empty if no image found
    } catch (e) {
      debugPrint('Image parsing error: $e');
      return '';
    }
  }

  static List<Category> _parseCategories(Map<String, dynamic> json) {
    try {
      return (json['categories'] as List?)?.map((c) {
        try {
          return Category.fromJson(c);
        } catch (e) {
          debugPrint('Error parsing category: $e');
          return Category(id: 0, name: 'Unknown');
        }
      }).toList() ?? [];
    } catch (e) {
      debugPrint('Error parsing categories: $e');
      return [];
    }
  }

  static List<ProductImage> _parseImages(Map<String, dynamic> json) {
    try {
      return (json['images'] as List?)?.map((i) {
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
          return ProductImage.empty();
        } catch (e) {
          debugPrint('Error parsing image: $e');
          return ProductImage.empty();
        }
      }).toList() ?? [];
    } catch (e) {
      debugPrint('Error parsing images: $e');
      return [];
    }
  }

  // Helper method to get primary category
  Category? get primaryCategory {
    if (categories.isNotEmpty) {
      return categories.firstWhere(
        (c) => c.id == categoryId,
        orElse: () => categories.first,
      );
    }
    return null;
  }

  // Helper method to get display image URL
  String get displayImageUrl {
    if (images.isNotEmpty) {
      return images.first.image;
    }
    return imageUrl;
  }

  // Helper method to check if product is on sale
  bool get isOnSale => salePrice > 0 && salePrice < regularPrice;

  // Helper method to calculate discount percentage
  int get discountPercentage {
    if (!isOnSale) return 0;
    return (100 - (salePrice / regularPrice * 100)).round();
  }
}

class ProductImage {
  final int id;
  final String image;
  final String optimized;
  final String thumbnail;

  ProductImage({
    required this.id,
    required this.image,
    required this.optimized, 
    required this.thumbnail,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'] ?? 0,
      image: json['image'] ?? '',
      optimized: json['optimized'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
    );
  }

  factory ProductImage.empty() => ProductImage(
    id: 0,
    image: '',
    optimized: '',
    thumbnail: '',
  );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'optimized': optimized,
      'thumbnail': thumbnail,
    };
  }

  bool get isValid => image.isNotEmpty;
}

class ProductVariation {
  final int id;
  final String value;
  final double price;
  final double regularPrice;
  final double salePrice;
  final String attributeName;
  final bool visible;
  final int position;

  ProductVariation({
    required this.id,
    required this.value,
    required this.price,
    required this.regularPrice,
    required this.salePrice,
    required this.attributeName,
    required this.visible,
    required this.position,
  });

  // Add this empty factory constructor
  factory ProductVariation.empty() {
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
  
  factory ProductVariation.fromJson(Map<String, dynamic> json) {
    final regularPrice = double.tryParse(json['regular_price']?.toString() ?? '0') ?? 0.0;
    final salePrice = double.tryParse(json['sale_price']?.toString() ?? '0') ?? 0.0;
    
    return ProductVariation(
      id: json['id'] ?? 0,
      value: json['value'] ?? '',
      price: salePrice > 0 ? salePrice : regularPrice,
      regularPrice: regularPrice,
      salePrice: salePrice,
      attributeName: json['attribute']?['name'] ?? 'Size',
      visible: json['visible'] ?? true,
      position: json['position'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'value': value,
      'regular_price': regularPrice.toString(),
      'sale_price': salePrice.toString(),
      'attribute': {
        'name': attributeName,
      },
      'visible': visible,
      'position': position,
    };
  }

  bool get isOnSale => salePrice > 0 && salePrice < regularPrice;

  int get discountPercentage {
    if (!isOnSale) return 0;
    return (100 - (salePrice / regularPrice * 100)).round();
  }
}

class Category {
  final int id;
  final String name;
  final String? slug;
  final int? parent;

  Category({
    required this.id,
    required this.name,
    this.slug,
    this.parent,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug']?.toString(),
      parent: json['parent'] is int ? json['parent'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (slug != null) 'slug': slug,
      if (parent != null) 'parent': parent,
    };
  }

  bool isChildOf(int parentId) => parent == parentId;
}