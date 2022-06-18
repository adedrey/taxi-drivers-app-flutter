import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/models/user_ride_request_information.dart';
import 'package:drivers_app/widgets/fare_amount_collection_dialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

  // Define the BitmapDescriptor for driver markup icon to animate move at real time
  BitmapDescriptor? iconAnimatedMarker;
  // Inital an instance of the geolocaor
  var geoLocator = Geolocator();

  // Define online driver live position for the trip
  Position? onlineDriverCurrentPosition;

  // Driver rideRequestStatus for updating duration to User pickup location
  String rideRequestStatus = "accepted";
  String durationFromOriginToDestination = "";
  bool isRequestDirectionDetails = false;

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
    // Cancel the show dialog
    Navigator.of(context).pop();
    // Decode the encoded points
    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPpointsReultList =
        pPoints.decodePolyline(directionDetailsInfo!.e_points!);
    pLineCoOrdinatesList.clear();
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
    // Calculate zoom based on distance
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

  // Create Driver Marker Icon
  void _createADriverMarkerIcon() {
    if (iconAnimatedMarker == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: const Size(1, 1));
      BitmapDescriptor.fromAssetImage(imageConfiguration, 'assets/img/car.png')
          .then((value) {
        iconAnimatedMarker = value;
      });
    }
  }

// Listen to Driver Live Location At RealTime
// Then set it to driverCurrentPosiiton
  void getDriverLocationUpdateAtRealTime() {
    // Initialize LatLng position
    LatLng oldLatLng = LatLng(0, 0);
    // Set streamSubscriptionPosition from Global file to Driver live location
    streamSubscriptionDriverLivePosition =
        Geolocator.getPositionStream().listen(
      (Position position) {
        // set driverCurrentPositon and onlineDriverCurrentPosition from Global to streamSubscription Position
        driverCurrentPosiiton = position;
        onlineDriverCurrentPosition = position;

        // Get driver current LatLng to display on Map
        LatLng latLngLiveDriverPosition = LatLng(
          onlineDriverCurrentPosition!.latitude,
          onlineDriverCurrentPosition!.longitude,
        );

        // Set live animatingMarker of Driver
        Marker animatingMarker = Marker(
          markerId: const MarkerId("AnimatedMarker"),
          position: latLngLiveDriverPosition,
          icon: iconAnimatedMarker!,
          infoWindow: const InfoWindow(
            title: "This is your Position",
          ),
        );

        setState(() {
          CameraPosition cameraPosition = CameraPosition(
            target: latLngLiveDriverPosition,
            zoom: 16,
          );
          // Display on Map
          _newTripGoogleMapController!.animateCamera(
            CameraUpdate.newCameraPosition(cameraPosition),
          );
          // Remove previous marker if it exist when the driver change position
          // where the markerId is AnimatedMarker
          markersSet.removeWhere(
              (element) => element.markerId.value == "AnimatedMarker");
          // Add an updated marker when a new position is gained
          markersSet.add(animatingMarker);
        });
        // Assign driver current position to initialized latLng
        oldLatLng = latLngLiveDriverPosition;
        // Get Duration Time at real time
        updateDurationTimeAtRealTime();
        // Update the driver location in the DB at real time
        Map driverLatLngDataMap = {
          "latitude": onlineDriverCurrentPosition!.latitude.toString(),
          "longitude": onlineDriverCurrentPosition!.longitude.toString(),
        };
        FirebaseDatabase.instance
            .ref()
            .child("All Ride Requests")
            .child(widget.userRideRequestInformation!.rideRequestId!)
            .child("driverLocation")
            .set(driverLatLngDataMap);
      },
    );
  }

