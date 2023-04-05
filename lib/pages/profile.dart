import 'dart:html';

import 'package:csc_picker/csc_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geocode/geocode.dart';
import 'package:geocoding/geocoding.dart';

import '../palette.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  String? _firstName,
      _lastName,
      _phone,
      _address,
      cityValue,
      stateValue,
      countryValue,
      _company,
      _position;
  TextEditingController _emailController = TextEditingController();
  String kGoogleApiKey = "YOUR_GOOGLE_MAPS_API_KEY_HERE";
  DatabaseReference ref = FirebaseDatabase.instance.ref("users");
  bool _isLoading = false;

  showErrorAlertDialog(BuildContext context, String message) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Profile not uploaded"),
      content: Text(message),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showSucessAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("To Home Page"),
      onPressed: () {
        // ignore: todo
        //TODO this should refresh and go to home page
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(""),
      content: Text("Sucess! Profile Uploaded"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  //upload profile data to backend
  uploadData(double? lat, double? long) {
    print("uploading to database...");
    //set userid to hashcode of email
    var userID = _emailController.text.hashCode;

    //add to firebase database
    ref = FirebaseDatabase.instance.ref("users/$userID");

    try {
      ref.set({
        "first name": _firstName,
        "last name": _lastName,
        "email": _emailController.text,
        "phone": _phone,
        "company": _company,
        //"street address": _location1Control.text,
        "city address": cityValue,
        "state address": stateValue,
        "country address": countryValue,
        "lat": lat,
        "long": long,
        "position": _position,
        "experience": "1",
        "date added": ServerValue.timestamp
      });
      print("sucess!");
    } catch (e) {
      print(e);
      print("not uploaded");
    }
  }

  //get lat long to save data to backend
  getLatLong(context) async {
    //get lat and log values
    double? lat = 0;
    double? long = 0;

    GeoCode geoCode = GeoCode();

    String addy = "${cityValue}, ${stateValue}, ${countryValue}";

    print(addy);

    try {
      Coordinates coordinates = await geoCode.forwardGeocoding(address: addy);
      //List<Location> locations = await locationFromAddress(addy);
      //Location local = locations[0];
      lat = coordinates.latitude;
      long = coordinates.longitude;
      //print("Latitude: ${lat}");
      //print("Longitude: ${long}");

      uploadData(lat, long);

      showSucessAlertDialog(context);
    } catch (e) {
      print(e);

      String message = "Invalid address, please try again";
      print(message);

      showErrorAlertDialog(context, message);
    }
  }

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
        backgroundColor: Palette.ktoCrimson,
        title: const Text('Create Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(80, 20, 80, 20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(labelText: 'First Name'),
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
                const SizedBox(height: 30.0),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Last Name'),
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
                const SizedBox(height: 30.0),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email'),
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
                const SizedBox(height: 30.0),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Phone'),
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
                const SizedBox(height: 30.0),
                CSCPicker(
                  ///Enable disable state dropdown [OPTIONAL PARAMETER]
                  showStates: true,

                  /// Enable disable city drop down [OPTIONAL PARAMETER]
                  showCities: true,

                  ///Enable (get flag with country name) / Disable (Disable flag) / ShowInDropdownOnly (display flag in dropdown only) [OPTIONAL PARAMETER]
                  flagState: CountryFlag.DISABLE,

                  ///Dropdown box decoration to style your dropdown selector [OPTIONAL PARAMETER] (USE with disabledDropdownDecoration)
                  dropdownDecoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      color: Colors.white,
                      border:
                          Border.all(color: Colors.grey.shade300, width: 1)),

                  ///Disabled Dropdown box decoration to style your dropdown selector [OPTIONAL PARAMETER]  (USE with disabled dropdownDecoration)
                  disabledDropdownDecoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      color: Colors.grey.shade300,
                      border:
                          Border.all(color: Colors.grey.shade300, width: 1)),

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
                const SizedBox(height: 30.0),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Company'),
                  maxLines: 1,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your company';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _company = value;
                  },
                ),
                const SizedBox(height: 30.0),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Position'),
                  maxLines: 1,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your position at the Company';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _position = value;
                  },
                ),
                const SizedBox(height: 30.0),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null // disable button while loading
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            setState(() {
                              _isLoading = true;
                            });
                            // send to fireabse
                            await getLatLong(context);
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Palette.ktoCrimson),
                  child: _isLoading
                      ? const CircularProgressIndicator() // show progress icon while loading
                      : const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
