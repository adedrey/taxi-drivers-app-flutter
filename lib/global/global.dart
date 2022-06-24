import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:drivers_app/models/driver_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/user_model.dart';

final FirebaseAuth fAuth = FirebaseAuth.instance;
User? currentFirebaseUser;
UserModel? userModelCurrentInfo;
// Define when driver is online or offline
bool isDriverActive = false;
String statusText = "Now Offline";
Color statusButtonColor = Colors.grey;

// Online Driver Data
DriverData onlineDriverData = DriverData();
StreamSubscription<Position>? streamSubscriptionPosition;
StreamSubscription<Position>? streamSubscriptionDriverLivePosition;
AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();
// Driver Current Position
Position? driverCurrentPosiiton;

// Vehicle Type
String? driverVehicleType = "";
// Driver Ratings
String titleStarRating = "Good";
