// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors

import 'package:flutter/material.dart';
import '../main_widgets/appbar.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: HeaderNav(context, 'Profile'),
      );
}
