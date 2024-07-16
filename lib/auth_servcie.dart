import 'package:books/widget/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;

  Future<void> updateUserAddress(String address) async {
    if (currentUser != null) {
      final userRef = _firestore.collection('users').doc(currentUser!.uid);
      await userRef.update({
        'address': address,
      });
      notifyListeners();
    }
  }

  Future<String?> getUserAddress() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      final userRef = _firestore.collection('users').doc(currentUser.uid);
      final userDoc = await userRef.get();

      if (userDoc.exists) {
        final address = userDoc.data()?['address'] as String?;
        return address;
      } else {
        return '';
      }
    }
    return null;
  }

  String? get currentUserAddress {
    return _currentUserAddress;
  }

  String? _currentUserAddress;

  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (_user != null) {
        getUserAddress();
      } else {
        _currentUserAddress = null;
      }
      notifyListeners();
    });
  }

  User? get currentUser => _user;

  Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      return null;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential =
        await _auth.signInWithCredential(credential);
    _user = userCredential.user;

    if (_user != null) {
      await _addUserToFirestore(_user!);
    }

    notifyListeners();
    return _user;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> addToCart(
      String bookId, String option, BuildContext context) async {
    if (_user != null) {
      final userRef = _firestore.collection('users').doc(_user!.uid);

      await userRef.update({
        'cart': FieldValue.arrayUnion([
          {
            'bookId': bookId,
            'option': option,
          }
        ]),
      });
      customSnackBar(context, 'Item added to cart successfully!');
    }
  }

  Future<void> updateCartOption(String bookId, String option) async {
    if (_user != null) {
      final userRef = _firestore.collection('users').doc(_user!.uid);
      final cartSnapshot = await userRef.get();
      if (cartSnapshot.exists) {
        List<dynamic> cart = cartSnapshot.get('cart') ?? [];
        List<Map<String, dynamic>> updatedCart = [];

        for (var item in cart) {
          if (item['bookId'] == bookId) {
            item['option'] = option;
          }
          updatedCart.add(item);
        }

        await userRef.update({'cart': updatedCart});
      }
    }
  }

  Future<void> removeFromCart(
      String bookId, BuildContext context, String message) async {
    try {
      if (_user != null) {
        final userRef = _firestore.collection('users').doc(_user!.uid);
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final docSnap = await userRef.get();
          final cart = docSnap.get('cart') as List;

          cart.removeWhere((item) => item['bookId'] == bookId);

          await transaction.update(userRef, {'cart': cart});
          customSnackBar(context, message);
        });
      }
    } catch (e) {
      print('Error removing item from cart: $e');
      customSnackBar(context, 'Error in removing item: $e');
      throw e;
    }
  }

  Future<void> clearCart() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'cart': [],
        });
      }
    } catch (e) {
      print('Error clearing cart: $e');
      throw e;
    }
  }

  Stream<List<Map<String, dynamic>>> get cartStream {
    return _firestore
        .collection('users')
        .doc(currentUser?.uid)
        .snapshots()
        .map((snapshot) {
      final cart = snapshot.data()?['cart'] as List<dynamic>? ?? [];
      return cart.cast<Map<String, dynamic>>();
    });
  }

  Future<List<Map<String, dynamic>>> getUserCart() async {
    List<Map<String, dynamic>> cartItems = [];
    if (_user != null) {
      final userDoc =
          await _firestore.collection('users').doc(_user!.uid).get();
      if (userDoc.exists) {
        cartItems = List<Map<String, dynamic>>.from(userDoc.get('cart') ?? []);
      }
    }
    return cartItems;
  }

  Future<void> _addUserToFirestore(User user) async {
    final userDoc = _firestore.collection('users').doc(user.uid);

    final docSnapshot = await userDoc.get();
    if (!docSnapshot.exists) {
      await userDoc.set({
        'email': user.email,
        'uid': user.uid,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'cart': [],
        'address': '',
      });
    }
  }
}
