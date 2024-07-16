import 'package:books/auth_servcie.dart';
import 'package:books/providers/location_provider.dart';
import 'package:books/screens/catalogue_page.dart';
import 'package:books/screens/select_location.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LocationProvider()),
        ChangeNotifierProvider(create: (context) => AuthService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Catalogue',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4D40A9),
        ),
        useMaterial3: true,
      ),
      home: const SelectLocation(),
      routes: {
        '/catalogue': (context) => const CataloguePage(),
      },
    );
  }
}
