// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../main_widgets/appbar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geocoder/geocoder.dart';

class ProfilePage extends StatelessWidget {
  //need to add user ID from authenticator
  DatabaseReference ref = FirebaseDatabase.instance.ref("users");

  //controllers
  final _firstNameControl = TextEditingController();
  final _lastNameControl = TextEditingController();
  final _emailControl = TextEditingController();
  final _phoneControl = TextEditingController();
  final _companyControl = TextEditingController();
  final _location1Control = TextEditingController();
  final _location2Control = TextEditingController();
  final _location3Control = TextEditingController();
  final _positionControl = TextEditingController();
  final _experienceControl = TextEditingController();

  saveData() async {
    //get lat and log values
    double lat = 0;
    double long = 0;
    try {
      final query = _location1Control.text +
          _location2Control.text +
          _location3Control.text;

      var addresses = await Geocoder.local.findAddressesFromQuery(query);
      var first = addresses.first;
      print("${first.featureName} : ${first.coordinates}");

      lat = addresses.first.coordinates.latitude;
      long = addresses.first.coordinates.latitude;
    } catch (e) {
      print("error in getting address coordinates");
    }

    var userID = _emailControl.text; //maybe use a hash code?
    ref = FirebaseDatabase.instance.ref("users/$userID");
    ref.set({
      "first name": _firstNameControl.text,
      "last name": _lastNameControl.text,
      "email": _emailControl.text,
      "phone": _phoneControl.text,
      "company": _companyControl.text,
      "street address": _location1Control.text,
      "city address": _location2Control.text,
      "state address": _location3Control.text,
      "lat": lat,
      "long": long,
      "position": _positionControl.text,
      "experience": _experienceControl.text
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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
                      child: TextField(
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
                      child: TextField(
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
                      child: TextField(
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
                      child: TextField(
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
                      child: TextField(
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
                      child: TextField(
                        controller: _location1Control,
                        style: TextStyle(color: Colors.black),
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Street Address',
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
                      child: TextField(
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
                      child: TextField(
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
                      child: TextField(
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
                      child: TextField(
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 300),
                  child: ElevatedButton(
                    onPressed: () {},
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
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
                ),
              ],
            ),
          ),
        ),
      ));
}
