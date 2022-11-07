// ignore_for_file: prefer_const_constructors, unused_import

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:gcisl_app/login/email_login.dart';
import 'pallete.dart';
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

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Granger Cobb Institute for Senior Living',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch().copyWith(
              primary: Palette.ktoCrimson, secondary: Palette.ktoCrimson),
          canvasColor: Color.fromARGB(255, 199, 195, 195),
          textTheme: Theme.of(context).textTheme.apply(
                bodyColor: Palette.ktoCrimson,
                displayColor: Palette.ktoCrimson,
              ),
        ),
        home: EmailLogin()
        //home: const MyHomePage(title: 'Cobb Connect'),
        );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar: HeaderNav(context, widget.title),
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          color: Palette.ktoCrimson,
          child: Row(
            children: [
              Expanded(
                child: Image.asset(
                  'assets/GCISL_logo.png',
                  height: 50,
                  width: 120,
                  color: Color.fromARGB(255, 199, 195, 195),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
