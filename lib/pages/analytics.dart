// ignore_for_file: file_names, prefer_const_constructors, use_key_in_widget_constructors

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gcisl_app/palette.dart';
import '../main_widgets/appbar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AnalyticsPage extends StatefulWidget {
  @override
  State<AnalyticsPage> createState() => _AnalyticsPage();
}

class _AnalyticsPage extends State<AnalyticsPage> {
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(0, 0);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
          color: Palette.ktoCrimson,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(children: [
                  Container(
                    width: 400,
                    height: 300,
                    child: GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: _center,
                        zoom: 1,
                      ),
                      markers: {
                        Marker(markerId: MarkerId("person"), position: _center)
                      },
                      minMaxZoomPreference: MinMaxZoomPreference(1, 10),
                    ),
                  ),
                ]),
                Spacer(),
                Row(
                  children: [Text("data")],
                )
              ]),
        ),
      );
}
