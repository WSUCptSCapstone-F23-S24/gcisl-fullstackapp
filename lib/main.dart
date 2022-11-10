// ignore_for_file: prefer_const_constructors, unused_import, prefer_const_literals_to_create_immutables, prefer_final_fields

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:gcisl_app/auth/auth_page.dart';
import 'package:gcisl_app/pages/signin.dart';
import 'package:gcisl_app/pages/register.dart';

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
      home: const MyHomePage(
        title: "Cobb Connect",
      ),
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
  var _post = TextEditingController();
  List<String> _postList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar: HeaderNav(context, widget.title),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: Color.fromARGB(255, 199, 195, 195),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 5),
              child: Image.asset(
                'assets/GCISL_logo.png',
                height: 50,
                color: Palette.ktoCrimson,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 20),
        alignment: Alignment.topCenter,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Column(),
            ),
            Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Feed"),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: _post,
                        maxLines: 4,
                        cursorColor: Colors.black,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.black12,
                          border: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                          hintStyle: TextStyle(color: Colors.white),
                          hintText: 'Create Post...',
                          suffixIcon: IconButton(
                            splashRadius: 10,
                            onPressed: () => setState(() {
                              if (_post.text.isEmpty) {
                                return;
                              }
                              _postList.add(_post.text);
                              _post.clear();
                            }),
                            icon: Icon(Icons.send_sharp),
                          ),
                        ),
                      ),
                      ListView.builder(
                        itemCount: _postList.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) => Text(_postList[index]),
                      ),
                      SizedBox(height: 20),
                      Text("\u{1F6D1} nothing more to show "),
                    ],
                  ),
                )),
            Expanded(
              flex: 1,
              child: Column(),
            ),
          ],
        ),
      ),
    );
  }

  void selectedItem(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
        break;
      case 1:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProfilePage(),
          ),
        );
        break;
      case 2:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MessagesPage(),
          ),
        );
        break;
      case 3:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AnalyticsPage(),
          ),
        );
        break;
    }
  }
}
