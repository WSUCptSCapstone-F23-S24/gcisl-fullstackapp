// ignore_for_file: file_names, prefer_const_constructors, use_key_in_widget_constructors

import 'dart:html';
import 'dart:math';

import 'package:flutter/material.dart';
import '../main_widgets/appbar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  void initMarker(spec, specId) async {
    var markerIdVal = specId;
    final MarkerId markerId = MarkerId(markerIdVal);
    final Marker marker = Marker(
        markerId: markerId,
        position: LatLng(spec['location'].latitude, spec['location'].longitude),
        infoWindow:
            InfoWindow(title: spec['first name'] + ' ' + spec['last name']));
    setState(() {
      markers[markerId] = marker;
    });
  }

  getMarkerData() async {
    FirebaseFirestore.instance.collection('users').get().then((userData) {
      if (userData.docs.isNotEmpty) {
        for (int i = 0; i < userData.docs.length; i++) {
          initMarker(userData.docs[i], userData.docs[i]);
        }
      }
    });
  }

  @override
  void initState() {
    getMarkerData();
    super.initState();
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
          width: 500,
          height: 400,
          child: GoogleMap(
            onMapCreated: _onMapCreated,
            markers: Set<Marker>.of(markers.values),
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 1,
            ),
            minMaxZoomPreference: MinMaxZoomPreference(1, 10),
          ),
        ),
      );
}
