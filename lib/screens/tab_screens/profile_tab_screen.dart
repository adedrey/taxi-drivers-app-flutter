import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/widgets/driver_info_design_ui.dart';
import 'package:flutter/material.dart';

import '../../main.dart';

class ProfileTabScreen extends StatefulWidget {
  const ProfileTabScreen({Key? key}) : super(key: key);
  @override
  _ProfileTabScreenState createState() => _ProfileTabScreenState();
}

class _ProfileTabScreenState extends State<ProfileTabScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // name
            Text(
              onlineDriverData.name!,
              style: const TextStyle(
                fontSize: 30,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              titleStarRating + " driver",
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 20,
              width: 200,
              child: Divider(
                color: Colors.white,
              ),
            ),
            const SizedBox(
              height: 38,
            ),

            // Phone
            DriverInfoDesignUIWidget(
              textinfo: onlineDriverData.phone,
              iconData: Icons.phone_iphone,
            ),

            // Email
            DriverInfoDesignUIWidget(
              textinfo: onlineDriverData.email,
              iconData: Icons.email,
            ),

            // Cr Details
            DriverInfoDesignUIWidget(
              textinfo: onlineDriverData.car_color! +
                  " " +
                  onlineDriverData.car_model! +
                  " " +
                  onlineDriverData.car_no!,
              iconData: Icons.car_repair,
            ),
            const SizedBox(
              height: 20,
            ),
            // Close Button
            ElevatedButton(
              onPressed: () {
                fAuth.signOut();
                MyApp.restartApp(context);
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.redAccent,
              ),
              child: const Text(
                "Logout",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
