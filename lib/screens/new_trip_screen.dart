import 'package:drivers_app/models/user_ride_request_information.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

import '../assistants/black_theme_google_map.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            mapType: MapType.normal,
            myLocationEnabled: true,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              _newTripGoogleMapController = controller;

              // Black Theme
              blackThemeGoogleMap(_newTripGoogleMapController);
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
