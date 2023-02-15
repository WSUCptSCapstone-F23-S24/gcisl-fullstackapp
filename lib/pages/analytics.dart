// ignore_for_file: file_names, prefer_const_constructors, use_key_in_widget_constructors

import 'dart:html';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gcisl_app/palette.dart';
import '../main_widgets/appbar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class AnalyticsPage extends StatefulWidget {
  @override
  State<AnalyticsPage> createState() => _AnalyticsPage();
}

class _AnalyticsPage extends State<AnalyticsPage> {
  late GoogleMapController mapController;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  final LatLng _center = const LatLng(0, 0);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    getMarkerData();
    super.initState();
  }

  void initMarker(element) async {
    var markerIdVal = element.child("first name").value;
    final MarkerId markerId = MarkerId(markerIdVal);
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(element.child("lat").value, element.child("long").value),
      infoWindow:
          InfoWindow(title: element.child("first name").value.toString() + " ".toString() + element.child("last name").value.toString())
    );
    setState(() {
      markers[markerId] = marker;
    });
  }

  getMarkerData() async {
    await FirebaseDatabase.instance
        .ref('users')
        .get()
        .then((snapshot) => snapshot.children.forEach((element) {
              initMarker(element);
            }));
  }

  Set<Marker> getMarker() {
    return <Marker>[
      Marker(
          markerId: MarkerId('Test'),
          position: _center,
          icon: BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(title: 'Test'))
    ].toSet();
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
                    width: 800,
                    height: 800,
                    padding:
                        EdgeInsets.only(bottom: 1, top: 1, right: 1, left: 1),
                    child: GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: _center,
                        zoom: 1,
                      ),
                      markers: Set<Marker>.of(markers.values),
                      minMaxZoomPreference: MinMaxZoomPreference(1, 10),
                    ),
                  ),
                ]),
                // Spacer(),
                // Row(
                //   children: [Text("data")],
                // )
              ]),
        ),
      );
}
