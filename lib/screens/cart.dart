import 'package:books/auth_servcie.dart';
import 'package:books/screens/cart_ceckout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Future<List<Map<String, dynamic>>> _fetchBookDetails(
      List<Map<String, dynamic>> cartItems) async {
    List<Map<String, dynamic>> detailedCartItems = [];

    for (var item in cartItems) {
      String bookId = item['bookId'];
      DocumentSnapshot bookSnapshot = await FirebaseFirestore.instance
          .collection('books')
          .doc(bookId)
          .get();
      if (bookSnapshot.exists) {
        Map<String, dynamic> bookData =
            bookSnapshot.data() as Map<String, dynamic>;
        bookData['bookId'] = bookId;
        bookData['option'] = item['option'];
        detailedCartItems.add(bookData);
      }
    }
    return detailedCartItems;
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    var size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Cart',
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
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: authService.cartStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No items in cart.'));
          }

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchBookDetails(snapshot.data!),
            builder: (context, bookSnapshot) {
              if (bookSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!bookSnapshot.hasData || bookSnapshot.data!.isEmpty) {
                return Center(child: Text('No items in cart.'));
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: bookSnapshot.data!.length,
                      itemBuilder: (context, index) {
                        final cartItem = bookSnapshot.data![index];
                        final bookId = cartItem['bookId'];
                        final bookPrice = cartItem['price'];
                        final bookTitle = cartItem['title'];
                        final bookImage = cartItem['imageRoute'];
                        String selectedOption = cartItem['option'] ?? 'buy';

                        return Card(
                          margin: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    bookImage,
                                    fit: BoxFit.contain,
                                    width: size.height * 0.15,
                                    height: size.height * 0.20,
                                  ),
                                ),
                                SizedBox(width: 16.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        bookTitle,
                                        style: GoogleFonts.roboto(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 8.0),
                                      Text(
                                        '₹$bookPrice',
                                        style: GoogleFonts.roboto(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.green,
                                        ),
                                      ),
                                      SizedBox(height: 8.0),
                                      DropdownButton<String>(
                                        value: selectedOption,
                                        onChanged: (value) {
                                          authService.updateCartOption(
                                              bookId, value!);
                                        },
                                        items: [
                                          DropdownMenuItem(
                                              value: 'buy', child: Text('Buy')),
                                          DropdownMenuItem(
                                              value: 'rent',
                                              child: Text('Rent')),
                                        ],
                                      ),
                                      SizedBox(height: 8.0),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              authService.removeFromCart(
                                                  bookId,
                                                  context,
                                                  'Item removed successfully.');
                                            },
                                            child: Text(
                                              'Remove',
                                              style: GoogleFonts.roboto(
                                                color: Colors.red,
                                                fontWeight: FontWeight.w500,
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
                          ),
                        );
                      },
                    ),
                  ),
                  if (snapshot.data!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CartCheckoutScreen(
                                cartItems: bookSnapshot.data!,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'Proceed to Checkout!!',
                          style: GoogleFonts.roboto(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          minimumSize: Size(double.infinity, 50),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
