import 'package:firebase_database/firebase_database.dart';

class TripHistoryModel {
  String? time;
  String? originAddress;
  String? destinationAddress;
  String? status;
  String? fareAmount;
  String? car_details;
  String? userName;
  String? userPhone;

  TripHistoryModel({
    this.time,
    this.originAddress,
    this.destinationAddress,
    this.status,
    this.fareAmount,
    this.car_details,
    this.userName,
    this.userPhone,
  });

  TripHistoryModel.fromDataSnapShot(DataSnapshot dataSnapshot) {
    time = (dataSnapshot.value as Map)['time'];
    originAddress = (dataSnapshot.value as Map)['originAddress'];
    destinationAddress = (dataSnapshot.value as Map)['destinationAddress'];
    status = (dataSnapshot.value as Map)['status'];
    fareAmount = (dataSnapshot.value as Map)['fareAmount'];
    car_details = (dataSnapshot.value as Map)['car_details'];
    userName = (dataSnapshot.value as Map)['userName'];
    userPhone = (dataSnapshot.value as Map)['userPhone'];
  }
}
