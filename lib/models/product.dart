class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final double? originalPrice;
  final String imageUrl;
  final String sku;
  final bool inStock;
  final int? salePercentage;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    required this.sku,
    this.inStock = true,
    this.salePercentage,
  });

  bool get isOnSale => originalPrice != null;
}