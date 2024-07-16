import 'package:books/auth_servcie.dart';
import 'package:books/screens/order_complete.dart';
import 'package:books/widget/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class CartCheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  CartCheckoutScreen({required this.cartItems});

  @override
  _CartCheckoutScreenState createState() => _CartCheckoutScreenState();
}

class _CartCheckoutScreenState extends State<CartCheckoutScreen> {
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool isEditing = false;
  String _address = '';

  @override
  void initState() {
    super.initState();
    _fetchAddress();
  }

  void _fetchAddress() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    String? address = await authService.getUserAddress();
    setState(() {
      _address = address ?? '';
    });
  }

  void _nextStep() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
      setState(() {
        _currentStep--;
      });
    }
  }

  void _placeOrder(AuthService authService) async {
    await authService.clearCart();
    customSnackBar(context, 'Order placed Successfully!!');
    await Future.delayed(const Duration(seconds: 2));
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const OrderCompleteScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    var size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Checkout',
          style: GoogleFonts.roboto(
            fontSize: 20.0,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: PageView(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            _buildBookDetailsPage(),
            _buildAddAddressPage(),
            _buildReviewOrderPage(authService),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: size.width,
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (_currentStep > 0)
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 1,
                      ),
                      minimumSize: Size(double.infinity, 50),
                    ),
                    onPressed: _previousStep,
                    child: Text(
                      'Back',
                      style: GoogleFonts.roboto(
                        color: Theme.of(context).primaryColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    minimumSize: Size(double.infinity, 50),
                  ),
                  onPressed: _currentStep == 2
                      ? () => _placeOrder(authService)
                      : _nextStep,
                  child: Text(
                    _currentStep == 2 ? 'Place Order' : 'Next',
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookDetailsPage() {
    double totalPrice = widget.cartItems.fold(
      0,
      (sum, item) => sum + item['price'],
    );
    double tax = 10;
    double deliveryCharge = 10;
    double totalAmount = totalPrice + tax + deliveryCharge;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Items',
            style: GoogleFonts.roboto(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.0),
          Expanded(
            child: ListView.builder(
              itemCount: widget.cartItems.length,
              itemBuilder: (context, index) {
                final cartItem = widget.cartItems[index];
                return ListTile(
                  title: Text(cartItem['title']),
                  subtitle: Text('₹${cartItem['price']}'),
                );
              },
            ),
          ),
          Divider(),
          Text(
            'Billing Details',
            style: GoogleFonts.roboto(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.0),
          Text('Total Price: ₹$totalPrice'),
          Text('Tax: ₹$tax'),
          Text('Delivery Charge: ₹$deliveryCharge'),
          Divider(),
          Text(
            'Total Amount: ₹$totalAmount',
            style: GoogleFonts.roboto(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddAddressPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add Address',
            style: GoogleFonts.roboto(
              fontSize: 20.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16.0),
          _address.isNotEmpty && !isEditing
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _address,
                        style: GoogleFonts.roboto(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        setState(() {
                          isEditing = true;
                        });
                      },
                    ),
                  ],
                )
              : Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        initialValue: _address,
                        decoration: InputDecoration(
                          labelText: 'Address',
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your address';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _address = value;
                          });
                        },
                      ),
                      SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final authService = Provider.of<AuthService>(
                                context,
                                listen: false);
                            authService.updateUserAddress(_address);
                            setState(() {
                              isEditing = false;
                            });
                          }
                        },
                        child: Text('Save Address'),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildReviewOrderPage(AuthService authService) {
    double totalPrice = widget.cartItems.fold(
      0,
      (sum, item) => sum + item['price'],
    );
    double tax = 10; // Flat rate for simplicity
    double deliveryCharge = 10; // Flat rate for simplicity
    double totalAmount = totalPrice + tax + deliveryCharge;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review Order',
            style: GoogleFonts.roboto(
              fontSize: 20.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16.0),
          Expanded(
            child: ListView.builder(
              itemCount: widget.cartItems.length,
              itemBuilder: (context, index) {
                final cartItem = widget.cartItems[index];
                return ListTile(
                  title: Text(cartItem['title']),
                  subtitle: Text('₹${cartItem['price']}'),
                );
              },
            ),
          ),
          Divider(),
          Text(
            'Total Amount: ₹$totalAmount',
            style: GoogleFonts.roboto(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
