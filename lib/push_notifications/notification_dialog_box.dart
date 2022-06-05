import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/models/user_ride_request_information.dart';
import 'package:flutter/material.dart';

class NotificationDialogBox extends StatefulWidget {
  UserRideRequestInformation? userRideRequestInformation;
  NotificationDialogBox({this.userRideRequestInformation});
  @override
  _NotificationDialogBoxState createState() => _NotificationDialogBoxState();
}

class _NotificationDialogBoxState extends State<NotificationDialogBox> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: Colors.transparent,
      elevation: 2,
      child: Container(
        margin: const EdgeInsets.all(8),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[800],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 14,
            ),
            Image.asset(
              "assets/img/car_logo.png",
              width: 160,
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(
              thickness: 3,
              height: 3,
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "New Ride Request",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.grey,
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 10, bottom: 20, right: 20, left: 20.0),
              child: Column(
                children: [
                  const SizedBox(
                    height: 14,
                  ),
                  // Origin Location with Icon
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
                  // Destination Location with Icon

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
                    height: 15,
                  ),
                  const Divider(
                    thickness: 3,
                    height: 3,
                  ),
                  const SizedBox(
                    height: 25,
                  ),

                  // Cancel and Accept Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Stop Audio Player
                          audioPlayer.pause();
                          audioPlayer.stop();
                          audioPlayer = AssetsAudioPlayer();
                          // Cancel the RideRequest

                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                        ),
                        child: Text(
                          "Cancel".toUpperCase(),
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Stop Audio Player
                          audioPlayer.pause();
                          audioPlayer.stop();
                          audioPlayer = AssetsAudioPlayer();
                          // Cancel the RideRequest

                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                        ),
                        child: Text(
                          "Accept".toUpperCase(),
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
