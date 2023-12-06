// ignore_for_file: prefer_const_constructors, unused_import, prefer_const_literals_to_create_immutables, prefer_final_fields, unused_field, prefer_interpolation_to_compose_strings, avoid_unnecessary_containers

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gcisl_app/pages/messaging.dart';
import 'package:gcisl_app/pages/signout.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:gcisl_app/auth/auth_page.dart';
import 'package:gcisl_app/pages/signin.dart';
import 'package:gcisl_app/pages/resetpasswd.dart';
import 'package:gcisl_app/pages/register.dart';
import 'package:gcisl_app/pages/public_profile.dart';

import 'palette.dart';
import 'pages/home.dart';
import 'pages/profile.dart';
import 'pages/public_profile.dart';
import 'pages/messages.dart';
import 'pages/analytics.dart';
import 'pages/admin.dart';
import 'main_widgets/appbar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.web);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var uID = FirebaseAuth.instance.currentUser;
  int index = 0;
  bool hideLabels = false;

  var screens = [
    MyHomePage(title: "Granger Cobb Institute for Senior Living"),
    Text("dummy"),
    MyHomePage(title: "Granger Cobb Institute for Senior Living"),
    ProfilePage(),
    ProfilePage1(FirebaseAuth.instance.currentUser?.email?.hashCode.toString(), false),
    ChatPage(),
    AnalyticsPage(),
    if(FirebaseAuth.instance.currentUser != null && FirebaseAuth.instance.currentUser!.email == "admin@wsu.edu")
            AdminPage(title: "Admin"),
    Text("dummey"),
    AuthPage()
  ];

  void _updateScreens() {
    setState(() {
      if (FirebaseAuth.instance.currentUser == null) {
        screens = [
          MyHomePage(title: "Granger Cobb Institute for Senior Living"),
          Text("dummy"),
          MyHomePage(title: "Granger Cobb Institute for Senior Living"),
          ProfilePage(),
          ProfilePage1(FirebaseAuth.instance.currentUser?.email?.hashCode.toString(), false),
          ChatPage(),
          AnalyticsPage(),
          Text("dummey"),
          Text("dummey"),
          AuthPage()
        ];
      } else {
        screens = [
          MyHomePage(title: "Granger Cobb Institute for Senior Living"),
          Text("dummy"),
          MyHomePage(title: "Granger Cobb Institute for Senior Living"),
          ProfilePage(),
          ProfilePage1(FirebaseAuth.instance.currentUser?.email?.hashCode.toString(), false),
          ChatPage(),
          AnalyticsPage(),
          if(FirebaseAuth.instance.currentUser != null && FirebaseAuth.instance.currentUser!.email == "admin@wsu.edu")
            AdminPage(title: "Admin"),
          Text("dummey"),
          SignOut(),
        ];
      }
    });
  }

  @override
  Widget build(BuildContext context) => MaterialApp(home: LayoutBuilder(
        builder: (context, constraints) {
          var screenWidth = constraints.maxWidth;
          // You can access the current window width using constraints.maxWidth
          // and update your UI or execute a function accordingly
          if (screenWidth < 600) {
            // Set a flag to true if screen width is below 1000
            hideLabels = true;
          } else {
            // Set the flag to false if screen width is 1000 or above
            hideLabels = false;
          }
          // Set index to login if user not logged in
          if (FirebaseAuth.instance.currentUser == null) {
            index = 8;
            if(FirebaseAuth.instance.currentUser != null && FirebaseAuth.instance.currentUser!.email == "admin@wsu.edu")
              index += 1;
          }
          return Scaffold(
              body: screens[index],
              appBar: AppBar(
                flexibleSpace: NavigationBarTheme(
                  data: NavigationBarThemeData(
                      indicatorColor: Palette.ktoCrimson),
                  child: NavigationBar(
                      height: 60,
                      selectedIndex: index,
                      onDestinationSelected: (selectedindex) {
                        // Don't allow users to go to other pages until signed in
                        if (FirebaseAuth.instance.currentUser == null) {
                          selectedindex = 8;
                          if(FirebaseAuth.instance.currentUser != null && FirebaseAuth.instance.currentUser!.email == "admin@wsu.edu")
                            selectedindex += 1;
                        }
                        _updateScreens();
                        setState(() => index = selectedindex);
                      },
                      destinations: [
                        Container(
                          child: NavigationDestination(
                            icon: ImageIcon(AssetImage("assets/cougar.png"),
                                size: 30),
                            label: hideLabels
                                ? ""
                                : "Cobb Connect", // hide label if hideLabels is true
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(right: 100, left: 100),
                        ),
                        Container(
                          child: NavigationDestination(
                            icon: Icon(Icons.house_outlined),
                            label: hideLabels ? "" : "Home",
                          ),
                        ),
                        Container(
                          child: NavigationDestination(
                              icon: Icon(Icons.person_add_alt_1_outlined),
                              label: hideLabels ? "" : "Edit Profile"),
                        ),
                        Container(
                          child: NavigationDestination(
                              icon: Icon(Icons.person_2_outlined),
                              label: hideLabels ? "" : "Profile"),
                        ),
                        Container(
                          child: NavigationDestination(
                              icon: Icon(Icons.email_outlined),
                              label: hideLabels ? "" : "Messages"),
                        ),
                        Container(
                          child: NavigationDestination(
                            icon: Icon(Icons.graphic_eq_outlined),
                            label: hideLabels ? "" : "Analytics",
                          ),
                        ),
                        if(FirebaseAuth.instance.currentUser != null && FirebaseAuth.instance.currentUser!.email == "admin@wsu.edu")
                          Container(
                            child: NavigationDestination(
                              icon: Icon(Icons.add_chart),
                              label: hideLabels ? "" : "Admin",
                            ),
                          ),
                        Container(
                          padding: EdgeInsets.only(right: 100, left: 100),
                        ),
                        if (FirebaseAuth.instance.currentUser != null)
                          Container(
                              child: NavigationDestination(
                            icon: Icon(Icons.person_off_outlined),
                            label: hideLabels ? "" : "Sign Out",
                          ))
                      ]),
                ),
              ));
        },
      ));
}
