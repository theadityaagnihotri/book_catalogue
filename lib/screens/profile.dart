import 'package:books/auth_servcie.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool isEditing = false;
  String? _address;
  bool isLoading = true;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchAddress();
  }

  void _fetchAddress() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    String? address = await authService.getUserAddress();
    setState(() {
      _address = address;
      isLoading = false;
    });
  }

  void _toggleEdit() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  void _saveAddress() {
    if (_formKey.currentState!.validate()) {
      final authService = Provider.of<AuthService>(context, listen: false);
      authService.updateUserAddress(_address!);
      setState(() {
        isEditing = false;
      });
    }
  }

  Future<void> _logout() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.signOut();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User Profile',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40.0,
                        backgroundImage: user?.photoURL != null
                            ? NetworkImage(user!.photoURL!)
                            : null,
                        child: user?.photoURL == null
                            ? Icon(Icons.person, size: 40.0)
                            : null,
                      ),
                      SizedBox(width: 16.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.displayName ?? 'Name not available',
                            style: GoogleFonts.roboto(
                              fontSize: 20.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            user?.email ?? 'Email not available',
                            style: GoogleFonts.roboto(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 32.0),
                  if (isEditing)
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            initialValue: _address,
                            decoration: InputDecoration(
                              labelText: 'Address',
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
                            onPressed: _saveAddress,
                            child: Text('Save Address'),
                          ),
                        ],
                      ),
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _address == null || _address!.isEmpty
                              ? 'Add an address for faster checkout!!'
                              : _address!,
                          style: GoogleFonts.roboto(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: _toggleEdit,
                        ),
                      ],
                    ),
                  const Spacer(),
                  Center(
                    child: ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text(
                        'Logout',
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
    );
  }
}
