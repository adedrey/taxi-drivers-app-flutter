import 'package:drivers_app/infoHandler/app_info.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './screens/main_screen.dart';
import './screens/splashscreen/splash_screen.dart';
import '../screens/authentication/auth_screen.dart';
import '../screens/authentication/car_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp(
      child: ChangeNotifierProvider(
    create: (context) => AppInfo(),
    child: MaterialApp(
      title: 'Drivers App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/': (context) => const MySplashScreen(),
        MainScreen.routeName: (context) => const MainScreen(),
        AuthScreen.routeName: (context) => AuthScreen(),
        CarDetailScreen.routeName: (context) => const CarDetailScreen(),
      },
      debugShowCheckedModeBanner: false,
    ),
  )));
}

class MyApp extends StatefulWidget {
  final Widget? child;

  const MyApp({this.child});

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_MyAppState>()!.restartApp();
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: key, child: widget.child!);
  }
}
