import 'package:books/auth_servcie.dart';
import 'package:books/models/books.dart';
import 'package:books/screens/checkout_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class BookDetailsPage extends StatefulWidget {
  final String bookId;

  BookDetailsPage({required this.bookId});

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  bool added = false;
  late User? _currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() {
    _currentUser = FirebaseAuth.instance.currentUser;

    if (_currentUser != null) {
      _checkBookInCart();
    }
  }

  Future<void> _checkBookInCart() async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(_currentUser!.uid).get();

      List<dynamic> cart = userDoc.get('cart') ?? [];
      bool isInCart = cart.any((item) => item['bookId'] == widget.bookId);

      setState(() {
        added = isInCart;
      });
    } catch (e) {
      print('Error checking cart: $e');
    }
  }

  Future<Book> fetchBookDetails() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('books')
        .doc(widget.bookId)
        .get();
    return Book.fromFirestore(doc);
  }

  Future<void> navigateToCheckout(String option) async {
    try {
      Book book = await fetchBookDetails();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckoutPage(cartItem: {
            'bookId': book.id,
            'title': book.title,
            'price': book.price,
            'imageRoute': book.imageRoute,
            'author': book.author,
            'option': option,
          }),
        ),
      );
    } catch (e) {
      print('Error navigating to checkout: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Buy Now!!!',
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
        actions: [
          IconButton(
            onPressed: () {
              if (added) {
                authService.removeFromCart(
                    widget.bookId, context, 'Item removed Successfully.');
              } else {
                authService.addToCart(widget.bookId, "buy", context);
              }
              setState(() {
                added = !added;
              });
            },
            icon: added
                ? Icon(Icons.remove_shopping_cart, color: Colors.white)
                : Icon(Icons.add_shopping_cart, color: Colors.white),
          ),
        ],
      ),
      body: FutureBuilder<Book>(
        future: fetchBookDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Book not found'));
          } else {
            Book book = snapshot.data!;
            return SizedBox(
              height: size.height,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: GoogleFonts.roboto(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: size.height * 0.02),
                      Text(
                        book.author,
                        style: GoogleFonts.roboto(
                          fontSize: 20,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: size.height * 0.04),
                      Center(
                        child: Image.network(
                          book.imageRoute,
                          height: size.height * 0.4,
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      Text(
                        '₹${book.price.toStringAsFixed(2)}',
                        style: GoogleFonts.roboto(fontSize: 26),
                      ),
                      SizedBox(height: size.height * 0.01),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 1,
                            ),
                            minimumSize: Size(double.infinity, 50),
                          ),
                          onPressed: () async {
                            if (authService.currentUser != null) {
                              await navigateToCheckout("rent");
                            } else {
                              User? user = await authService.signInWithGoogle();
                              if (user != null) {
                                await navigateToCheckout("rent");
                              }
                            }
                          },
                          child: Text(
                            'Rent',
                            style: GoogleFonts.roboto(
                              color: Theme.of(context).primaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.01),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            minimumSize: Size(double.infinity, 50),
                          ),
                          onPressed: () async {
                            if (authService.currentUser != null) {
                              await navigateToCheckout("buy");
                            } else {
                              User? user = await authService.signInWithGoogle();
                              if (user != null) {
                                await navigateToCheckout("buy");
                              }
                            }
                          },
                          child: Text(
                            'Buy Now',
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
        },
      ),
    );
  }
}
