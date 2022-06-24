import 'package:flutter/material.dart';
import '../models/trip_history_model.dart';
import './directions.dart';

class AppInfo extends ChangeNotifier {
  Directions? userPickUpLocation;
  Directions? userDropOffLocation;
  int countTotalTrips = 0;
  List<String> historyTripKeysList = [];
  List<TripHistoryModel> allTripHistoryInformationList = [];
  String driverTotalEarnings = "0";

  void updatePickupLocationAddress(Directions userPickUpAddress) {
    userPickUpLocation = Directions(
        locationLatitude: userPickUpAddress.locationLatitude,
        locationLongitude: userPickUpAddress.locationLongitude,
        locationName: userPickUpAddress.locationName);
    notifyListeners();
  }

  void updateDropOffLocationAddress(Directions dropOffAddress) {
    userDropOffLocation = Directions(
      locationLatitude: dropOffAddress.locationLatitude,
      locationLongitude: dropOffAddress.locationLongitude,
      locationName: dropOffAddress.locationName,
      locationId: dropOffAddress.locationId,
    );
    notifyListeners();
  }

  // Update user number of ride request - AssistantMethod
  void updateOverallTripsCounter(int overAllTripsCounter) {
    countTotalTrips = overAllTripsCounter;
  }

  // Get user ride request keys/ids - AssistantMethod
  void updateOverallTripsKeys(List<String> tripsKeysList) {
    historyTripKeysList = tripsKeysList;
  }

  // Update user each ride request history - AssistantMethod
  void updateOverAllTripsHistoryInformation(TripHistoryModel eachTripHistory) {
    allTripHistoryInformationList.add(eachTripHistory);
  }

  // Update driver earnings
  updateDriverTotalEarnings(String driverEarnings) {
    driverTotalEarnings = driverEarnings;
  }
}
