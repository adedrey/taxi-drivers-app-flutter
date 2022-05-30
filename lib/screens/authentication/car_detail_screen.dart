import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../screens/splashscreen/splash_screen.dart';
import '../../widgets/auth_form.dart';
import '../../widgets/car_detail_form.dart';
import '../../global/global.dart';

class CarDetailScreen extends StatefulWidget {
  static const routeName = '/car-detail';
  const CarDetailScreen({Key? key}) : super(key: key);

  @override
  State<CarDetailScreen> createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends State<CarDetailScreen> {
  Future<void> _submitForm(
    String car_model,
    String car_no,
    String car_color,
    String car_type,
    AuthMode authMode,
  ) async {
    if (authMode == AuthMode.SIGNUP) {
      Map driverCarInfo = {
        'car_no': car_no,
        'car_model': car_model,
        'car_color': car_color,
        'car_type': car_type
      };
      DatabaseReference driverRef =
          FirebaseDatabase.instance.ref().child('drivers');
      driverRef
          .child(currentFirebaseUser!.uid)
          .child('car_details')
          .set(driverCarInfo);
      Fluttertoast.showToast(
          msg: 'Car details has been saved. Congratulations!');
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const MySplashScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(color: Colors.black),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Image.asset(
                    'assets/img/logo1.png',
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Flexible(
                  fit: FlexFit.loose,
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    child: CarDetailGuard(
                      submitFn: _submitForm,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
