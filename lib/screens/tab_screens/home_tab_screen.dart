import 'package:drivers_app/main.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../global/global.dart';
import '../../assistants/assistant_methods.dart';

class HomeTabScreen extends StatefulWidget {
  const HomeTabScreen({Key? key}) : super(key: key);

  @override
  _HomeTabScreenState createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen> {
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? _newGoogleMapController;
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  Position? driverCurrentPosiiton;
  var geoLocator = Geolocator();
  LocationPermission? _locationPermission;
  String statusText = "Now Offline";
  Color statusButtonColor = Colors.grey;
  bool isDriverActive = false;

  void _blackThemeGoogleMap() {
    _newGoogleMapController!.setMapStyle('''
                    [
                      {
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#242f3e"
                          }
                        ]
                      },
                      {
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#746855"
                          }
                        ]
                      },
                      {
                        "elementType": "labels.text.stroke",
                        "stylers": [
                          {
                            "color": "#242f3e"
                          }
                        ]
                      },
                      {
                        "featureType": "administrative.locality",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "poi",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "poi.park",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#263c3f"
                          }
                        ]
                      },
                      {
                        "featureType": "poi.park",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#6b9a76"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#38414e"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "geometry.stroke",
                        "stylers": [
                          {
                            "color": "#212a37"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#9ca5b3"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#746855"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "geometry.stroke",
                        "stylers": [
                          {
                            "color": "#1f2835"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#f3d19c"
                          }
                        ]
                      },
                      {
                        "featureType": "transit",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#2f3948"
                          }
                        ]
                      },
                      {
                        "featureType": "transit.station",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#17263c"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#515c6d"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "labels.text.stroke",
                        "stylers": [
                          {
                            "color": "#17263c"
                          }
                        ]
                      }
                    ]
                ''');
  }

  void _locateDriverPosition() async {
    Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    driverCurrentPosiiton = currentPosition;
    LatLng latLngPosition = LatLng(
        driverCurrentPosiiton!.latitude, driverCurrentPosiiton!.longitude);
    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 14);
    _newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    String humanReadableAddress =
        await AssistantMethods.searchAddressForGeographicCoordinates(
            driverCurrentPosiiton!, context);
  }

  void _checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();
    if (_locationPermission == LocationPermission.denied) {
      print("Access denied");
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  void _driverIsOnlineNow() async {
    Position currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    driverCurrentPosiiton = currentPosition;

    Geofire.initialize("activeDrivers");
    Geofire.setLocation(
      currentFirebaseUser!.uid,
      driverCurrentPosiiton!.latitude,
      driverCurrentPosiiton!.longitude,
    );
    DatabaseReference ref = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentFirebaseUser!.uid)
        .child("newRideStatus");
    ref.set("idle"); // searching for ride request
    ref.onValue.listen((event) {
      // print while listening
    });
  }

  void _updateDriversLocationAtRealTime() {
    streamSubscriptionPosition = Geolocator.getPositionStream().listen(
      (Position position) {
        driverCurrentPosiiton = position;
        if (isDriverActive == true) {
          Geofire.setLocation(
            currentFirebaseUser!.uid,
            driverCurrentPosiiton!.latitude,
            driverCurrentPosiiton!.longitude,
          );
        }
        LatLng latLng = LatLng(
          driverCurrentPosiiton!.latitude,
          driverCurrentPosiiton!.longitude,
        );
        _newGoogleMapController!.animateCamera(
          CameraUpdate.newLatLng(latLng),
        );
      },
    );
  }

  void _driverIsOfflineNow() {
    Geofire.removeLocation(currentFirebaseUser!.uid);
    DatabaseReference? ref = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentFirebaseUser!.uid)
        .child("newRideStatus");
    ref.onDisconnect();
    ref.remove();
    ref = null;
    Future.delayed(
      const Duration(milliseconds: 2000),
      () {
        // SystemChannels.platform.invokeMethod("SystemNavigator.pop");
        SystemNavigator.pop();
        // MyApp.restartApp(context);
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkIfLocationPermissionAllowed();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.normal,
          myLocationEnabled: true,
          initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controller) {
            _controllerGoogleMap.complete(controller);
            _newGoogleMapController = controller;

            // Black Theme
            _blackThemeGoogleMap();
            // Locate Driver Position
            _locateDriverPosition();
          },
        ),

        // UI for online and offline drivers
        statusText != "Now Online"
            ? Container(
                height: MediaQuery.of(context).size.height,
                width: double.infinity,
                color: Colors.black54,
              )
            : Container(),

        // button for online offline driver
        Positioned(
          top: statusText != "Now Online"
              ? MediaQuery.of(context).size.height * 0.46
              : 25,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Offline
                  if (isDriverActive != true) {
                    _driverIsOnlineNow();
                    _updateDriversLocationAtRealTime();
                    setState(() {
                      statusText = "Now Online";
                      isDriverActive = true;
                      statusButtonColor = Colors.transparent;
                    });
                    // Display Toast
                    Fluttertoast.showToast(msg: "You are online now!");
                  } else {
                    _driverIsOfflineNow();
                    setState(() {
                      statusText = "Now Offline";
                      isDriverActive = false;
                      statusButtonColor = Colors.grey;
                    });
                    // Display Toast
                    Fluttertoast.showToast(msg: "You are offline now!");
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: statusButtonColor,
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: statusText != "Now Online"
                    ? Text(
                        statusText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.phonelink_ring,
                        color: Colors.white,
                        size: 26,
                      ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
