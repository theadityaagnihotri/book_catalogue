import 'package:books/auth_servcie.dart';
import 'package:books/models/books.dart';
import 'package:books/providers/location_provider.dart';
import 'package:books/screens/book_details.dart';
import 'package:books/screens/cart.dart';
import 'package:books/screens/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CataloguePage extends StatefulWidget {
  const CataloguePage({super.key});

  @override
  State<CataloguePage> createState() => _CataloguePageState();
}

class _CataloguePageState extends State<CataloguePage> {
  late Future<List<Book>> booksFuture;

  @override
  void initState() {
    super.initState();
    booksFuture = fetchBooks();
  }

  Future<List<Book>> fetchBooks() async {
    final snapshot = await FirebaseFirestore.instance.collection('books').get();
    return snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Consumer<LocationProvider>(
          builder: (context, locationProvider, child) {
            return Text(
              'Welcome ${locationProvider.city}',
              style: GoogleFonts.roboto(
                fontSize: 20.0,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            );
          },
        ),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          if (authService.currentUser != null) ...[
            IconButton(
              icon: const Icon(
                Icons.person,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserProfilePage()),
                );
              },
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CartScreen()),
                );
              },
              icon: Icon(Icons.shopping_cart_outlined, color: Colors.white),
            ),
          ] else
            TextButton(
              onPressed: () async {
                await authService.signInWithGoogle();
              },
              child: const Text(
                'Sign In',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<List<Book>>(
            future: booksFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No books available'));
              } else {
                final books = snapshot.data!;
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    mainAxisExtent: size.height * 0.3,
                  ),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookDetailsPage(
                              bookId: books[index].id,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 12,
                              child: ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(12.0)),
                                child: Image.network(
                                  books[index].imageRoute,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 6,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      books[index].title,
                                      style: GoogleFonts.roboto(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      books[index].author,
                                      style: GoogleFonts.roboto(
                                        fontSize: 14.0,
                                        color: Colors.black54,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '₹${books[index].price.toStringAsFixed(2)}',
                                      style: GoogleFonts.roboto(
                                        fontSize: 14.0,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            }),
      ),
    );
  }
}
