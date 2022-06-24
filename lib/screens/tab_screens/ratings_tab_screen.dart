import 'package:drivers_app/infoHandler/app_info.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';

import '../../global/global.dart';

class RatingsTabScreen extends StatefulWidget {
  const RatingsTabScreen({Key? key}) : super(key: key);
  @override
  _RatingsTabScreenState createState() => _RatingsTabScreenState();
}

class _RatingsTabScreenState extends State<RatingsTabScreen> {
  double ratingsFromDBNumber = 0.0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getRatingsNumber();
  }

  getRatingsNumber() {
    setState(() {
      ratingsFromDBNumber = double.parse(
          Provider.of<AppInfo>(context, listen: false).driverAverageRatings);
    });
    setupRatingsTitle();
  }

  setupRatingsTitle() {
    if (ratingsFromDBNumber == 1) {
      setState(() {
        titleStarRating = "Very Bad";
      });
    }
    if (ratingsFromDBNumber == 2) {
      setState(() {
        titleStarRating = "Bad";
      });
    }
    if (ratingsFromDBNumber == 3) {
      setState(() {
        titleStarRating = "Good";
      });
    }
    if (ratingsFromDBNumber == 4) {
      setState(() {
        titleStarRating = "Very Good";
      });
    }
    if (ratingsFromDBNumber == 5) {
      setState(() {
        titleStarRating = "Excellent";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        backgroundColor: Colors.white60,
        child: Container(
          margin: const EdgeInsets.all(8),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white54,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 22,
              ),
              const Text(
                "Your Ratings",
                style: TextStyle(
                  fontSize: 22,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              const Divider(
                thickness: 4,
                height: 4,
              ),
              const SizedBox(
                height: 24,
              ),
              SmoothStarRating(
                rating: ratingsFromDBNumber,
                // allowHalfRating: true,
                starCount: 5,
                size: 46,
                color: Colors.green,
                borderColor: Colors.green,
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                titleStarRating,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(
                height: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
