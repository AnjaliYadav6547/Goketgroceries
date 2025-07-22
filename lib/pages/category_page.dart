import 'package:flutter/material.dart';

class CategoryPage extends StatelessWidget {
  // 1. Define Controller
  final TextEditingController searchController = TextEditingController();

  // 2. Define Category Data Constants (place at top of class)
  static const List<Map<String, String>> groceryKitchen = [
    {"img": "assets/images/image_41.png", "text": "Vegetables & \nFruits"},
    {"img": "assets/images/image_42.png", "text": "Atta, Dal & \nRice"},
    {"img": "assets/images/image_43.png", "text": "Oil, Ghee & \nMasala"},
    {"img": "assets/images/image_44.png", "text": "Dairy, Bread & \nMilk"},
    {"img": "assets/images/image_45.png", "text": "Biscuits & \nBakery"}
  ];

  static const List<Map<String, String>> secondGrocery = [
    {"img": "assets/images/image_21.png", "text": "Dry Fruits &\n Cereals"},
    {"img": "assets/images/image_22.png", "text": "Kitchen &\n Appliances"},
    {"img": "assets/images/image_23.png", "text": "Tea & \nCoffees"},
    {"img": "assets/images/image_24.png", "text": "Ice Creams & \nmuch more"},
    {"img": "assets/images/image_25.png", "text": "Noodles & \nPacket Food"}
  ];

  static const List<Map<String, String>> snacksAndDrinks = [
    {"img": "assets/images/image_31.png", "text": "Chips &\n Namkeens"},
    {"img": "assets/images/image_32.png", "text": "Sweets & \nChocolates"},
    {"img": "assets/images/image_33.png", "text": "Drinks & \nJuices"},
    {"img": "assets/images/image_34.png", "text": "Sauces &\n Spreads"},
    {"img": "assets/images/image_35.png", "text": "Beauty &\n Cosmetics"}
  ];

  static const List<Map<String, String>> household = [
    {"img": "assets/images/image_36.png", "text": "Cleaning\n Supplies"},
    {"img": "assets/images/image_37.png", "text": "Laundry\n Essentials"},
    {"img": "assets/images/image_38.png", "text": "Home\n Fragrances"},
    {"img": "assets/images/image_39.png", "text": "Pooja\n Items"},
    {"img": "assets/images/image_40.png", "text": "Pet\n Care"}
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeaderSection(),
            const SizedBox(height: 30),
            _buildCategorySection(title: "Grocery & Kitchen", items: groceryKitchen),
            _buildCategorySection(title: "More Grocery Items", items: secondGrocery),
            _buildCategorySection(title: "Snacks & Drinks", items: snacksAndDrinks),
            _buildCategorySection(title: "Household Essentials", items: household),
          ],
        ),
      ),
    );
  }

  // 3. Define Header Section Widget
  Widget _buildHeaderSection() {
    return Stack(
      children: [
        Container(
          height: 190,
          width: double.infinity,
          color: const Color(0xFFF7CB45),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              const Padding(
                padding: EdgeInsets.only(left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Blinkit in",
                      style: TextStyle(
                        color: Color(0xFF000000),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        fontFamily: "bold",
                      ),
                    ),
                    Text(
                      "16 minutes",
                      style: TextStyle(
                        color: Color(0xFF000000),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        fontFamily: "bold",
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          "HOME ",
                          style: TextStyle(
                            color: Color(0xFF000000),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "Buddhanagar",
                          style: TextStyle(
                            color: Color(0xFF000000),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 20,
          bottom: 100,
          child: CircleAvatar(
            radius: 15,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Colors.black, size: 20),
          ),
        ),
        Positioned(
          bottom: 30,
          left: 20,
          right: 20,
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: "Search for products...",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  // 4. Define Category Section Widget with Parameters
  Widget _buildCategorySection({
    required String title,
    required List<Map<String, String>> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              fontFamily: "bold",
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 120,
          child: ListView.builder(
            padding: const EdgeInsets.only(left: 15),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Column(
                  children: [
                    Container(
                      height: 78,
                      width: 71,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color(0xFFD9EBEB),
                      ),
                      child: Center(
                        child: Image.asset(
                          items[index]["img"]!,
                          height: 50,
                          width: 50,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    if (items[index]["text"] != null)
                      Text(
                        items[index]["text"]!,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}