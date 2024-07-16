import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String id;
  final String title;
  final double price;
  final String author;
  final String imageRoute;

  Book({
    required this.id,
    required this.title,
    required this.price,
    required this.author,
    required this.imageRoute,
  });
  factory Book.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Book(
      id: doc.id,
      title: data['title'] ?? '',
      price: data['price'] is int
          ? (data['price'] as int).toDouble()
          : data['price'] as double,
      author: data['author'] ?? '',
      imageRoute: data['imageRoute'] ?? '',
    );
  }
}
