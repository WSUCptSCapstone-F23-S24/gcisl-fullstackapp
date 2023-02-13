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

  void initMarker(spec, specId) async {
    var markerIdVal = specId;
    final MarkerId markerId = MarkerId(markerIdVal);
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(spec['location'].latitude, spec['location'].longitude),
      // infoWindow:
      //     InfoWindow(title: spec['first name'] + ' ' + spec['last name'])
    );
    setState(() {
      markers[markerId] = marker;
    });
  }

  getUserData() async {
    DatabaseReference r = FirebaseDatabase.instance.ref("users");
    DatabaseEvent e = await r.once();
    print(e.snapshot.value);
  }

  getAllNames() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("users");
    List<String> userIDs = []; //use this to collect the names
    await FirebaseDatabase.instance.ref('users').get().then(
          (snapshot) => snapshot.children.forEach((element) {
            //print(element.ref);
            //print(element.value);
            print(element.child("first name").value);
            print(element.child("last name").value);
          }),
        );

    //Query query = ref.orderByChild("first name");
    //DataSnapshot e = await query.get();
    //need some way to get names extracted from the map that is stored in e.value
  }

  @override
  void initState() {
    //getMarkerData();
    getAllNames();
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
