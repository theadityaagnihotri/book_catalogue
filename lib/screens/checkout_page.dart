import 'package:books/auth_servcie.dart';
import 'package:books/screens/order_complete.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckoutPage extends StatefulWidget {
  final Map<String, dynamic> cartItem;

  CheckoutPage({required this.cartItem});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool isEditing = false;
  String _address = '';

  final double taxAmount = 10.0;
  final double deliveryCharges = 50.0;
  late double totalAmount;

  @override
  void initState() {
    super.initState();
    _fetchAddress();
    totalAmount = widget.cartItem['price'] + taxAmount + deliveryCharges;
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
    await authService.removeFromCart(
        widget.cartItem['bookId'], context, 'Order placed successfully!');

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
    var size = MediaQuery.of(context).size;
    final bookTitle = widget.cartItem['title'];
    final bookImage = widget.cartItem['imageRoute'];
    final bookPrice = widget.cartItem['price'];
    final selectedOption = widget.cartItem['option'] ?? 'buy';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image.network(
              bookImage,
              fit: BoxFit.contain,
              height: size.height * 0.2,
              width: double.infinity,
            ),
          ),
          SizedBox(height: 16.0),
          Text(
            bookTitle,
            style: GoogleFonts.roboto(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            'Option: $selectedOption',
            style: GoogleFonts.roboto(
              fontSize: 18.0,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 16.0),
          Text(
            'Price: ₹${bookPrice.toStringAsFixed(2)}',
            style: GoogleFonts.roboto(
              fontSize: 18.0,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            'Tax: ₹${taxAmount.toStringAsFixed(2)}',
            style: GoogleFonts.roboto(
              fontSize: 18.0,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            'Delivery Charges: ₹${deliveryCharges.toStringAsFixed(2)}',
            style: GoogleFonts.roboto(
              fontSize: 18.0,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            'Total: ₹${totalAmount.toStringAsFixed(2)}',
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
    final bookTitle = widget.cartItem['title'];
    final selectedOption = widget.cartItem['option'] ?? 'buy';

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
          ListTile(
            title: Text(bookTitle),
            subtitle: Text('Option: $selectedOption'),
          ),
          SizedBox(height: 16.0),
          Text(
            'Shipping Address',
            style: GoogleFonts.roboto(
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(_address),
          SizedBox(height: 16.0),
          Text(
            'Total Amount: ₹${totalAmount.toStringAsFixed(2)}',
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
