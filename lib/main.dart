// ignore_for_file: prefer_const_constructors, unused_import

import 'package:flutter/material.dart';
import 'pallete.dart';
import 'pages/home.dart';
import 'pages/profile.dart';
import 'pages/messages.dart';
import 'pages/analytics.dart';
import 'main_widgets/appbar.dart';

void main() {
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
      home: const MyHomePage(title: 'Cobb Connect'),
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
  int _counter = 0;
  String name = "";

  void _incrementCounter() {
    setState(() {
      _counter++;
      if (_counter % 2 == 0) {
        name = "Cobb";
      } else {
        name = "Connect";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HeaderNav(context, widget.title),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/GCISL_logo.png'),
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter : $name',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
