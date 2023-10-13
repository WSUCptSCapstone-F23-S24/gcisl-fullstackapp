import 'package:flutter/material.dart';

import 'dart:html';

import 'package:csc_picker/csc_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocode/geocode.dart';
import 'package:geocoding/geocoding.dart';

import '../palette.dart';

class ProfilePage1 extends StatefulWidget {
  String? emailHashString = "";
  ProfilePage1(this.emailHashString);
  @override
  _ProfilePage1State createState() => _ProfilePage1State();
}

class _ProfilePage1State extends State<ProfilePage1> {
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
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _zipcodeController = TextEditingController();
  TextEditingController _companyController = TextEditingController();
  TextEditingController _companyPositionController = TextEditingController();
  TextEditingController _countryAddressController = TextEditingController();

  DatabaseReference ref = FirebaseDatabase.instance.ref("users");

  getCurrentUser() async {
    await FirebaseDatabase.instance
        .ref('users')
        .get()
        // ignore: avoid_function_literals_in_foreach_calls
        .then((snapshot) => snapshot.children.forEach((element) {
              if (element.key.toString() == widget.emailHashString) {
               _nameController.text = element.child("first name").value.toString()
                   + " "
                   + element.child("last name").value.toString();
               _companyPositionController.text = element.child("position").value.toString();
                _phoneController.text = element.child("phone").value.toString();
                _zipcodeController.text =
                    element.child("zip address").value.toString();
                _companyController.text =
                    element.child("company").value.toString();
                _companyPositionController.text =
                    element.child("position").value.toString();
                _countryAddressController.text =
                    element.child("country address").value.toString();
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Expanded(flex: 1, child: _TopPortion()),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    readOnly: true,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 16.0),
                      FloatingActionButton.extended(
                        onPressed: () {},
                        heroTag: 'message',
                        elevation: 0,
                        backgroundColor: Colors.red,
                        label: const Text("Message"),
                        icon: const Icon(Icons.message_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _ProfileInfoRow(_companyPositionController, _companyController, _countryAddressController, _phoneController)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class _ProfileInfoRow extends StatefulWidget {
  TextEditingController companyPositionController = TextEditingController();
  TextEditingController companyController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  _ProfileInfoRow(this.companyPositionController, this.companyController, this.countryController, this.phoneController);

  final List<ProfileInfoItem> _items = const [
    ProfileInfoItem("Company", 1),
    ProfileInfoItem("Company Position", 2),
    ProfileInfoItem("Country", 3),
    ProfileInfoItem("Phone Number", 4)
  ];

  TextEditingController getController(int value) {
    if(value == 1) { return companyController;} 
    else if(value == 2) {return companyPositionController;}
    else if(value == 3) {return countryController;}
    else if(value == 4) {return phoneController;}
    else {return companyController;}
    }

  @override
  _ProfileInfoRowState createState() => _ProfileInfoRowState();
}

class _ProfileInfoRowState extends State<_ProfileInfoRow> {
  //const _ProfileInfoRowState({Key? key}) : super(key: key);

   @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: widget._items
            .map((item) => Expanded(
                    child: Row(
                  children: [
                    if (widget._items.indexOf(item) != 0) const VerticalDivider(),
                    Expanded(child: _singleItem(context, item)),
                  ],
                )))
            .toList(),
      ),
    );
  }

  Widget _singleItem(BuildContext context, ProfileInfoItem item) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              //item.value.toString(),
              controller: widget.getController(item.value),
              readOnly: true,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          Text(
            item.title,
            style: Theme.of(context).textTheme.caption,
          )
        ],
      );
}

class ProfileInfoItem {
  final String title;
  final int value;
  const ProfileInfoItem(this.title, this.value);
}

class _TopPortion extends StatelessWidget {
  const _TopPortion({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 50),
          decoration: const BoxDecoration(
              color: Palette.ktoCrimson,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              )),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: 150,
            height: 150,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(
                            'https://www.booksie.com/files/profiles/22/mr-anonymous_230x230.png')),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      decoration: const BoxDecoration(
                          color: Colors.green, shape: BoxShape.circle),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
