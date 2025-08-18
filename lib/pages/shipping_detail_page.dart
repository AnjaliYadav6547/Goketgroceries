import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'location_picker_screen.dart';
import 'package:flutter_application/services/location_service.dart';
import '../models/order.dart';
import '../services/order_repository.dart';
import 'order_summary_page.dart';
import 'cart_page.dart';

class ShippingDetailsPage extends StatefulWidget {
  const ShippingDetailsPage({super.key});

  @override
  State<ShippingDetailsPage> createState() => _ShippingDetailsPageState();
}

class _ShippingDetailsPageState extends State<ShippingDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _addressLine1Controller = TextEditingController();
  final TextEditingController _addressLine2Controller = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _paymentMethod = 'cod';

  double subtotal = 0.0;
  double deliveryFee = 0.0;
  double total = 0.0;
  bool isLoading = true;
  String? errorMessage;
  List<Map<String, dynamic>> cartItems = [];
  bool isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCartItems() async {
    try {
      final orderRepository = OrderRepository();
      final cartData = await orderRepository.fetchCartItems();
      
      setState(() {
        cartItems = List<Map<String, dynamic>>.from(cartData['items']);
        subtotal = (cartData['subtotal'] as num).toDouble();
        deliveryFee = (cartData['delivery_fee'] as num).toDouble();
        total = (cartData['total'] as num).toDouble();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load cart: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        body: Center(child: Text(errorMessage!)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shipping Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Address Section (matches your reference image)
              const Text(
                'Address',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      controller: _fullNameController,
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildAddressLine1Field(),
                    // _buildTextField(
                    //   controller: _addressLine1Controller,
                    //   label: 'Address Line 1',
                    //   hint: 'Street address, P.O. box, company name',
                    //   validator: (value) {
                    //     if (value == null || value.isEmpty) {
                    //       return 'Please enter your address';
                    //     }
                    //     return null;
                    //   },
                    // ),
                    // const SizedBox(height: 16),
                    _buildTextField(
                      controller: _addressLine2Controller,
                      label: 'Address Line 2 (Optional)',
                      hint: 'Apartment, suite, unit, building, floor, etc.',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _cityController,
                      label: 'City',
                      hint: 'Enter your city',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your city';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      hint: 'Enter your phone number',
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                          return 'Please enter a valid 10-digit phone number';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Order Summary Section (matches your reference image)
              const Text(
                'Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    ...cartItems.map((item) => _buildCartItem(item)),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Subtotal (${cartItems.length} Items)'),
                          Text(
                            'Rs. ${subtotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Shipping and Payment Section (matches your reference image)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Shipping Fee Subtotal'),
                        Text('Rs. ${deliveryFee.toStringAsFixed(2)}'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {},
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Voucher & Code'),
                          Row(
                            children: [
                              Text('Enter Voucher Code >'),
                              SizedBox(width: 4),
                              Icon(Icons.chevron_right, size: 20),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Rs. ${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'All taxes included',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Place Order Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _submitForm,
                  child: const Text(
                    'Place Order',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          keyboardType: keyboardType,
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Rs. ${item['price'].toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  const Text(
                    'You Whilisted this item',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Text(
                'Rs. ${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (item != cartItems.last) const Divider(height: 24),
        ],
      ),
    );
  }

  Widget _buildAddressLine1Field() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Address Line 1',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              icon: const Icon(Icons.my_location, size: 18),
              label: const Text('Auto-fill'),
              onPressed: _fetchCurrentLocation,
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _addressLine1Controller,
          decoration: InputDecoration(
            hintText: 'Street address, P.O. box, company name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min, // Important for proper layout
              children: [
                if (isLoadingLocation)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.location_on),
                  onPressed: _fetchCurrentLocation,
                ),
                IconButton(
                  icon: const Icon(Icons.map),
                  onPressed: _openMapPicker,
                  tooltip: 'Select from map',
                ),
              ],
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your address';
            }
            return null;
          },
          readOnly: true, // Make field read-only since selection is done via buttons
          onTap: _openMapPicker, // Open map when tapping the field
        ),
      ],
    );
  }

  Future<void> _openMapPicker({bool autoFocus = false}) async {
    // Get current address if exists
    LatLng? initialPosition;
    if (_addressLine1Controller.text.isNotEmpty) {
      final locations = await locationFromAddress(_addressLine1Controller.text);
      if (locations.isNotEmpty) {
        initialPosition = LatLng(
          locations.first.latitude,
          locations.first.longitude,
        );
      }
    }

    final selectedAddress = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(
          initialPosition: autoFocus ? null : initialPosition,
          onLocationSelected: (address) => address,
        ),
      ),
    );

    if (selectedAddress != null && mounted) {
      setState(() {
        _addressLine1Controller.text = selectedAddress;
      });
    }
  }

  Future<void> _fetchCurrentLocation() async {
    if (isLoadingLocation) return;
    
    setState(() => isLoadingLocation = true);
    try {
      final address = await LocationService.getCurrentAddress();
      if (address != null && mounted) {
        setState(() {
          _addressLine1Controller.text = address;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoadingLocation = false);
      }
    }
  }



  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderSummaryPage(
            order: Order(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              items: cartItems.map((item) => OrderItem(
                productId: item['id']?.toString() ?? '0',
                productName: item['name'],
                quantity: item['quantity'],
                price: item['price'],
                imageUrl: item['image_url'] ?? '',
              )).toList(),
              total: total,
              address: ShippingAddress(
                fullName: _fullNameController.text,
                addressLine1: _addressLine1Controller.text,
                addressLine2: _addressLine2Controller.text,
                city: _cityController.text,
                phoneNumber: _phoneController.text,
              ),
              paymentMethod: _paymentMethod,
              orderDate: DateTime.now(),
              status: 'pending',
            ),
          ),
        ),
      );
    }
  }
}