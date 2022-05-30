import 'package:drivers_app/global/global.dart';
import 'package:flutter/material.dart';
import '../authentication/auth_screen.dart';

class ProfileTabScreen extends StatefulWidget {
  const ProfileTabScreen({Key? key}) : super(key: key);

  @override
  _ProfileTabScreenState createState() => _ProfileTabScreenState();
}

class _ProfileTabScreenState extends State<ProfileTabScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          fAuth.signOut();
          Navigator.of(context).pushNamed(AuthScreen.routeName);
        },
        style: ElevatedButton.styleFrom(
          primary: Colors.black,
          padding: const EdgeInsets.all(10),
          // textStyle: const TextStyle(),
        ),
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
      ),
    );
  }
}
