import 'dart:math';
import 'dart:html';
import 'dart:async';
import 'dart:core';
import 'package:uuid/uuid.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'image.dart';
import '../palette.dart';
import 'dart:typed_data';

class User {
  final String name;
  final String lastName;
  final String email;
  final String country;
  final String city;
  final String state;
  final String zipcode;
  final String company;
  final String position;
  final String phone;
  bool isAdmin;

  User({
    required this.name,
    required this.lastName,
    required this.email,
    required this.country,
    required this.city,
    required this.state,
    required this.zipcode,
    required this.company,
    required this.position,
    required this.phone,
    required this.isAdmin,
  });
}

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.reference().child('users');
  List<User> userList = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  void fetchUsers() {
    _database.once().then((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      Map<dynamic, dynamic>? usersData = snapshot.value as Map<dynamic, dynamic>?;
      userList.clear();

      if (usersData != null) {
        usersData.forEach((key, value) {
          if(value['email'] == "admin@wsu.edu")
            return;
          bool isAdmin = value['isAdmin'] != null ? value['isAdmin'] as bool : false;
          var user = User(
            name: value['first name'],
            lastName: value['last name'],
            email: value['email'],
            country: value['country address'],
            city: value['city address'],
            state: value['state address'],
            zipcode: value['zip address'],
            company: value['company'],
            position: value['position'],
            phone: value['phone'],
            isAdmin: isAdmin,
          );

          setState(() {
            userList.add(user);
          });
        });
      }
    });
  }


  void changeAdmin(User u)
  {
    print("Changing ${u.email} admin's status to ${u.isAdmin}");
    DatabaseReference ref = FirebaseDatabase.instance.ref("users/${u.email.hashCode}");
    ref.update({'isAdmin' : !u.isAdmin});
    u.isAdmin = !u.isAdmin;
  }


  void deleteUser(User user) {
    print("Delete User");
    setState(() {
      userList.remove(user);
    });

    _database.child(user.email).remove();
  }

  void exportToCSV() async {
    StringBuffer csvBuffer = StringBuffer();
    csvBuffer.writeln('Name,Last Name,Email,Phone,Country,City,State,Zipcode,Company,Position');

    for (User user in userList) {
      csvBuffer.writeln(
          '${user.name},${user.lastName},${user.email},${user.phone},${user.country},${user.city},${user.state},${user.zipcode},${user.company},${user.position}');
    }
    final blob = Blob([Blob([Uint8List.fromList(csvBuffer.toString().codeUnits)], 'text/plain')]);

    final url = Url.createObjectUrlFromBlob(blob);

    final anchor = AnchorElement(href: url)
      ..target = 'download'
      ..download = 'users.csv'
      ..click();

    Url.revokeObjectUrl(url);

  }

  @override
   Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List'),
        backgroundColor: Palette.ktoCrimson,
        actions: [
          IconButton(
            icon: Icon(Icons.file_download),
            onPressed: () {
              exportToCSV();
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: userList.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            elevation: 3,
            margin: EdgeInsets.all(10),
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${userList[index].name} ${userList[index].lastName}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 10), // Add vertical spacing

                  Text(
                    'Email: ${userList[index].email}',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Phone: ${userList[index].phone}',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Country: ${userList[index].country}',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    'State: ${userList[index].state}',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    'City: ${userList[index].city}',
                    style: TextStyle(fontSize: 16),
                  ),
                  if (userList[index].zipcode != null)
                    Text(
                      'Zipcode: ${userList[index].zipcode}',
                      style: TextStyle(fontSize: 16),
                    ),
                  Text(
                    'Company: ${userList[index].company}',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Position: ${userList[index].position}',
                    style: TextStyle(fontSize: 16),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            changeAdmin(userList[index]);
                          });
                        },
                        child: Text(
                          userList[index].isAdmin ? "Revoke Admin" : "Set As Admin",
                        ),
                      ),
                      // IconButton(
                      //   icon: Icon(Icons.delete),
                      //   onPressed: () {
                      //     deleteUser(userList[index]);
                      //   },
                      // ),
                    ],
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.end,
                  //   children: [
                  //     IconButton(
                  //       icon: Icon(Icons.delete),
                  //       onPressed: () {
                  //         deleteUser(userList[index]);
                  //       },
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
