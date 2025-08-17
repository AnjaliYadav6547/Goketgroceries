import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/product.dart';
import '../models/category.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loading = true;

  // Parsed from API
  final List<Category> _mainCategories = []; // grouped mains with subs
  final List<Product> _flashDeals = [];

  // Convenience: seeds for placeholder mosaics
  final _rnd = Random();

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    try {
      final catRes =
          await http.get(Uri.parse('https://api.goket.com.np/categories'));
      final prodRes =
          await http.get(Uri.parse('https://api.goket.com.np/products/'));

      // ---- Categories parsing ----
      final catJson = jsonDecode(catRes.body);
      List rawCats = [];
      if (catJson is List) {
        rawCats = catJson;
      } else if (catJson is Map && catJson['data'] is List) {
        rawCats = catJson['data'];
      }

      // Group by main (left of '>'), collect sub (right-most)
      final Map<String, Set<String>> grouped = {};
      for (final c in rawCats) {
        final rawName = (c['name'] ?? '').toString();
        if (rawName.isEmpty) continue;

        final parts = rawName.split('>');
        final main = parts.first.trim();
        final sub = parts.length > 1 ? parts.last.trim() : '';

        // ignore noisy "ALL PRODUCTS" buckets
        if (main.isEmpty || main.toLowerCase().contains('all products')) continue;

        grouped.putIfAbsent(main, () => <String>{});
        if (sub.isNotEmpty && !sub.toLowerCase().contains('all products')) {
          grouped[main]!.add(sub);
        }
      }

      _mainCategories
        ..clear()
        ..addAll(
          grouped.entries.map(
            (e) => Category(
              id: e.key,
              name: e.key,
              subCategories: e.value
                  .map((s) => SubCategory(id: s, name: s, products: const []))
                  .toList()
                ..sort((a, b) => a.name.compareTo(b.name)),
            ),
          ),
        );

      // ---- Products parsing ----
      final prodJson = jsonDecode(prodRes.body);
      List rawProds = [];
      if (prodJson is List) {
        rawProds = prodJson;
      } else if (prodJson is Map && prodJson['data'] is List) {
        rawProds = prodJson['data'];
      }

      final allProducts =
          rawProds.map<Product>((p) => Product.fromMap(p)).toList();

      // Shuffle and take 9-12 items (3 per row)
      allProducts.shuffle(_rnd);
      final takeCount = min(12, max(9, allProducts.length));
      _flashDeals
        ..clear()
        ..addAll(allProducts.take(takeCount));

      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
      debugPrint('Fetch error: $e');
    }
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGradientHeader(context),

                    // Top categories (6) with 2x2 mosaics
                    const SizedBox(height: 12),
                    _buildTopCategoriesMosaics(),

                    // Category sections (about 4)
                    ..._buildMainCategorySections(),

                    // Flash Sale at the end
                    _buildFlashSale(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  // Header with gradient + search bar (rounded)
  Widget _buildGradientHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0C7B4C), // dark green
            Color(0xFF57B88F), // light green
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Goket Groceries',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.white70, Colors.white30],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Search bar with rounded background like design
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.95),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Search for groceries…',
                hintStyle: TextStyle(color: Color(0xFF9AA0A6)),
                prefixIcon: Icon(Icons.search),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build top 6 category mosaics
  Widget _buildTopCategoriesMosaics() {
    const preferred = [
      'Vegetables & Fruits',
      'Ghee & Masala',
      'Bread & Eggs',
      'Coffee & Milk Drinks',
      'Rice & Dal',
      'Snacks & Drink',
    ];

    final mainsByName = {for (final c in _mainCategories) c.name: c};

    // Synthesize "Vegetables & Fruits" from Grocery & Kitchen subs if needed
    Category? vegFruit;
    final gk = mainsByName['Grocery & Kitchen'];
    if (gk != null &&
        gk.subCategories.any((s) => s.name.contains('Vegetables & Fruits'))) {
      vegFruit = Category(
        id: 'Vegetables & Fruits',
        name: 'Vegetables & Fruits',
        subCategories: gk.subCategories
            .where((s) => s.name.contains('Vegetables & Fruits'))
            .toList(),
      );
    }

    final ordered = <Category>[
      if (vegFruit != null) vegFruit,
      if (mainsByName['Ghee & Masala'] != null) mainsByName['Ghee & Masala']!,
      if (mainsByName['Bread & Eggs'] != null) mainsByName['Bread & Eggs']!,
      if (mainsByName['Coffee & Milk Drinks'] != null)
        mainsByName['Coffee & Milk Drinks']!,
      if (mainsByName['Rice & Dal'] != null) mainsByName['Rice & Dal']!,
      if (mainsByName['Snacks & Drink'] != null)
        mainsByName['Snacks & Drink']!,
    ];

    if (ordered.length < 6) {
      for (final c in _mainCategories) {
        if (ordered.length >= 6) break;
        if (ordered.every((e) => e.name != c.name)) {
          ordered.add(c);
        }
      }
    }
    final top6 = ordered.take(6).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: top6.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: .88,
        ),
        itemBuilder: (ctx, i) {
          final c = top6[i];
          final mosaic = _relatedMosaicForMain(c.name);
          return _TopCategoryMosaicCard(
            title: _displayTitleForTop(c.name),
            images: mosaic,
          );
        },
      ),
    );
  }

  // Build about 4 main sections, each with up to 8 subcategories
  List<Widget> _buildMainCategorySections() {
    // Choose 4 mains (like the design)
    final picks = <String>[
      'Grocery & Kitchen',
      'Snacks & Drink',
      'Rice & Dal',
      'Bread & Eggs',
    ];

    final selected = _mainCategories
        .where((c) => picks.contains(c.name))
        .toList(growable: false);

    return selected.map((c) {
      final subs = c.subCategories.take(8).toList();

      return Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              c.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: subs.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: .9,
              ),
              itemBuilder: (ctx, i) {
                final s = subs[i];
                return Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _subCategoryThumb(main: c.name, sub: s.name),
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 72,
                          height: 72,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      );
    }).toList();
  }

  // Flash sale grid 3 per row, 9-12 products
  Widget _buildFlashSale() {
    if (_flashDeals.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Flash Sale',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _flashDeals.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: .58,
              ),
              itemBuilder: (ctx, i) {
                final p = _flashDeals[i];
                return _FlashCard(product: p, fallbackGetter: _productPlaceholder);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Improved Placeholder Helpers ----------

  // Map main-category -> keywords
  static const Map<String, List<String>> _tagMap = {
    'Vegetables & Fruits': ['vegetable', 'fruit'],
    'Ghee & Masala': ['ghee', 'spices'],
    'Bread & Eggs': ['bread', 'eggs'],
    'Coffee & Milk Drinks': ['coffee', 'milk'],
    'Rice & Dal': ['rice', 'lentils'],
    'Snacks & Drink': ['snacks', 'drinks'],
    'Grocery & Kitchen': ['grocery', 'kitchen'],
    'Household Essentials': ['household', 'cleaning'],
    'Beauty & Personal Care': ['beauty', 'personalcare'],
  };

  // Simplified URL generator
  String _generatePlaceholderUrl({required String seed, required List<String> tags, int width = 220, int height = 220}) {
    // Clean the seed and tags
    final cleanSeed = seed.replaceAll(RegExp(r'[^a-zA-Z0-9-]'), '-').toLowerCase();
    final cleanTags = tags.map((t) => t.replaceAll(' ', '')).join(',');
    
    return 'https://loremflickr.com/$width/$height/$cleanTags?random=$cleanSeed';
  }

  // Build 4 images for a top-category mosaic
  List<String> _relatedMosaicForMain(String main) {
    final tags = _tagMap[main] ?? ['grocery'];
    return List<String>.generate(4, (i) {
      return _generatePlaceholderUrl(
        seed: '${main}_$i',
        tags: tags,
      );
    });
  }

  // Subcategory thumbnail based on its main bucket + sub name
  String _subCategoryThumb({required String main, required String sub}) {
    final tags = [
      ...(_tagMap[main] ?? ['grocery']),
      sub.split(RegExp(r'\s+|&|,|>')).firstWhere((e) => e.isNotEmpty, orElse: () => '').toLowerCase(),
    ].where((t) => t.isNotEmpty).toList();
    
    return _generatePlaceholderUrl(
      seed: '$main-$sub',
      tags: tags,
      width: 160,
      height: 160,
    );
  }

  // Product fallback
  String _productPlaceholder(String name) {
    return _generatePlaceholderUrl(
      seed: 'product-${name.replaceAll(' ', '-')}',
      tags: ['grocery', 'product'],
      width: 400,
      height: 400,
    );
  }

  String _displayTitleForTop(String apiName) {
    if (apiName == 'Ghee & Masala') return 'Oil,Ghee & Masala';
    if (apiName == 'Bread & Eggs') return 'Dairy, Bread & Eggs';
    return apiName;
  }
}

// ======= Widgets =======

// 2x2 mosaic category card used in the top six
class _TopCategoryMosaicCard extends StatelessWidget {
  const _TopCategoryMosaicCard({
    required this.title,
    required this.images,
  });

  final String title;
  final List<String> images;

  @override
  Widget build(BuildContext context) {
    final tiles = images.take(4).map((url) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey[200],
            child: const Icon(Icons.image_not_supported),
          ),
        ),
      );
    }).toList();

    return Column(
      children: [
        Container(
          height: 84,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F3F4),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(6),
          child: GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            children: tiles,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 32,
          child: Text(
            title,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

// Flash sale product card (3 per row look)
class _FlashCard extends StatelessWidget {
  const _FlashCard({
    required this.product,
    required this.fallbackGetter,
  });

  final Product product;
  final String Function(String name) fallbackGetter;

  @override
  Widget build(BuildContext context) {
    final image = (product.imageUrl.isNotEmpty)
        ? product.imageUrl
        : fallbackGetter(product.name);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE6E8EA)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              image,
              height: 110,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 110,
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rs ${product.currentPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (product.isOnSale)
                          Text(
                            'Rs ${product.regularPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      width: 46,
                      height: 26,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF2E7D32)),
                        color: Colors.white,
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'ADD',
                        style: TextStyle(
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}