// Update Driver duration time to reach User pickup location
// Checks Duration time from driver location to pickup location for step 1
// Checks Duration time from user pick up location to destination for step 2
  updateDurationTimeAtRealTime() async {
    // If request direction is false
    // Get direction duration only when needed
    // to prevent lagging
    if (isRequestDirectionDetails == false) {
      isRequestDirectionDetails = true;

      // If We couldn't get Driver Location at real time
      if (onlineDriverCurrentPosition == null) {
        return;
      }
      // Get driver current position
      LatLng originLatLng = LatLng(onlineDriverCurrentPosition!.latitude,
          onlineDriverCurrentPosition!.longitude);
      LatLng? destinationLatLng;
      // Check if a ride request has being accept
      if (rideRequestStatus == "accepted") {
        // Get the user pickup location
        destinationLatLng = widget.userRideRequestInformation!.originLatLng!;
      } else {
        // arrived
        // get the user destination location
        destinationLatLng =
            widget.userRideRequestInformation!.destinationLatLng!;
      }
      // Get the direction detail information
      var directionDetailInformation =
          await AssistantMethods.obtainOriginToDestinationDirectionDetails(
              originLatLng, destinationLatLng);
      // Check if its not null
      if (directionDetailInformation != null) {
        // Assign the duration time
        setState(() {
          durationFromOriginToDestination =
              directionDetailInformation.duration_text!;
        });
      }
      // After the above code has updated successfully
      // Set isisRequestDirectionDetails
      // To prevent lagging
      isRequestDirectionDetails = false;
    }
  }

  // End User Trip after reaching Destination
  endTripNow() async {
    // Please Wait Dialog Box
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProgressDialog(message: "Please wait"),
    );

    // GET TRIP DIRECTION DETAILS - DISTANCE TRAVELLED
    // In order to prevent driver from scamming the user
    // We should get the Driver current position and User Pickup/Origin Position
    // Instead of using the default widget userTrip Details from the driver position to user destinaition
    var currentDriverPostionLatLng = LatLng(
      onlineDriverCurrentPosition!.latitude,
      onlineDriverCurrentPosition!.longitude,
    );
    var tripDirectionDetails =
        await AssistantMethods.obtainOriginToDestinationDirectionDetails(
            currentDriverPostionLatLng,
            widget.userRideRequestInformation!.originLatLng!);

    // FARE AMOUNT
    double totalFareAmount =
        AssistantMethods.calculuateFareAmountFromOriginToDestination(
            tripDirectionDetails!);
    // Save fare amount in the DB of ride request
    FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(widget.userRideRequestInformation!.rideRequestId!)
        .child("fareAmount")
        .set(totalFareAmount.toString());
    // Save ride status in the DB of ride request
    FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(widget.userRideRequestInformation!.rideRequestId!)
        .child("status")
        .set("ended");

    // Stop StreamSubScription
    streamSubscriptionDriverLivePosition!.cancel();

    Navigator.pop(context);

    // Display Fare Amount in dialog box
    showDialog(
      context: context,
      builder: (context) =>
          FareAmountCollectionDialog(totalFareAmount: totalFareAmount),
    );

    // Save Fare AMount to Driver Total Earnings
    saveFareAmountToDriverEarnings(totalFareAmount);
  }

  // Save Fare AMount to Driver Total Earnings
  saveFareAmountToDriverEarnings(double totalFareAmount) {
    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentFirebaseUser!.uid)
        .child("earnings")
        .once()
        .then(
      (snapShot) {
        // Earnings subchild exist in DB
        if (snapShot.snapshot.value != null) {
          double oldEarnings = double.parse(snapShot.snapshot.value.toString());
          double driverTotalEarnings = oldEarnings + totalFareAmount;
          FirebaseDatabase.instance
              .ref()
              .child("drivers")
              .child(currentFirebaseUser!.uid)
              .child("earnings")
              .set(driverTotalEarnings.toString());
        } else {
          // Earnings subchild does not exist in DB
          FirebaseDatabase.instance
              .ref()
              .child("drivers")
              .child(currentFirebaseUser!.uid)
              .child("earnings")
              .set(totalFareAmount.toString());
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // To Add Active Driver MarkerIcon
    _createADriverMarkerIcon();
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

              // Update Driver Realtime Location on the Map
              getDriverLocationUpdateAtRealTime();
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
                      durationFromOriginToDestination,
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
                      onPressed: () async {
                        if (rideRequestStatus == "accepted") {
                          // Driver has arrived at user pickup location
                          rideRequestStatus = "arrived";
                          FirebaseDatabase.instance
                              .ref()
                              .child("All Ride Requests")
                              .child(widget
                                  .userRideRequestInformation!.rideRequestId!)
                              .child("status")
                              .set(rideRequestStatus);
                          setState(() {
                            buttonTitle = "Start Trip"; // Start the trip
                            buttonColor = Colors.lightGreenAccent;
                          });
                          showDialog(
                            context: context,
                            barrierDismissible: false, // make it indismissible
                            builder: (context) => ProgressDialog(
                                message: "Setting trip route..."),
                          );
                          // Draw Polyline for the trip - User pickup location to Destination Location
                          await _drawPolyLineFromOriginToDestination(
                              widget.userRideRequestInformation!.originLatLng!,
                              widget.userRideRequestInformation!
                                  .destinationLatLng!);

                          Navigator.pop(context); //Dismiss dialog box
                        }
                        // Driver has reached the user pickup location
                        // User is in the Driver's car - Start Trip
                        // Update arrived to OnTrip
                        // Realtime location is still on
                        else if (rideRequestStatus == "arrived") {
                          // Driver is ready to start trip
                          rideRequestStatus = "ontrip";
                          FirebaseDatabase.instance
                              .ref()
                              .child("All Ride Requests")
                              .child(widget
                                  .userRideRequestInformation!.rideRequestId!)
                              .child("status")
                              .set(rideRequestStatus);
                          setState(() {
                            buttonTitle = "End Trip"; // Start the trip
                            buttonColor = Colors.redAccent;
                          });
                        }
                        //  Driver/User reached to the dropoff Destination Location -End Trip Button
                        else if (rideRequestStatus == "ontrip") {
                          // Method to End Trip
                          endTripNow();
                        }
                      },
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
