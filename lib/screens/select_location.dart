import 'package:books/providers/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SelectLocation extends StatefulWidget {
  const SelectLocation({super.key});

  @override
  State<SelectLocation> createState() => _SelectLocationState();
}

class _SelectLocationState extends State<SelectLocation> {
  final _formKey = GlobalKey<FormState>();

  final List<String> _cities = [
    "Delhi",
    "Mumbai",
    "Bangalore",
    "Chennai",
    "Hyderabad"
  ];

  String? _pincodeValidator(String? value) {
    if (value!.isEmpty) {
      return "Please enter a pincode";
    } else if (value.length != 6) {
      return "Pincode must be 6 digits";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "City",
                style: GoogleFonts.roboto(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              DropdownButtonFormField<String>(
                value: "Delhi",
                decoration: InputDecoration(
                  labelText: "Select City",
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(width: 1.0),
                  ),
                ),
                items: _cities
                    .map((city) => DropdownMenuItem<String>(
                          value: city,
                          child: Text(
                            city,
                            style: GoogleFonts.roboto(),
                          ),
                        ))
                    .toList(),
                onChanged: (value) => locationProvider.city = value!,
                validator: (value) =>
                    value == null ? "Please select a city" : null,
              ),
              SizedBox(height: 16.0),
              Text(
                "Pincode",
                style: GoogleFonts.roboto(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.0),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Pincode",
                  labelStyle: GoogleFonts.roboto(),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(width: 1.0),
                  ),
                ),
                validator: _pincodeValidator,
                keyboardType: TextInputType.number,
                maxLength: 6,
                onSaved: (value) => locationProvider.pincode = value!,
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Navigator.pushReplacementNamed(context, '/catalogue');
                    print(
                        "City: ${locationProvider.city}, Pincode: ${locationProvider.pincode}");
                  }
                },
                child: Text(
                  "Continue",
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
