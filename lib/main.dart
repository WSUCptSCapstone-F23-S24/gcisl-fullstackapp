// ignore_for_file: prefer_const_constructors, unused_import, prefer_const_literals_to_create_immutables, prefer_final_fields, unused_field, prefer_interpolation_to_compose_strings, avoid_unnecessary_containers

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gcisl_app/pages/messaging.dart';
import 'package:gcisl_app/pages/newprofile.dart';
import 'package:gcisl_app/pages/signout.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:gcisl_app/auth/auth_page.dart';
import 'package:gcisl_app/pages/signin.dart';
import 'package:gcisl_app/pages/register.dart';

import 'palette.dart';
import 'pages/home.dart';
import 'pages/profile.dart';
import 'pages/messages.dart';
import 'pages/analytics.dart';
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
  int index = 0;

  var uID = FirebaseAuth.instance.currentUser;

  var screens = [
    MyHomePage(title: "Granger Cobb Institute for Senior Living"),
    Text("dummy"),
    MyHomePage(title: "Granger Cobb Institute for Senior Living"),
    ProfilePage(),
    ChatPage(),
    AnalyticsPage(),
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
          NewProfilePage(),
          ChatPage(),
          AnalyticsPage(),
          Text("dummey"),
          AuthPage()
        ];
      } else {
        screens = [
          MyHomePage(title: "Granger Cobb Institute for Senior Living"),
          Text("dummy"),
          MyHomePage(title: "Granger Cobb Institute for Senior Living"),
          NewProfilePage(),
          ChatPage(),
          AnalyticsPage(),
          Text("dummey"),
          SignOut(),
        ];
      }
    });
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
            body: screens[index],
            appBar: AppBar(
              flexibleSpace: NavigationBarTheme(
                data:
                    NavigationBarThemeData(indicatorColor: Palette.ktoCrimson),
                child: NavigationBar(
                    height: 60,
                    selectedIndex: index,
                    onDestinationSelected: (index) {
                      _updateScreens();
                      setState(() => this.index = index);
                    },
                    destinations: [
                      Container(
                        child: NavigationDestination(
                            icon: ImageIcon(AssetImage("cougar.png"), size: 30),
                            label: "Cobb Connect"),
                      ),
                      Container(
                        padding: EdgeInsets.only(right: 100, left: 100),
                      ),
                      Container(
                        child: NavigationDestination(
                            icon: Icon(Icons.house_outlined), label: "Home"),
                      ),
                      Container(
                        child: NavigationDestination(
                            icon: Icon(Icons.person_add_alt_1_outlined),
                            label: "Profile"),
                      ),
                      Container(
                        child: NavigationDestination(
                            icon: Icon(Icons.email_outlined),
                            label: "Messages"),
                      ),
                      Container(
                        child: NavigationDestination(
                            icon: Icon(Icons.graphic_eq_outlined),
                            label: "Analytics"),
                      ),
                      Container(
                        padding: EdgeInsets.only(right: 100, left: 100),
                      ),
                      Container(
                          child: NavigationDestination(
                        icon: FirebaseAuth.instance.currentUser == null
                            ? Icon(Icons.person_outline)
                            : Icon(Icons.person_off_outlined),
                        label: FirebaseAuth.instance.currentUser == null
                            ? "Sign in"
                            : "Sign Out",
                      ))
                    ]),
              ),
            )),
      );
}
