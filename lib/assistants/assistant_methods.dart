import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../global/global.dart';
import '../global/map_key.dart';
import '../infoHandler/app_info.dart';
import '../models/direction_details_info.dart';
import '../models/trip_history_model.dart';
import '../models/user_model.dart';
import './request_assistant.dart';

import '../infoHandler/directions.dart';

class AssistantMethods {
  static Future<String> searchAddressForGeographicCoordinates(
      Position position, context) async {
    String apiURL =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$googleApiKey';
    String humanReadableAddress = '';

    var requestResponse = await RequestAssistant.receiveRequest(apiURL);

    if (requestResponse != 'failed') {
      humanReadableAddress = requestResponse['results'][0]["formatted_address"];
      Directions userPickUpAddress = Directions();
      userPickUpAddress.locationLatitude = position.latitude;
      userPickUpAddress.locationLongitude = position.longitude;
      userPickUpAddress.locationName = humanReadableAddress;
      Provider.of<AppInfo>(context, listen: false)
          .updatePickupLocationAddress(userPickUpAddress);
    }
    return humanReadableAddress;
  }

  static readCurrentOnlineUserInfo() async {
    currentFirebaseUser = fAuth.currentUser;
    DatabaseReference userRef = FirebaseDatabase.instance
        .ref()
        .child('users')
        .child(currentFirebaseUser!.uid);
    userRef.once().then(
      (snap) {
        if (snap.snapshot.value != null) {
          userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);
        }
      },
    );
  }

  static Future<DirectionDetailsInfo?>
      obtainOriginToDestinationDirectionDetails(
          LatLng originPosition, LatLng destinationPosition) async {
    String ultToObtainOriginToDestinationDirectionDetails =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$googleApiKey";
    var responseDirectionApi = await RequestAssistant.receiveRequest(
        ultToObtainOriginToDestinationDirectionDetails);

    if (responseDirectionApi == "failed") {
      return null;
    }
    if (responseDirectionApi["status"] == "OK") {
      DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();
      directionDetailsInfo.e_points =
          responseDirectionApi["routes"][0]["overview_polyline"]["points"];
      directionDetailsInfo.distance_text =
          responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
      directionDetailsInfo.distance_value =
          responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];
      directionDetailsInfo.duration_text =
          responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
      directionDetailsInfo.duration_value =
          responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];
      return directionDetailsInfo;
    } else {
      return null;
    }
  }

  // Pause live location of the current user
  static pauseLiveLocationUpdate() {
    // Pause streamSubscriptionPosition - pause the Live Location
    streamSubscriptionPosition!.pause();
    // Remove driver from list of nearby drivers to users using Geofire
    Geofire.removeLocation(currentFirebaseUser!.uid);
  }

  // Resume live location of the current user
  static resumeLiveLocationUpdate() {
    // Resume streamSubscriptionPosition - resume the Live Location
    streamSubscriptionPosition!.resume();
    // Add driver back to the list of nearby drivers to users using Geofire
    Geofire.setLocation(
      currentFirebaseUser!.uid,
      driverCurrentPosiiton!.latitude,
      driverCurrentPosiiton!.longitude,
    );
  }

  // Calculate Fare AMount

  static calculuateFareAmountFromOriginToDestination(
      DirectionDetailsInfo directionDetailsInfo) {
    // Calculate how much to charge per minute
    double timeTraveledFareAmountPerMinute =
        (directionDetailsInfo.duration_value! / 60) * 0.1;
    // Calcate how much per kilometre
    double distanceTraveledFareAMountPerKilometer =
        (directionDetailsInfo.distance_value! / 1000) * 0.1;
    // Calcutae total fare amount to get overall fare amount from origin to destination

    double totalFareAmount = timeTraveledFareAmountPerMinute +
        distanceTraveledFareAMountPerKilometer;
    // To convert from USD to other currency
    // 1 USD = 400 Naira
    double localCurrencyTotalFareAmount = totalFareAmount * 400;
    // Validate Amount with Vehicle Type
    if (driverVehicleType == "bike") {
      double resultFareAmount = (localCurrencyTotalFareAmount.truncate()) / 2.0;
      return resultFareAmount;
    } else if (driverVehicleType == "uber-go") {
      double resultFareAmount = localCurrencyTotalFareAmount.truncateToDouble();
      return resultFareAmount;
    } else if (driverVehicleType == "uber-x") {
      double resultFareAmount = (localCurrencyTotalFareAmount.truncate()) * 2.0;
      return resultFareAmount;
    } else {
      double resultFareAmount = localCurrencyTotalFareAmount.truncateToDouble();
      return resultFareAmount;
    }
  }

  // Retrieve the trip keys for online driver
  // trip key = ride request key
  static readTripKeysForOnlineDriver(BuildContext context) {
    FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .orderByChild("driverId")
        .equalTo(fAuth.currentUser!.uid)
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        // get all available trips
        Map keysTripsId = snap.snapshot.value as Map;
        // Count user  total trips
        int overAllTripsCounter = keysTripsId.length;
        // Share with app using Provider
        Provider.of<AppInfo>(context, listen: false)
            .updateOverallTripsCounter(overAllTripsCounter);
        // share ride request ids with Provider
        List<String> tripsKeysList = [];
        keysTripsId.forEach((key, value) {
          tripsKeysList.add(key);
        });
        // share with app using Provider
        Provider.of<AppInfo>(context, listen: false)
            .updateOverallTripsKeys(tripsKeysList);

        // get trips keys data - read trips complete information...
        readTripHistoryInformation(context);
      }
    });
  }

  // get trips keys data - read trips complete information...
  static void readTripHistoryInformation(BuildContext context) {
    var tripsAllKeys =
        Provider.of<AppInfo>(context, listen: false).historyTripKeysList;
    for (String EachKey in tripsAllKeys) {
      FirebaseDatabase.instance
          .ref()
          .child("All Ride Requests")
          .child(EachKey)
          .once()
          .then((snap) {
        // Add only trips that has been completed - ended
        // Initialize from the Model class
        var eachTripHistory = TripHistoryModel.fromDataSnapShot(snap.snapshot);
        if ((snap.snapshot.value as Map)["status"] == "ended") {
          // Update OverallTrips History Data
          Provider.of<AppInfo>(context, listen: false)
              .updateOverAllTripsHistoryInformation(eachTripHistory);
        }
      });
    }
  }

  // readDriverEarnings
  static void readDriverEarnings(BuildContext context) {
    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(fAuth.currentUser!.uid)
        .child("earnings")
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        String driverEarnings = snap.snapshot.value.toString();
        print("Earnings: " + driverEarnings);
        Provider.of<AppInfo>(context, listen: false)
            .updateDriverTotalEarnings(driverEarnings);
      }
    });
    // Read Keys for online Driver
    readTripKeysForOnlineDriver(context);
  }
}
