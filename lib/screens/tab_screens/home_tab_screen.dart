import 'package:drivers_app/push_notifications/push_notification_system.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../assistants/black_theme_google_map.dart';
import '../../global/global.dart';
import '../../assistants/assistant_methods.dart';

class HomeTabScreen extends StatefulWidget {
  const HomeTabScreen({Key? key}) : super(key: key);

  @override
  _HomeTabScreenState createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen> {
  // Set the Google map controller and completer
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? _newGoogleMapController;
  // From google_maps_flutter
  // Initial Position of the Driver before the phone picks the driver position
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  var geoLocator = Geolocator();
  LocationPermission? _locationPermission;
  String statusText = "Now Offline";
  Color statusButtonColor = Colors.grey;
  bool isDriverActive = false;

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

// Listen to Driver Location At RealTime
// Then set it to driverCurrentPosiiton
  void _updateDriversLocationAtRealTime() {
    // Set streamSubscriptionPosition from Global file to Driver live location
    streamSubscriptionPosition = Geolocator.getPositionStream().listen(
      (Position position) {
        // set driverCurrentPositon from Global to streamSubscription Position
        driverCurrentPosiiton = position;
        // Check if driver is ready to receive ride request
        if (isDriverActive == true) {
          // Activate Geofire
          Geofire.setLocation(
            currentFirebaseUser!.uid,
            driverCurrentPosiiton!.latitude,
            driverCurrentPosiiton!.longitude,
          );
        }
        // Get driver current LatLng to display on Map
        LatLng latLng = LatLng(
          driverCurrentPosiiton!.latitude,
          driverCurrentPosiiton!.longitude,
        );
        // Display on Map
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

  void readCurrentDriverInformation() async {
    // ...
    currentFirebaseUser = fAuth.currentUser;
    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentFirebaseUser!.uid)
        .once()
        .then((snapShot) {
      if (snapShot.snapshot.value != null) {
        onlineDriverData.id = (snapShot.snapshot.value as Map)["id"];
        onlineDriverData.name = (snapShot.snapshot.value as Map)["name"];
        onlineDriverData.phone = (snapShot.snapshot.value as Map)["phone"];
        onlineDriverData.email = (snapShot.snapshot.value as Map)["email"];
        onlineDriverData.car_color =
            (snapShot.snapshot.value as Map)["car_details"]["car_color"];
        onlineDriverData.car_model =
            (snapShot.snapshot.value as Map)["car_details"]["car_model"];
        onlineDriverData.car_no =
            (snapShot.snapshot.value as Map)["car_details"]["car_no"];
        onlineDriverData.car_type =
            (snapShot.snapshot.value as Map)["car_details"]["car_type"];
        driverVehicleType =
            (snapShot.snapshot.value as Map)["car_details"]["car_type"];
      } else {
        Fluttertoast.showToast(msg: "User not available at the moment.");
      }
    });
    PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
    pushNotificationSystem.initializeCloudMessaging(context);
    pushNotificationSystem.generateAndGetToken();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkIfLocationPermissionAllowed();
    readCurrentDriverInformation();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Google Map
        GoogleMap(
          mapType: MapType.normal,
          myLocationEnabled: true,
          initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controller) {
            _controllerGoogleMap.complete(controller);
            _newGoogleMapController = controller;

            // Black Theme
            blackThemeGoogleMap(_newGoogleMapController);
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
