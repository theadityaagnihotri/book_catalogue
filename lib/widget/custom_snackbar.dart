import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void customSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: GoogleFonts.roboto(
          fontSize: 16.0,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      duration: const Duration(seconds: 1),
    ),
  );
}
