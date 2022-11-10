// ignore_for_file: non_constant_identifier_names, unused_import, unnecessary_const, duplicate_ignore, unnecessary_new, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:gcisl_app/pallete.dart';
import '../pages/home.dart';
import '../pages/profile.dart';
import '../pages/messages.dart';
import '../pages/analytics.dart';

AppBar HeaderNav(BuildContext context, String title) {
  switch (title) {
    case 'Home':
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
                        color: Colors.white,
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
                    child: ElevatedButton.icon(
                      onPressed: () => selectedItem(context, 1),
                      icon: Icon(
                        Icons.portrait_rounded,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Profile',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  new Flexible(
                    child: ElevatedButton.icon(
                      onPressed: () => selectedItem(context, 2),
                      icon: Icon(
                        Icons.message_rounded,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Messages',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  new Flexible(
                    child: ElevatedButton.icon(
                      onPressed: () => selectedItem(context, 3),
                      icon: Icon(
                        Icons.analytics_rounded,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Analytics',
                        // ignore: unnecessary_const
                        style: const TextStyle(
                          color: Colors.white,
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
                onPressed: () {},
              ),
            )
          ],
        ),
      ));

    case 'Profile':
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
                        color: Colors.white,
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
                    child: ElevatedButton.icon(
                      onPressed: () => selectedItem(context, 0),
                      icon: Icon(
                        Icons.home_rounded,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Home',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  new Flexible(
                    child: ElevatedButton.icon(
                      onPressed: () => selectedItem(context, 2),
                      icon: Icon(
                        Icons.message_rounded,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Messages',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  new Flexible(
                    child: ElevatedButton.icon(
                      onPressed: () => selectedItem(context, 3),
                      icon: Icon(
                        Icons.analytics_rounded,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Analytics',
                        // ignore: unnecessary_const
                        style: const TextStyle(
                          color: Colors.white,
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
                onPressed: () {},
              ),
            )
          ],
        ),
      ));

    case 'Messages':
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
                        color: Colors.white,
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
                    child: ElevatedButton.icon(
                      onPressed: () => selectedItem(context, 0),
                      icon: Icon(
                        Icons.home_rounded,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Home',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // ignore: unnecessary_new
                  new Flexible(
                    child: ElevatedButton.icon(
                      onPressed: () => selectedItem(context, 1),
                      icon: Icon(
                        Icons.portrait_rounded,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Profile',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  new Flexible(
                    child: ElevatedButton.icon(
                      onPressed: () => selectedItem(context, 3),
                      icon: Icon(
                        Icons.analytics_rounded,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Analytics',
                        // ignore: unnecessary_const
                        style: const TextStyle(
                          color: Colors.white,
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
                onPressed: () {},
              ),
            )
          ],
        ),
      ));

    case 'Analytics':
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
                        color: Colors.white,
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
                    child: ElevatedButton.icon(
                      onPressed: () => selectedItem(context, 0),
                      icon: Icon(
                        Icons.home_rounded,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Home',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // ignore: unnecessary_new
                  new Flexible(
                    child: ElevatedButton.icon(
                      onPressed: () => selectedItem(context, 1),
                      icon: Icon(
                        Icons.portrait_rounded,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Profile',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  new Flexible(
                    child: ElevatedButton.icon(
                      onPressed: () => selectedItem(context, 2),
                      icon: Icon(
                        Icons.message_rounded,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Messages',
                        style: TextStyle(
                          color: Colors.white,
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
                onPressed: () {},
              ),
            )
          ],
        ),
      ));

    default:
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
                        color: Colors.white,
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
                    child: ElevatedButton.icon(
                      onPressed: () => selectedItem(context, 0),
                      icon: Icon(
                        Icons.home_rounded,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Home',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // ignore: unnecessary_new
                  new Flexible(
                    child: ElevatedButton.icon(
                      onPressed: () => selectedItem(context, 1),
                      icon: Icon(
                        Icons.portrait_rounded,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Profile',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  new Flexible(
                    child: ElevatedButton.icon(
                      onPressed: () => selectedItem(context, 2),
                      icon: Icon(
                        Icons.message_rounded,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Messages',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  new Flexible(
                    child: ElevatedButton.icon(
                      onPressed: () => selectedItem(context, 3),
                      icon: Icon(
                        Icons.analytics_rounded,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Analytics',
                        // ignore: unnecessary_const
                        style: const TextStyle(
                          color: Colors.white,
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
                onPressed: () {},
              ),
            )
          ],
        ),
      ));
  }
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
