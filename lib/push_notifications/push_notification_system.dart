import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/models/user_ride_request_information.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PushNotificationSystem {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future initializeCloudMessaging() async {
    // Terminated: When the app is completely closed and you receive a notification
    // Open directly from the notification
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        // Display the  user ride request information

        // Send ride request id
        // display ride request information - user information who request a ride
        readUserRideReequestInformation(remoteMessage.data["rideRequestId"]);
      }
    });

    // Foreground: WHen the app is opened and in use and it receive a notification
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      // Display the  user ride request information
      // Send ride request id
      // display ride request information - user information who request a ride
      readUserRideReequestInformation(remoteMessage!.data["rideRequestId"]);
    });
    // Background: When the app is not closed but not in use i.e minimized
    // and it receive a notifcation
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
      // Display the  user ride request information
      // Send ride request id
      // display ride request information - user information who request a ride
      readUserRideReequestInformation(remoteMessage!.data["rideRequestId"]);
    });
  }

// Read ride request from Database
  readUserRideReequestInformation(String userRideRequestId) {
// Get ride request from DB
    FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(userRideRequestId)
        .once()
        .then((snapData) {
      // check if request is not null
      if (snapData.snapshot.value != null) {
        // retrieve data
        // Get Origin Details
        double originLatitude = double.parse(
            (snapData.snapshot.value as Map)["origin"]["latitude"]);
        double originLongitude = double.parse(
            (snapData.snapshot.value as Map)["origin"]["longitude"]);
        String originAddress =
            (snapData.snapshot.value as Map)["originAddress"];
        // Get Destination Details
        double destinationLatitude = double.parse(
            (snapData.snapshot.value as Map)["destination"]["latitude"]);
        double destinationLongitude = double.parse(
            (snapData.snapshot.value as Map)["destination"]["longitude"]);
        String destinationAddress =
            (snapData.snapshot.value as Map)["destinationAddress"];
        // Get User Details
        String userName = (snapData.snapshot.value as Map)["userName"];
        String userPhone = (snapData.snapshot.value as Map)["userPhone"];
        // Assgn values to UserRideRequestInformation Model
        UserRideRequestInformation userRideRequestInformation =
            UserRideRequestInformation();
        userRideRequestInformation.originLatLng =
            LatLng(originLatitude, originLongitude);
        userRideRequestInformation.destinationLatLng =
            LatLng(destinationLatitude, destinationLongitude);
        userRideRequestInformation.originAddress = originAddress;
        userRideRequestInformation.destinationAddress = destinationAddress;
        userRideRequestInformation.userName = userName;
        userRideRequestInformation.userPhone = userPhone;
        userRideRequestInformation.rideRequestId = userRideRequestId;
      } else {
        Fluttertoast.showToast(msg: "This Ride Request Id do not exists.");
      }
    });
  }

  Future generateAndGetToken() async {
    // Generate a device token for client app to identify each device
    String? registrationToken = await messaging.getToken();
    print("FCM registration token: " + registrationToken!);
    // Save token to the Database
    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentFirebaseUser!.uid)
        .child("token")
        .set(registrationToken);
    // Subscribe to available topics: Drivers, Users
    messaging.subscribeToTopic("allDrivers");
    messaging.subscribeToTopic("allUsers");
  }
}
