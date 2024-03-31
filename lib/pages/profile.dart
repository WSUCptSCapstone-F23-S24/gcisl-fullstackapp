import 'dart:html';

import 'package:csc_picker/csc_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gcisl_app/main.dart';
import 'package:gcisl_app/pages/public_profile.dart';
import 'package:geocode/geocode.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../helper_functions/geolocation_service.dart';

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
      zipValue,
      _company,
      _position;
  String? emailHash;

  TextEditingController _emailController = TextEditingController();
  TextEditingController _userTypeController = TextEditingController();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _zipcodeController = TextEditingController();
  TextEditingController _companyController = TextEditingController();
  TextEditingController _companyPositionController = TextEditingController();
  TextEditingController _countryAddressController = TextEditingController();

  String kRadarApiKey = "prj_live_sk_2fb53893e9f964d139db2df3f78ef8480ba5d424";
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
      content: Text(
        message,
        textAlign: TextAlign.center,
      ),
      actions: [
        Center(child: okButton),
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
      child: Text("Go Back to Home Page"),
      onPressed: () {
        //this should refresh and go to home page
        //Navigator.of(context).pop();
        Navigator.of(context, rootNavigator: true)
            .pop('dialog'); // Dismiss the dialog
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyApp()),
        );
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(""),
      content: Text("Sucess! Profile Updated", textAlign: TextAlign.center),
      actions: [
        Center(child: okButton),
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

  showLocationErrorAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        // When Ok button is pressed it will remove the dialog box
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(""),
      content: Text(
        "Error! Please Enter State and City",
        textAlign: TextAlign.center,
      ),
      actions: [
        Center(child: okButton),
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
      ref.update({
        "first name": _firstName,
        "last name": _lastName,
        "email": _emailController.text,
        "phone": _phone,
        "company": _company,
        //"street address": _location1Control.text,
        "city address": cityValue,
        "state address": stateValue,
        "country address": countryValue,
        "zip address": zipValue,
        "lat": lat,
        "long": long,
        "position": _position,
        "experience": "1",
        "date added": ServerValue.timestamp,
        "userType": _userTypeController.text
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
    String addy = "";

    try {
      Map<String, double> coordinates =
          await GeoLocationService.queryGeoLocation(
              countryValue, cityValue, stateValue, zipValue);

      //List<Location> locations = await locationFromAddress(addy);
      //Location local = locations[0];
      lat = coordinates['latitude'];
      long = coordinates['longitude'];
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

  getCurrentUser() async {
    await FirebaseDatabase.instance
        .ref('users')
        .get()
        // ignore: avoid_function_literals_in_foreach_calls
        .then((snapshot) => snapshot.children.forEach((element) {
              if (element.key.toString() == emailHash) {
                _firstNameController.text =
                    element.child("first name").value.toString();
                _lastNameController.text =
                    element.child("last name").value.toString();
                _phoneController.text = element.child("phone").value.toString();
                _zipcodeController.text =
                    element.child("zip address").value.toString();
                _companyController.text =
                    element.child("company").value.toString();
                _companyPositionController.text =
                    element.child("position").value.toString();
                _countryAddressController.text =
                    element.child("country address").value.toString();
                _userTypeController.text =
                    element.child("userType").value.toString();
              }
            }));
  }

  @override
  void initState() {
    getCurrentUser();
    super.initState();
    // Check if user is logged in using Firebase Authentication
    final user = FirebaseAuth.instance.currentUser;

    emailHash = FirebaseAuth.instance.currentUser?.email?.hashCode.toString();
    if (user != null) {
      _emailController.text = user.email!;

      if (_userTypeController.text == "null") {
        _userTypeController.text = "student";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print("user type: " + _userTypeController.text);
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
                  ),
                  controller: _firstNameController,
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
                  ),
                  controller: _lastNameController,
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
                  ),
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email address';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _emailController.text = value!;
                  },
                ),
                const SizedBox(height: 30.0),
                TextFormField(
                  decoration: InputDecoration(
                    label: RichText(
                      text: const TextSpan(
                          text: 'Phone',
                          style: const TextStyle(color: Colors.black),
                          children: [
                            TextSpan(
                                text: ' *',
                                style: TextStyle(
                                  color: Colors.red,
                                ))
                          ]),
                    ),
                  ),
                  controller: _phoneController,
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
                const SizedBox(height: 20.0),
                TextFormField(
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
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
                const SizedBox(height: 30.0),
                TextFormField(
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
                  ),
                  controller: _companyController,
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
                  ),
                  controller: _companyPositionController,
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
                TextFormField(
                  decoration: InputDecoration(
                    label: RichText(
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  controller: _userTypeController,
                  readOnly: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your user role';
                    }
                    return null;
                  },
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Select Role'),
                          content: DropdownButtonFormField<String>(
                            value: _userTypeController.text,
                            onChanged: (String? newValue) {
                              setState(() {
                                _userTypeController.text = newValue!;
                              });
                            },
                            items: ['student', 'alumni', 'faculty']
                                .map((String userType) {
                              return DropdownMenuItem<String>(
                                value: userType,
                                child: Text(userType),
                              );
                            }).toList(),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                // TextFormField(
                //   decoration: const InputDecoration(labelText: 'Role'),
                //   controller: _userTypeController,
                //   readOnly: true,
                //   maxLines: 1,
                //   validator: (value) {
                //     if (value == null || value.isEmpty) {
                //       return 'Please enter your user role';
                //     }
                //     return null;
                //   },
                //   onSaved: (value) {
                //     _userTypeController.text = value!;
                //   },
                // ),
                const SizedBox(height: 30.0),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null // disable button while loading
                      : () async {
                          if (_formKey.currentState!.validate() &&
                              stateValue != null &&
                              cityValue != null) {
                            _formKey.currentState!.save();
                            setState(() {
                              _isLoading = true;
                            });
                            // send to fireabse
                            await getLatLong(context);
                            setState(() {
                              _isLoading = false;
                            });
                          } else {
                            // Show an error message if state or city is not selected
                            // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            //   content: Text('Please select State and City'),
                            // ));
                            showLocationErrorAlertDialog(context);
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
