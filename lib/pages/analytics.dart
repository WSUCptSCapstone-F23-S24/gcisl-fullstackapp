// ignore_for_file: file_names, prefer_const_constructors, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import '../main_widgets/appbar.dart';

class AnalyticsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: HeaderNav(context, 'Analytics'),
      );
}
