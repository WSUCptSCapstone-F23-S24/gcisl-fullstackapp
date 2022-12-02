// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors

import 'package:flutter/material.dart';
import '../main_widgets/appbar.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: HeaderNav(context, 'Profile'),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
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
                      style: TextStyle(color: Colors.black),
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Location',
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
                  onPressed: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => MyHomePage(title : 'Cobb Connect')),
                    // );
                  },
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
      ));
}
