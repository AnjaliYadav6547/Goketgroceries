import 'package:flutter_application/models/product.dart';

class Category {
  final String id;
  final String name;
  final List<SubCategory> subCategories;

  Category({
    required this.id,
    required this.name,
    required this.subCategories,
  });
}

class SubCategory {
  final String id;
  final String name;
  final List<Product> products;

  SubCategory({
    required this.id,
    required this.name,
    required this.products,
  });
}