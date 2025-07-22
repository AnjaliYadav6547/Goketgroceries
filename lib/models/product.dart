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
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'].toString(),
      name: map['name'],
      category: map['category'] is int ? map['category'] : int.parse(map['category']),
      brand: map['brand'] is int ? map['brand'] : int.parse(map['brand']),
      type: map['type'] ?? 'simple',
      isFeatured: map['is_featured'] ?? false,
      inStock: map['in_stock'] ?? true,
      regularPrice: map['regular_price']?.toDouble() ?? 0.0,
      salePrice: map['sale_price']?.toDouble(),
      sku: map['sku'],
      published: map['published'] ?? true,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      imageUrl: map['image_url'] ?? '',
      variantIds: List<String>.from(map['variant_ids'] ?? []),
    );
  }

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