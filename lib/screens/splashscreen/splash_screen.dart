import 'dart:async';
import 'package:flutter/material.dart';
import '../../assistants/assistant_methods.dart';
import '../main_screen.dart';
import '../../global/global.dart';
import '../authentication/auth_screen.dart';

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({Key? key}) : super(key: key);

  @override
  _MySplashScreenState createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTime();
  }

  Future<void> startTime() async {
    fAuth.currentUser != null
        ? AssistantMethods.readCurrentOnlineUserInfo()
        : null;
    Timer(
      const Duration(seconds: 3),
      () async {
        // Send user to home screen;
        if (fAuth.currentUser != null) {
          Navigator.of(context).pushNamed(MainScreen.routeName);
        } else {
          Navigator.of(context).pushNamed(AuthScreen.routeName);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 250,
              height: 300,
              child: Image.asset(
                'assets/img/logo1.png',
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              'Adedrey Uber',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
