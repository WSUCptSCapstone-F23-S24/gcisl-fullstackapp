// ignore_for_file: file_names, prefer_const_constructors, use_key_in_widget_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gcisl_app/palette.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
    getUserData();
    getMarkerData();
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
                element.child("last name").value.toString()),
        onTap: () {
          for (var e = 0; e < userInfo.length; e++) {
            if (userInfo[e][0] ==
                    element.child("first name").value.toString() &&
                userInfo[e][1] == element.child("last name").value.toString() &&
                userInfo[e][6] ==
                    double.tryParse(element.child("phone").value.toString())) {
              mapController.animateCamera(CameraUpdate.newCameraPosition(
                  CameraPosition(
                      target: LatLng(userInfo[e][4], userInfo[e][5]),
                      zoom: 10)));
              setState(() {
                _selectedIndex = e;
              });
            }
          }
        });
    setState(() {
      markers[markerId] = marker;
    });
  }

  getMarkerData() async {
    await FirebaseDatabase.instance
        .ref('users')
        .get()
        // ignore: avoid_function_literals_in_foreach_calls
        .then((snapshot) => snapshot.children.forEach((element) {
              initMarker(element);
            }));
  }

  getUserData() async {
    List user = [];
    await FirebaseDatabase.instance
        .ref('users')
        .get()
        .then((snapshot) => snapshot.children.forEach((element) {
              user.add([
                element.child("first name").value.toString(),
                element.child("last name").value.toString(),
                element.child("city address").value.toString(),
                element.child("state address").value.toString(),
                double.tryParse(element.child("lat").value.toString()),
                double.tryParse(element.child("long").value.toString()),
                double.tryParse(element.child("phone").value.toString()),
                element.child("email").value.toString(),
                element.child("company").value.toString(),
                element.child("position").value.toString(),
                element.child("profile picture").value.toString(),
              ]);
            }));

    userInfo = user;
  }

  String getInitials(String fullName) {
    List<String> nameParts = fullName.split(" ");
    String initials = "";
    for (int i = 0; i < nameParts.length; i++) {
      if (nameParts[i].isNotEmpty) {
        String initial = nameParts[i][0];
        initials += initial;
      }
    }
    initials = initials.toUpperCase();
    return initials;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
          body: Container(
        // padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
        color: Colors.white,
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  // margin: EdgeInsets.fromLTRB(
                  //     0, 0, 0, MediaQuery.of(context).size.height * 0.01),
                  width: MediaQuery.of(context).size.width * 0.30,
                  height: MediaQuery.of(context).size.height * 1,
                  color: Colors.white,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          // margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          height: 30,
                          child: Column(children: [
                            const SizedBox(
                              height: 5,
                            ),
                            Expanded(
                              child: Text("Find People",
                                  style: TextStyle(fontSize: 20)),
                            ),
                          ]),
                        ),
                        //Divider(height: 0),
                        ListView.builder(
                            itemCount: userInfo.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return Container(
                                  color: _selectedIndex == index
                                      ? Colors.blueGrey.shade50
                                      : Colors.white,
                                  child: ListTile(
                                    leading: userInfo[index][10] == "null"
                                        ? CircleAvatar(
                                            child: Text(
                                              getInitials(userInfo[index][0] +
                                                  " " +
                                                  userInfo[index][1]),
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Color.fromARGB(
                                                      255, 130, 125, 125)),
                                            ),
                                            radius: 25,
                                          )
                                        : CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                userInfo[index][10]),
                                            radius: 25,
                                          ),
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
                                                child: Text(
                                              userInfo[index][0] +
                                                  " " +
                                                  userInfo[index][1] +
                                                  "\n",
                                              style: TextStyle(
                                                  color: _selectedIndex == index
                                                      ? Color.fromARGB(
                                                          255, 217, 10, 51)
                                                      : Colors.black),
                                            )),
                                            Spacer(flex: 1),
                                            Expanded(
                                              child: Text(
                                                userInfo[index][2] +
                                                    ", " +
                                                    userInfo[index][3],
                                                style: TextStyle(
                                                    color: _selectedIndex ==
                                                            index
                                                        ? Color.fromARGB(
                                                            255, 217, 10, 51)
                                                        : Colors.black),
                                              ),
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
              SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                          //margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          width: MediaQuery.of(context).size.width * 0.70,
                          height: MediaQuery.of(context).size.height * 0.65,
                          /*padding:
                          EdgeInsets.only(bottom: 1, top: 1, right: 1, left: 1),*/
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
                              cameraTargetBounds: CameraTargetBounds(
                                  LatLngBounds(
                                      southwest: LatLng(-90, -180),
                                      northeast: LatLng(90, 180))),
                            ),
                            Align(
                                alignment: Alignment(-0.97, 0.85),
                                child: FloatingActionButton(
                                  onPressed: () => {
                                    mapController.animateCamera(
                                        CameraUpdate.newCameraPosition(
                                            CameraPosition(
                                      target: _center,
                                      zoom: 1.5,
                                    )))
                                  },
                                  backgroundColor: Palette.ktoGray,
                                  child: Icon(Icons.gps_fixed_rounded),
                                ))
                          ])),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.70,
                        height: MediaQuery.of(context).size.height * 0.29,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black, width: 2)),
                        child: userInfo.isNotEmpty
                            ? buildUserInfoWidget(userInfo, _selectedIndex)
                            : Container(), // Placeholder if userInfo is empty
                      )
                    ]),
              ),
            ]),
      ));

  Widget buildUserInfoWidget(List userInfo, int selectedIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.all(10),
          color: Colors.grey[200],
          child: Text(
            '${userInfo[selectedIndex][0]} ${userInfo[selectedIndex][1]}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 10),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'City',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5),
                      Text(
                        '${userInfo[selectedIndex][2]}',
                        style: TextStyle(fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height:5),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Company',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5),
                      Text(
                        '${userInfo[selectedIndex][3]}',
                        style: TextStyle(fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height:5),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Email',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5),
                      Text(
                        '${userInfo[selectedIndex][7]}',
                        style: TextStyle(fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height:5),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Job Title',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5),
                      Text(
                        '${userInfo[selectedIndex][8]}',
                        style: TextStyle(fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height:5),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
