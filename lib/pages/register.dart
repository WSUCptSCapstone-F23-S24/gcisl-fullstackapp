import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gcisl_app/palette.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:flutter/services.dart';
import 'package:geocode/geocode.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../helper_functions/geolocation_service.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showSignInPage;
  const RegisterPage({Key? key, required this.showSignInPage})
      : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailControllor = TextEditingController();
  final _passwordControllor = TextEditingController();
  final _confirmPasswordControllor = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyController = TextEditingController();
  final _positionController = TextEditingController();
  final _zipcodeController = TextEditingController();
  final _countryAddressController = TextEditingController();

  String? countryValue;
  String? stateValue;
  String? cityValue;
  String? zipValue;

  String _selectedUserType = 'student'; // Default user type

  var loading = false;

  //get lat long to save data to backend
  getLatLong(context) async {
    //get lat and log values
    double? lat = 0;
    double? long = 0;
    String addy = "";

    try {
      Map<String, double> coordinates =
          await GeoLocationService.queryGeoLocation(
              countryValue, cityValue, stateValue, zipValue);

      lat = coordinates['latitude'];
      long = coordinates['longitude'];
      //print("Latitude: ${lat}");
      //print("Longitude: ${long}");

      //uploadData(lat, long);
      _register(lat, long);
    } catch (e) {
      print(e);

      String message = "Invalid address, please try again";
      print(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                //Wecolme Back
                const Text(
                  'Welcome to Cobb Connect!',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 24),
                ),

                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Fill out the form below in order to create a new account on Cobb Connect',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                RichText(
                  text: const TextSpan(
                    text: 'Fields marked with',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: ' * ',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: 'are required',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                //Email textfield
                const SizedBox(height: 20),
                Container(
                  width: MediaQuery.of(context).size.width * 0.50,
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: TextFormField(
                      controller: _emailControllor,
                      validator: _requiredValidator,
                      style: const TextStyle(color: Colors.black),
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        label: RichText(
                          text: const TextSpan(
                              text: 'Email',
                              style: const TextStyle(color: Colors.black),
                              children: [
                                TextSpan(
                                    text: ' *',
                                    style: TextStyle(
                                      color: Colors.red,
                                    ))
                              ]),
                        ),
                        border: InputBorder.none,
                        //hintText: 'Email',
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ),
                //Password textfield
                const SizedBox(height: 20),
                Container(
                  width: MediaQuery.of(context).size.width * 0.50,
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: TextFormField(
                      controller: _passwordControllor,
                      validator: _requiredValidator,
                      style: const TextStyle(color: Colors.black),
                      cursorColor: Colors.black,
                      obscureText: true,
                      decoration: InputDecoration(
                        label: RichText(
                          text: const TextSpan(
                              text: 'Password',
                              style: const TextStyle(color: Colors.black),
                              children: [
                                TextSpan(
                                    text: ' *',
                                    style: TextStyle(
                                      color: Colors.red,
                                    ))
                              ]),
                        ),
                        border: InputBorder.none,
                        //hintText: 'Password',
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ),

                //Confirm Password textfield
                const SizedBox(height: 20),
                Container(
                  width: MediaQuery.of(context).size.width * 0.50,
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: TextFormField(
                      onFieldSubmitted: (value) {
                        debugPrint("pressed");
                        if (_formKey.currentState != null &&
                            _formKey.currentState!.validate()) {
                          _register(0, 0);
                        }
                      },
                      controller: _confirmPasswordControllor,
                      validator: _confirmPassword,
                      style: const TextStyle(color: Colors.black),
                      cursorColor: Colors.black,
                      obscureText: true,
                      decoration: InputDecoration(
                        label: RichText(
                          text: const TextSpan(
                              text: 'Re-enter Password',
                              style: const TextStyle(color: Colors.black),
                              children: [
                                TextSpan(
                                    text: ' *',
                                    style: TextStyle(
                                      color: Colors.red,
                                    ))
                              ]),
                        ),
                        border: InputBorder.none,
                        //hintText: 'Re-enter Password',
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                Container(
                  width: MediaQuery.of(context).size.width * 0.50,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: TextFormField(
                      controller: _firstNameController,
                      validator: _requiredValidator,
                      style: const TextStyle(color: Colors.black),
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        label: RichText(
                          text: const TextSpan(
                              text: 'First Name',
                              style: const TextStyle(color: Colors.black),
                              children: [
                                TextSpan(
                                    text: ' *',
                                    style: TextStyle(
                                      color: Colors.red,
                                    ))
                              ]),
                        ),
                        border: InputBorder.none,
                        //hintText: 'First Name',
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                Container(
                  width: MediaQuery.of(context).size.width * 0.50,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: TextFormField(
                      controller: _lastNameController,
                      validator: _requiredValidator,
                      style: const TextStyle(color: Colors.black),
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        label: RichText(
                          text: const TextSpan(
                              text: 'Last Name',
                              style: const TextStyle(color: Colors.black),
                              children: [
                                TextSpan(
                                    text: ' *',
                                    style: TextStyle(
                                      color: Colors.red,
                                    ))
                              ]),
                        ),
                        border: InputBorder.none,
                        //hintText: 'Last Name',
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                Container(
                  width: MediaQuery.of(context).size.width * 0.50,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: TextFormField(
                      controller: _phoneController,
                      validator: _requiredValidator,
                      style: const TextStyle(color: Colors.black),
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        label: RichText(
                          text: const TextSpan(
                              text: 'Phone Number',
                              style: const TextStyle(color: Colors.black),
                              children: [
                                TextSpan(
                                    text: ' *',
                                    style: TextStyle(
                                      color: Colors.red,
                                    ))
                              ]),
                        ),
                        border: InputBorder.none,
                        //hintText: 'Phone Number',
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30.0),
                Container(
                  width: MediaQuery.of(context).size.width * 0.50,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      label: RichText(
                        text: const TextSpan(
                            text: 'Location',
                            style: const TextStyle(color: Colors.black),
                            children: [
                              TextSpan(
                                  text: ' *',
                                  style: TextStyle(
                                    color: Colors.red,
                                  ))
                            ]),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    child: CSCPicker(
                      ///Enable disable state dropdown [OPTIONAL PARAMETER]
                      showStates: true,

                      /// Enable disable city drop down [OPTIONAL PARAMETER]
                      showCities: true,

                      ///Enable (get flag with country name) / Disable (Disable flag) / ShowInDropdownOnly (display flag in dropdown only) [OPTIONAL PARAMETER]
                      flagState: CountryFlag.DISABLE,

                      ///Dropdown box decoration to style your dropdown selector [OPTIONAL PARAMETER] (USE with disabledDropdownDecoration)
                      dropdownDecoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          color: Colors.white,
                          border: Border.all(
                              color: Colors.grey.shade300, width: 1)),

                      ///Disabled Dropdown box decoration to style your dropdown selector [OPTIONAL PARAMETER]  (USE with disabled dropdownDecoration)
                      disabledDropdownDecoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          color: Colors.grey.shade300,
                          border: Border.all(
                              color: Colors.grey.shade300, width: 1)),

                      ///placeholders for dropdown search field
                      countrySearchPlaceholder: "Country",
                      stateSearchPlaceholder: "State",
                      citySearchPlaceholder: "City",

                      ///labels for dropdown
                      countryDropdownLabel: "Country",
                      stateDropdownLabel: "State",
                      cityDropdownLabel: "City",

                      ///Default Country
                      defaultCountry: CscCountry.United_States,

                      ///Disable country dropdown (Note: use it with default country)
                      //disableCountry: true,

                      ///selected item style [OPTIONAL PARAMETER]
                      selectedItemStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),

                      ///DropdownDialog Heading style [OPTIONAL PARAMETER]
                      dropdownHeadingStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                          fontWeight: FontWeight.bold),

                      ///DropdownDialog Item style [OPTIONAL PARAMETER]
                      dropdownItemStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),

                      ///Dialog box radius [OPTIONAL PARAMETER]
                      dropdownDialogRadius: 10.0,

                      ///Search bar radius [OPTIONAL PARAMETER]
                      searchBarRadius: 10.0,

                      ///triggers once country selected in dropdown
                      onCountryChanged: (value) {
                        setState(() {
                          ///store value in country variable
                          countryValue = value;
                        });
                      },

                      ///triggers once state selected in dropdown
                      onStateChanged: (value) {
                        setState(() {
                          ///store value in state variable
                          stateValue = value;
                        });
                      },

                      ///triggers once city selected in dropdown
                      onCityChanged: (value) {
                        setState(() {
                          ///store value in city variable
                          cityValue = value;
                        });
                      },

                      ///Show only specific countries using country filter
                      // countryFilter: ["United States", "Canada", "Mexico"],
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                Container(
                  width: MediaQuery.of(context).size.width * 0.50,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: TextFormField(
                      style: const TextStyle(color: Colors.black),
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        label: RichText(
                          text: const TextSpan(
                              text: 'Postal Code',
                              style: const TextStyle(color: Colors.black),
                              children: [
                                TextSpan(
                                    text: ' *',
                                    style: TextStyle(
                                      color: Colors.red,
                                    ))
                              ]),
                        ),
                        border: InputBorder.none,
                        // hintText: 'Postal Code/Zip Code'
                      ),
                      controller: _zipcodeController,
                      // keyboardType: TextInputType.number,
                      // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a postal code';
                        }
                        // if (value.length != 5) {
                        //   return 'Zip code must be 5 digits';
                        // }
                        return null;
                      },
                      onSaved: (value) {
                        zipValue = value;
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                Container(
                  width: MediaQuery.of(context).size.width * 0.50,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: TextFormField(
                      controller: _companyController,
                      validator: _requiredValidator,
                      style: const TextStyle(color: Colors.black),
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        label: RichText(
                          text: const TextSpan(
                              text: 'Company',
                              style: const TextStyle(color: Colors.black),
                              children: [
                                TextSpan(
                                    text: ' *',
                                    style: TextStyle(
                                      color: Colors.red,
                                    ))
                              ]),
                        ),
                        border: InputBorder.none,
                        //hintText: 'Company',
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                Container(
                  width: MediaQuery.of(context).size.width * 0.50,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: TextFormField(
                      controller: _positionController,
                      validator: _requiredValidator,
                      style: const TextStyle(color: Colors.black),
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        label: RichText(
                          text: const TextSpan(
                              text: 'Position',
                              style: const TextStyle(color: Colors.black),
                              children: [
                                TextSpan(
                                    text: ' *',
                                    style: TextStyle(
                                      color: Colors.red,
                                    ))
                              ]),
                        ),
                        border: InputBorder.none,
                        //hintText: 'Position',
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),
                //User-role drop-down button
                // Add a dropdown or radio buttons for user type selection
                DropdownButton<String>(
                  hint: RichText(
                    text: const TextSpan(
                        text: 'Role',
                        style: const TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                              text: ' *',
                              style: TextStyle(
                                color: Colors.red,
                              ))
                        ]),
                  ),
                  //value: _selectedUserType,
                  items: <String>['student', 'alumni', 'faculty']
                      .map((String userType) {
                    return DropdownMenuItem<String>(
                      value: userType,
                      child: Text(userType),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedUserType = newValue!;
                    });
                  },
                ),

                //Register button
                const SizedBox(height: 20),
                Container(
                  width: MediaQuery.of(context).size.width * 0.50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Palette.ktoCrimson,
                      minimumSize: const Size(0, 65),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                    ),
                    onPressed: () {
                      debugPrint("pressed");
                      if (_formKey.currentState != null &&
                          _formKey.currentState!.validate()) {
                        getLatLong(context);
                      }
                    },
                    child: const Center(
                        child: Text(
                      'Register',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    )),
                  ),
                ),

                //Already a Member? Login
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already a User? ',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      onPressed: widget.showSignInPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 0,
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ));
  }

  String? _requiredValidator(String? text) {
    if (text == null || text.trim().isEmpty) {
      return 'This Field is Required';
    }
    return null;
  }

  String? _confirmPassword(String? confirmPass) {
    if (confirmPass == null || confirmPass.trim().isEmpty) {
      return 'This Field is Required';
    }
    if (_passwordControllor.text != confirmPass) {
      return "Passwords do not match";
    }
    return null;
  }

  void _handleRegisterError(FirebaseAuthException e) {
    String message = " ";
    switch (e.code) {
      case 'email-already-in-use':
        message = "An account is already being used with this email";
        break;
      case 'invalid-email':
        message = "Invalid Email";
        break;
      case 'operation-not-alowed':
        message = "Error: Opporation not allowed";
        break;
      case 'weak-password':
        message = "Password is too weak, please enter a longer one";
        break;
    }

    showDialog(
        context: context,
        builder: ((context) => AlertDialog(
              title: const Text("Sign up failed"),
              content: Text(message),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    // ignore: prefer_const_constructors
                    child: Text("Ok"))
              ],
            )));
  }

  Future _register(double? lat, double? long) async {
    setState(() {
      loading = true;
    });

    try {
      //try adding new user to authenticator
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailControllor.text, password: _passwordControllor.text);
      // ignore: todo
      //TODO: add user data to database
      // Get the user's unique ID
      var userID = _emailControllor.text.hashCode;
      DatabaseReference ref = FirebaseDatabase.instance.ref("users/$userID");
      bool isAdmin = _emailControllor.text == "admin@wsu.edu" ? true : false;

      await ref.set({
        'first name': _firstNameController.text,
        'last name': _lastNameController.text,
        "email": _emailControllor.text,
        'phone': _phoneController.text,
        'company': _companyController.text,
        "city address": cityValue,
        "state address": stateValue,
        "country address": countryValue,
        "zip address": _zipcodeController.text,
        "lat": lat,
        "long": long,
        'position': _positionController.text,
        "experience": "1",
        "date added": ServerValue.timestamp,
        'userType': _selectedUserType,
        'isAdmin': isAdmin,
      });
      //show success message
      await showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text("Sign up Success"),
                content:
                    const Text("Your account was created, you can now login"),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Center(child: const Text("Ok")))
                ],
              ));

      widget.showSignInPage();
    } on FirebaseAuthException catch (e) {
      _handleRegisterError(e);
      setState(() {
        loading = false;
      });
    }
  }
}
