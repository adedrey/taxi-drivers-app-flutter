import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/models/user_ride_request_information.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../assistants/assistant_methods.dart';
import '../assistants/black_theme_google_map.dart';
import '../widgets/progress_dialog.dart';

class NewTripScreen extends StatefulWidget {
  UserRideRequestInformation? userRideRequestInformation;
  NewTripScreen({this.userRideRequestInformation});

  @override
  _NewTripScreenState createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {
  // Set the Google map controller and completer
  // From dart:async
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? _newTripGoogleMapController;
  // From google_maps_flutter
  // Initial Position of the Driver before the phone picks the driver position
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  // Set Status of button for when driver reaches pickup desgination
  String buttonTitle = "Arrived";
  Color buttonColor = Colors.green;

  // Define Set of Markers and Circles for polyline from Pickup to Destination
  Set<Marker> markersSet = {};
  Set<Circle> circleSet = {};

  // To Draw Polyline and e_points
  List<LatLng> pLineCoOrdinatesList = [];
  Set<Polyline> polyLineSet = {};

  // Decode the encoded points

  // Add Padding to Map to display Google Logo in order for app to be accepted
  double mapPadding = 0;

  // Step 1 - Draw PolyLine from Origin to Destination
  // WHen Driver Accept the User Ride Request
  // Get trip direction info from origin to destination and draw the
  // polyline on the map
  // originLatLng = DriverCurrentPosition
  // destinationLatLng = UserPickupLocation
  // First Scenario
  // WHen Driver Accept the User Ride Request

  // Step 2 - Draw PolyLine from Origin to Destination
  // Driver already picked up the user in his/her car
  // originLatLng = DriverCurrentPosition -> UserPickupLocation
  // destinationLatLng =UserPickupLocation ->  UserDropOffLocation
  Future<void> _drawPolyLineFromOriginToDestination(
      LatLng originLatLng, LatLng destinationLatLng) async {
    // Keep User waiting
    showDialog(
      context: context,
      builder: (context) => ProgressDialog(
        message: "Please wait...",
      ),
    );
    // Obtain the Origin to Destination Direction Details
    // Direction details contains the polyLine e_points and some other info
    var directionDetailsInfo =
        await AssistantMethods.obtainOriginToDestinationDirectionDetails(
            originLatLng, destinationLatLng);
    print("Direction Info");
    print(directionDetailsInfo);
    // Cancel the show dialog
    Navigator.of(context).pop();
    // Decode the encoded points
    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPpointsReultList =
        pPoints.decodePolyline(directionDetailsInfo!.e_points!);
    pLineCoOrdinatesList.clear();
    print("Decoded List");
    print(decodedPpointsReultList);
    // Check if decoded points are not empty
    if (decodedPpointsReultList.isNotEmpty) {
      // Insert each decoded points LatLng in pLineCoOrdinates
      decodedPpointsReultList.forEach(
        (PointLatLng pointLatLng) {
          pLineCoOrdinatesList.add(
            LatLng(pointLatLng.latitude, pointLatLng.longitude),
          );
        },
      );
    }
    print("PolyLineList");
    print(pLineCoOrdinatesList);
    polyLineSet.clear();
    setState(() {
      // Draw the polyLine
      Polyline polyLine = Polyline(
        polylineId: const PolylineId("PolylineID"),
        color: Colors.redAccent,
        jointType: JointType.round,
        points: pLineCoOrdinatesList,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polyLineSet.add(polyLine);
    });
    // Fix polyline zoom
    LatLngBounds boundsLatLng;
    if (originLatLng.latitude > destinationLatLng.latitude &&
        originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: destinationLatLng,
        northeast: originLatLng,
      );
    } else if (originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
        northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude),
      );
    } else if (originLatLng.latitude > destinationLatLng.latitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
        northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude),
      );
    } else {
      boundsLatLng = LatLngBounds(
        southwest: originLatLng,
        northeast: destinationLatLng,
      );
    }
    // Display PolyLine on Map
    _newTripGoogleMapController!
        .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));
    Marker originMarker = Marker(
      markerId: const MarkerId("originId"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );
    Marker destinationMarker = Marker(
      markerId: const MarkerId("destinationId"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
    setState(() {
      markersSet.add(originMarker);
      markersSet.add(destinationMarker);
    });
    Circle originCircle = Circle(
      circleId: const CircleId("originId"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 2,
      strokeColor: Colors.white,
      center: originLatLng,
    );
    Circle destinationCircle = Circle(
      circleId: const CircleId("destinationId"),
      fillColor: Colors.red,
      radius: 12,
      strokeWidth: 2,
      strokeColor: Colors.white,
      center: destinationLatLng,
    );
    setState(() {
      circleSet.add(originCircle);
      circleSet.add(destinationCircle);
    });
  }

  // Assign Driver Detail to UserRideRequest in All RIde Request Table - Database
  saveAssignedDriverDetailsToUserRideRequest() {
    // Get the rideRequest DatabaseReference
    DatabaseReference databaseReference = FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(widget.userRideRequestInformation!.rideRequestId!);
    // Save Driver Current Location
    Map driverLocationDataMap = {
      "latitude": driverCurrentPosiiton!.latitude.toString(),
      "longitude": driverCurrentPosiiton!.longitude.toString(),
    };
    // Set driverLocationDataMap on the database
    databaseReference.child("driverLocation").set(driverLocationDataMap);
    // Set status field of the databseReference to accepted
    databaseReference.child("status").set("accepted");
    // setdriver details
    databaseReference.child("driverId").set(onlineDriverData.id);
    databaseReference.child("driverName").set(onlineDriverData.name);
    databaseReference.child("driverPhone").set(onlineDriverData.phone);
    databaseReference.child("driverEmail").set(onlineDriverData.email);
    databaseReference.child("car_details").set(
        onlineDriverData.car_color.toString() +
            onlineDriverData.car_model.toString());
    // Save rideRequestId to driver History
    saveRideRequestIdToDriverHistory();
  }

  // Save rideRequestId to driver History
  saveRideRequestIdToDriverHistory() {
    DatabaseReference tripsHistoryReference = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentFirebaseUser!.uid)
        .child("tripsHistory");
    tripsHistoryReference
        .child(widget.userRideRequestInformation!.rideRequestId!)
        .set(true);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    saveAssignedDriverDetailsToUserRideRequest();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapPadding),
            mapType: MapType.normal,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            initialCameraPosition: _kGooglePlex,
            markers: markersSet,
            circles: circleSet,
            polylines: polyLineSet,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              _newTripGoogleMapController = controller;

              // Adjust Padding
              setState(() {
                mapPadding = 350;
              });

              // Black Theme
              blackThemeGoogleMap(_newTripGoogleMapController);

              // Set Driver current Position from the the Global - home_tab
              var driverCurrentLatLng = LatLng(driverCurrentPosiiton!.latitude,
                  driverCurrentPosiiton!.longitude);
              // Get User Origin/PickUp Location
              var userPickUpLaLng = LatLng(
                  widget.userRideRequestInformation!.originLatLng!.latitude,
                  widget.userRideRequestInformation!.originLatLng!.longitude);

              // Draw the PolyLine
              _drawPolyLineFromOriginToDestination(
                  driverCurrentLatLng, userPickUpLaLng);
            },
          ),
          // User Interface
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                      color: Colors.white30,
                      blurRadius: 18,
                      spreadRadius: .5,
                      offset: Offset(.6, .6)),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 20,
                ),
                child: Column(
                  children: [
                    // Duration from Pickup to Drop Off
                    Text(
                      "18 mins",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightGreenAccent,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Divider(
                      thickness: 2,
                      height: 2,
                      color: Colors.grey,
                    ),
                    const SizedBox(
                      height: 10,
                    ),

                    // Username of who placed a request and Icon
                    Row(
                      children: [
                        Text(
                          widget.userRideRequestInformation!.userName!,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.lightGreenAccent,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Icon(
                            Icons.phone_android,
                            color: Colors.grey,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 18,
                    ),

                    // Username pickup location with Icon
                    Row(
                      children: [
                        Image.asset(
                          "assets/img/origin.png",
                          width: 30,
                          height: 30,
                        ),
                        const SizedBox(
                          width: 22,
                        ),
                        Expanded(
                          child: Container(
                            child: Text(
                              widget.userRideRequestInformation!.originAddress!,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),

                    // Username of dropoff location with Icon

                    Row(
                      children: [
                        Image.asset(
                          "assets/img/destination.png",
                          width: 30,
                          height: 30,
                        ),
                        const SizedBox(
                          width: 22,
                        ),
                        Expanded(
                          child: Container(
                            child: Text(
                              widget.userRideRequestInformation!
                                  .destinationAddress!,
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.grey),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Divider(
                      thickness: 2,
                      height: 2,
                      color: Colors.grey,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    // Button
                    ElevatedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(primary: buttonColor),
                      label: Text(
                        buttonTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      icon: const Icon(
                        Icons.directions_car,
                        color: Colors.white,
                        size: 25,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
