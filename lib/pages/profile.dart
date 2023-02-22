// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors

import 'dart:html';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../main_widgets/appbar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geocode/geocode.dart';

import '../palette.dart';

class ProfilePage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  //need to add user ID from authenticator
  DatabaseReference ref = FirebaseDatabase.instance.ref("users");

  //controllers
  final _firstNameControl = TextEditingController();
  final _lastNameControl = TextEditingController();
  final _emailControl = TextEditingController();
  final _phoneControl = TextEditingController();
  final _companyControl = TextEditingController();
  //final _location1Control = TextEditingController();
  final _location2Control = TextEditingController();
  final _location3Control = TextEditingController();
  final _positionControl = TextEditingController();
  final _experienceControl = TextEditingController();

  //upload profile data to backend
  uploadData(double? lat, double? long) {
    //set userid to hashcode of email
    var userID = _emailControl.text.hashCode;

    //add to firebase database
    ref = FirebaseDatabase.instance.ref("users/$userID");

    try {
      ref.set({
        "first name": _firstNameControl.text,
        "last name": _lastNameControl.text,
        "email": _emailControl.text,
        "phone": _phoneControl.text,
        "company": _companyControl.text,
        //"street address": _location1Control.text,
        "city address": _location2Control.text,
        "state address": _location3Control.text,
        "lat": lat,
        "long": long,
        "position": _positionControl.text,
        "experience": _experienceControl.text,
        "date added": ServerValue.timestamp
      });
      print("sucess!");
    } catch (e) {
      print(e);
      print("not uploaded");
    }
  }

  String? _requiredValidator(String? text) {
    if (text == null || text.trim().isEmpty) {
      return 'This Field is Required';
    }
    return null;
  }

  String? _validateMobile(String? text) {
    String patttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = new RegExp(patttern);
    if (text?.length == 0) {
      return 'Please enter mobile number';
    } else if (!regExp.hasMatch(text!)) {
      return 'Please enter valid mobile number';
    }
    return null;
  }

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

  //get lat long to save data to backend
  getLatLong(context) async {
    //get lat and log values
    double? lat = 0;
    double? long = 0;

    GeoCode geoCode = GeoCode();

    String addy =
        "${_location2Control.text.trim()}, ${_location3Control.text.trim()}";

    print(addy);

    try {
      Coordinates coordinates = await geoCode.forwardGeocoding(address: addy);

      lat = coordinates.latitude;
      long = coordinates.longitude;
      print("Latitude: ${lat}");
      print("Longitude: ${long}");
      print("uploading to database...");
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
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                //First Name
                SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 300),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextFormField(
                        validator: _requiredValidator,
                        controller: _firstNameControl,
                        style: TextStyle(color: Colors.black),
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'First Name',
                          hoverColor: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),

                //Last Name
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 300),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextFormField(
                        validator: _requiredValidator,
                        controller: _lastNameControl,
                        style: TextStyle(color: Colors.black),
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Last Name',
                          hoverColor: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),

                //Email textfield
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 300),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextFormField(
                        validator: _requiredValidator,
                        controller: _emailControl,
                        style: TextStyle(color: Colors.black),
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Email',
                          hoverColor: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                //Phone Number
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 300),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextFormField(
                        validator: _validateMobile,
                        controller: _phoneControl,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: Colors.black),
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Phone Number',
                          hoverColor: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                //Company
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 300),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextFormField(
                        validator: _requiredValidator,
                        controller: _companyControl,
                        style: TextStyle(color: Colors.black),
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Company',
                          hoverColor: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),

                //Location
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 300),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextFormField(
                        validator: _requiredValidator,
                        controller: _location2Control,
                        style: TextStyle(color: Colors.black),
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'City',
                          hoverColor: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                //Location
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 300),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextFormField(
                        validator: _requiredValidator,
                        controller: _location3Control,
                        style: TextStyle(color: Colors.black),
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'State',
                          hoverColor: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                //Position
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 300),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextFormField(
                        validator: _requiredValidator,
                        controller: _positionControl,
                        style: TextStyle(color: Colors.black),
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Position',
                          hoverColor: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),

                //Experience
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 300),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextFormField(
                        validator: _requiredValidator,
                        controller: _experienceControl,
                        style: TextStyle(color: Colors.black),
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Experience',
                          hoverColor: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),

                //Save button
                SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 300),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Palette.ktoCrimson,
                      minimumSize: const Size(0, 65),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                    ),
                    onPressed: () {
                      //if valid form, send request to get lat long
                      if (_formKey.currentState != null &&
                          _formKey.currentState!.validate()) {
                        getLatLong(context);
                      } else {
                        print("form was not valid");
                      }
                    },
                    child: const Center(
                        child: Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    )),
                  ),
                ),
                //space for after the save button
                SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ));
}
