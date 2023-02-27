// ignore_for_file: file_names, prefer_const_constructors, use_key_in_widget_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gcisl_app/palette.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';

class AnalyticsPage extends StatefulWidget {
  @override
  State<AnalyticsPage> createState() => _AnalyticsPage();
}

class _AnalyticsPage extends State<AnalyticsPage> {
  late GoogleMapController mapController;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  List userInfo = [];
  final LatLng _center = const LatLng(30, 0);
  BitmapDescriptor customIcon = BitmapDescriptor.defaultMarker;
  int _selectedIndex = 0;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(75, 75)), 'assets/coug_marker.png')
        .then((onValue) {
      customIcon = onValue;
    });
    getMarkerData();
    getUserData();
    super.initState();
  }

  void initMarker(element) async {
    var markerIdVal = element.key;
    final MarkerId markerId = MarkerId(markerIdVal);
    final Marker marker = Marker(
        markerId: markerId,
        position:
            LatLng(element.child("lat").value, element.child("long").value),
        icon: customIcon,
        infoWindow: InfoWindow(
            title: element.child("first name").value.toString() +
                " ".toString() +
                element.child("last name").value.toString()));

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

  getUserData() async {
    await FirebaseDatabase.instance
        .ref('users')
        .get()
        .then((snapshot) => snapshot.children.forEach((element) {
              userInfo.add([
                element.child("first name").value.toString(),
                element.child("last name").value.toString(),
                element.child("city address").value.toString(),
                element.child("state address").value.toString(),
                double.tryParse(element.child("lat").value.toString()),
                double.tryParse(element.child("long").value.toString()),
              ]);
            }));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
          body: Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
        color: Palette.ktoCrimson,
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  margin: EdgeInsets.fromLTRB(
                      0, 0, 0, MediaQuery.of(context).size.height * 0.01),
                  width: MediaQuery.of(context).size.width * 0.30,
                  height: MediaQuery.of(context).size.height * 0.95,
                  color: Colors.white,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                          height: 20,
                          child: Column(children: [
                            Expanded(
                              child: Text("Find People",
                                  style: TextStyle(fontSize: 20)),
                            ),
                          ]),
                        ),
                        Divider(height: 0),
                        ListView.builder(
                            itemCount: userInfo.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return Container(
                                  color: _selectedIndex == index
                                      ? Palette.ktoGray
                                      : Colors.white,
                                  child: ListTile(
                                    leading: Icon(Icons.portrait_rounded,
                                        color: Palette.ktoCrimson),
                                    title: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                                child: Text(userInfo[index][0] +
                                                    "\n" +
                                                    userInfo[index][1])),
                                            Spacer(flex: 1),
                                            Expanded(
                                              child: Text(userInfo[index][2] +
                                                  ", " +
                                                  userInfo[index][3]),
                                            )
                                          ],
                                        ),
                                        Divider(
                                          height: 0,
                                        )
                                      ],
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _selectedIndex = index;
                                      });
                                      mapController.animateCamera(
                                          CameraUpdate.newCameraPosition(
                                              CameraPosition(
                                        target: LatLng(userInfo[index][4],
                                            userInfo[index][5]),
                                        zoom: 10,
                                      )));
                                    },
                                  ));
                            })
                      ],
                    ),
                  )),
              Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    width: MediaQuery.of(context).size.width * 0.60,
                    height: MediaQuery.of(context).size.height * 0.65,
                    padding:
                        EdgeInsets.only(bottom: 1, top: 1, right: 1, left: 1),
                    child: Stack(children: [
                      GoogleMap(
                        onMapCreated: _onMapCreated,
                        // mapType: MapType.normal, //for changing map appearance
                        initialCameraPosition: CameraPosition(
                          target: _center,
                          zoom: 1.9,
                        ),
                        markers: Set<Marker>.of(markers.values),
                        minMaxZoomPreference: MinMaxZoomPreference(1, 23),
                        cameraTargetBounds: CameraTargetBounds(LatLngBounds(
                            southwest: LatLng(-90, -180),
                            northeast: LatLng(90, 180))),
                      ),
                      Align(
                          alignment: Alignment(-0.97, 0.85),
                          child: FloatingActionButton(
                            onPressed: () => {
                              mapController.animateCamera(
                                  CameraUpdate.newCameraPosition(CameraPosition(
                                target: _center,
                                zoom: 1.5,
                              )))
                            },
                            backgroundColor: Palette.ktoGray,
                            child: Icon(Icons.gps_fixed_rounded),
                          ))
                    ])),
                Container(
                  width: MediaQuery.of(context).size.width * 0.60,
                  height: MediaQuery.of(context).size.height * 0.22,
                  color: Colors.white,
                  child: Expanded(
                      child: Text(
                    userInfo[_selectedIndex][0] +
                        "\n" +
                        userInfo[_selectedIndex][1] +
                        "\n" +
                        userInfo[_selectedIndex][2] +
                        "\n" +
                        userInfo[_selectedIndex][3].toString() +
                        "\n" +
                        userInfo[_selectedIndex][4].toString() +
                        "\n" +
                        userInfo[_selectedIndex][5].toString(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  )),
                ),
              ]),
            ]),
      ));
}
