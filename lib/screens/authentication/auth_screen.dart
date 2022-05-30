import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../widgets/auth_form.dart';
import './car_detail_screen.dart';
import '../../global/global.dart';
import '../../screens/splashscreen/splash_screen.dart';
import '../../widgets/progress_dialog.dart';

class AuthScreen extends StatefulWidget {
  static const routeName = '/auth';

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  var _isLoading = false;

  void _showProgressDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ProgressDialog(
          message: "Processing, Please wait...",
        );
      },
    );
  }

  void _showSnackBar(String msg, Color color) {
    Fluttertoast.showToast(msg: msg);
  }

  Future<void> _submitForm(
    String name,
    String email,
    String phone,
    String password,
    AuthMode authMode,
  ) async {
    try {
      _showProgressDialog();
      if (authMode == AuthMode.SIGNUP) {
        // Sign Up

        final User? firebaseUser = (await fAuth
                .createUserWithEmailAndPassword(
          email: email,
          password: password,
        )
                .catchError(
          (msg) {
            Navigator.pop(context);
            _showSnackBar(msg, Theme.of(context).errorColor);
          },
        ))
            .user;
        if (firebaseUser == null) {
          Navigator.pop(context);
          _showSnackBar(
            'Unable to create account',
            Theme.of(context).errorColor,
          );
          return;
        }
        Map driverMap = {
          'id': firebaseUser.uid,
          'name': name,
          'email': email,
          'phone': phone,
        };
        DatabaseReference driverRef =
            FirebaseDatabase.instance.ref().child('drivers');
        driverRef.child(firebaseUser.uid).set(driverMap);
        currentFirebaseUser = firebaseUser;
        _showSnackBar('Sucess!', Colors.black54);
        Navigator.of(context).pushNamed(CarDetailScreen.routeName);
      } else {
        // Login
        final User? firebaseUser = (await fAuth
                .signInWithEmailAndPassword(email: email, password: password)
                .catchError(
          (msg) {
            Navigator.of(context).pop();
            _showSnackBar(msg, Theme.of(context).errorColor);
          },
        ))
            .user;
        if (firebaseUser == null) {
          Navigator.pop(context);
          _showSnackBar(
            'Failed Credentils',
            Theme.of(context).errorColor,
          );
          return;
        }
        DatabaseReference driverRef =
            FirebaseDatabase.instance.ref().child('drivers');
        driverRef.child(firebaseUser.uid).once().then((driverKey) {
          final snap = driverKey.snapshot;
          if (snap.value != null) {
            currentFirebaseUser = firebaseUser;
            _showSnackBar('Sucess!', Colors.black54);
          } else {
            _showSnackBar('No record exist with this email!',
                Theme.of(context).errorColor);
            fAuth.signOut();
          }
        });
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const MySplashScreen(),
          ),
        );
      }
    } on HttpException catch (err) {
      var message = 'An error occurred, please check your credentials';

      // if (err ) {
      message = err.message;
      // }
      _showSnackBar(message, Theme.of(context).errorColor);
    } catch (err) {
      print(err);
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
                    child: AuthGuard(
                      submitFn: _submitForm,
                      isLoading: _isLoading,
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
