import 'package:flutter/material.dart';

class LocationProvider extends ChangeNotifier {
  String _city = "Delhi";
  String _pincode = "";

  String get city => _city;
  String get pincode => _pincode;

  set city(String value) {
    _city = value;
    notifyListeners();
  }

  set pincode(String value) {
    _pincode = value;
    notifyListeners();
  }
}
