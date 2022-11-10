// ignore_for_file: unnecessary_const, duplicate_ignore, prefer_const_constructors

//palette.dart
import 'package:flutter/material.dart';

const Map<int, Color> colorCrim = {
  50: Color.fromRGBO(166, 15, 45, .1),
  100: Color.fromRGBO(166, 15, 45, .2),
  200: Color.fromRGBO(166, 15, 45, .3),
  300: Color.fromRGBO(166, 15, 45, .4),
  400: Color.fromRGBO(166, 15, 45, .5),
  500: Color.fromRGBO(166, 15, 45, .6),
  600: Color.fromRGBO(166, 15, 45, .7),
  700: Color.fromRGBO(166, 15, 45, .8),
  800: Color.fromRGBO(166, 15, 45, .9),
  900: Color.fromRGBO(166, 15, 45, 1),
};

const Map<int, Color> colorGray = {
  50: Color.fromRGBO(177, 77, 77, .1),
  100: Color.fromRGBO(177, 77, 77, .2),
  200: Color.fromRGBO(177, 77, 77, .3),
  300: Color.fromRGBO(177, 77, 77, .4),
  400: Color.fromRGBO(177, 77, 77, .5),
  500: Color.fromRGBO(177, 77, 77, .6),
  600: Color.fromRGBO(177, 77, 77, .7),
  700: Color.fromRGBO(177, 77, 77, .8),
  800: Color.fromRGBO(177, 77, 77, .9),
  900: Color.fromRGBO(177, 77, 77, 1),
};

class Palette {
  // ignore: unnecessary_const
  static const MaterialColor ktoCrimson =
      const MaterialColor(0xFFA60F2D, colorCrim);

  static const MaterialColor ktoGray =
      const MaterialColor(0xFF4D4D4D, colorGray);
}
