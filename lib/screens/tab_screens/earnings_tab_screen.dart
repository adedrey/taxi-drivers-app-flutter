import 'package:drivers_app/infoHandler/app_info.dart';
import 'package:drivers_app/screens/trips_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EarningsTabScreen extends StatefulWidget {
  const EarningsTabScreen({Key? key}) : super(key: key);

  @override
  _EarningsTabScreenState createState() => _EarningsTabScreenState();
}

class _EarningsTabScreenState extends State<EarningsTabScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      child: Column(
        children: [
          // Driver Earnings
          Container(
            color: Colors.black,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 80),
              child: Column(
                children: [
                  // Total Earnings
                  const Text(
                    "Your Earnings",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "₦ ${Provider.of<AppInfo>(context, listen: false).driverTotalEarnings}",
                    style: TextStyle(
                      fontSize: 50,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Total Number of completed trips
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TripsHistoryScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.white54,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              child: Row(
                children: [
                  // Image
                  Image.asset(
                    "assets/img/car_logo.png",
                    width: 100,
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  const Text(
                    "Trips Completed",
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      child: Text(
                        Provider.of<AppInfo>(context, listen: false)
                            .allTripHistoryInformationList
                            .length
                            .toString(),
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
