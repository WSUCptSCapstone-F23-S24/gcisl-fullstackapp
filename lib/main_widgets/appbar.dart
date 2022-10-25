// ignore_for_file: non_constant_identifier_names, unused_import, unnecessary_const, duplicate_ignore, unnecessary_new

import 'package:flutter/material.dart';
import '../pages/home.dart';
import '../pages/profile.dart';
import '../pages/messages.dart';
import '../pages/analytics.dart';

final _formKey = GlobalKey<FormState>();

AppBar HeaderNav(BuildContext context, String title) {
  return AppBar(
      title: SingleChildScrollView(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 4,
          child: Row(
            children: [
              new Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 199, 195, 195),
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ignore: unnecessary_new
              new Flexible(
                child: TextButton(
                  onPressed: () => selectedItem(context, 0),
                  child: const Text(
                    'Home',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              // ignore: unnecessary_new
              new Flexible(
                child: TextButton(
                  onPressed: () => selectedItem(context, 1),
                  child: const Text(
                    'Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              new Flexible(
                child: TextButton(
                  onPressed: () => selectedItem(context, 2),
                  child: const Text(
                    'Messages',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              new Flexible(
                child: TextButton(
                  onPressed: () => selectedItem(context, 3),
                  child: const Text(
                    'Analytics',
                    // ignore: unnecessary_const
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Expanded(flex: 3, child: const Text("")),
        Expanded(
          flex: 1,
          child: IconButton(
            iconSize: 30,
            icon: const Icon(
              Icons.settings,
            ),
            // the method which is called
            // when button is pressed
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      insetPadding: const EdgeInsets.all(100),
                      shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0))),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: <Widget>[
                          Positioned(
                            right: -20.0,
                            top: -20.0,
                            child: InkResponse(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: const CircleAvatar(
                                backgroundColor: Colors.red,
                                child: Icon(Icons.close),
                              ),
                            ),
                          ),
                          Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: TextFormField(),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: TextFormField(),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    child: Text("Submit"),
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        _formKey.currentState!.save();
                                      }
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  });
            },
          ),
        )
      ],
    ),
  ));
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
