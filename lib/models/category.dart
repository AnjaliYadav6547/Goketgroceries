// category.dart
import 'package:flutter_application/models/product.dart';

class Category {
  final String id;
  final String name;
  final String? parentId; // Add parent category reference
  final List<SubCategory> subCategories;
  final List<Product> products; // Products directly in this category

  Category({
    required this.id,
    required this.name,
    this.parentId,
    this.subCategories = const [],
    this.products = const [],
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unnamed Category',
      parentId: json['parent_id']?.toString(),
      subCategories: (json['subcategories'] as List?)?.map((sub) => SubCategory.fromJson(sub)).toList() ?? [],
      products: (json['products'] as List?)?.map((p) => Product.fromJson(p)).toList() ?? [],
    );
  }
}

class SubCategory {
  final String id;
  final String name;
  final List<Product> products;

  SubCategory({
    required this.id,
    required this.name,
    this.products = const [],
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unnamed Subcategory',
      products: (json['products'] as List?)?.map((p) => Product.fromJson(p)).toList() ?? [],
    );
  }
}