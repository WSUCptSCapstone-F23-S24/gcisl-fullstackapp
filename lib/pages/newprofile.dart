import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class NewProfilePage extends StatefulWidget {
  @override
  _NewProfilePageState createState() => _NewProfilePageState();
}

class _NewProfilePageState extends State<NewProfilePage> {
  final _formKey = GlobalKey<FormState>();
  String? _firstName, _lastName, _phone, _address, _city, _state, _country;
  TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Check if user is logged in using Firebase Authentication
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _emailController.text = user.email!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Profile'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'First Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _firstName = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Last Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _lastName = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email address';
                  }
                  return null;
                },
                onSaved: (value) {
                  _emailController.text = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _phone = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Address'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
                onSaved: (value) {
                  _address = value;
                },
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _city,
                onChanged: (String? value) {
                  setState(() {
                    _city = value!;
                  });
                },
                items: <String>[
                  'New York City',
                  'Los Angeles',
                  'Chicago',
                  'Houston',
                  'Philadelphia',
                  'Phoenix',
                  'San Antonio',
                  'San Diego',
                  'Dallas',
                  'San Jose'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'City',
                  hintText: 'Select City',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your city';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(labelText: 'State'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your state';
                  }
                  return null;
                },
                onSaved: (value) {
                  _state = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Country'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your country';
                  }
                  return null;
                },
                onSaved: (value) {
                  _country = value;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
// Save user data to Firebase Realtime Database
                    DatabaseReference databaseReference =
                        FirebaseDatabase.instance.reference().child('users');
                    String userId = FirebaseAuth.instance.currentUser!.uid;
                    databaseReference.child(userId).set({
                      'firstName': _firstName,
                      'lastName': _lastName,
                      'phone': _phone,
                      'address': _address,
                      'city': _city,
                      'state': _state,
                      'country': _country,
                    });

                    // Navigate to the home screen
                    Navigator.pop(context);
                  }
                },
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
