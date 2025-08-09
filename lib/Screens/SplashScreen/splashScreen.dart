import 'dart:async';

import 'package:flixprime_app/Screens/Dashboard/dashboard.dart';
import 'package:flixprime_app/Screens/Login/login.dart';
import 'package:flixprime_app/Screens/Login/loginScreen.dart';
import 'package:flixprime_app/Service/serviceManager.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    // super.initState();
    ServiceManager().getUserID();
    ServiceManager().getTokenID();
    ServiceManager().getSubId();
    ServiceManager().getName();
    //  ServiceManager().get;
    //   ServiceManager().getTokenID();
    //    ServiceManager().getTokenID();
    // LocationService().fetchLocation();
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      if (ServiceManager.userID != '') {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => DashboardScreen()),
            (route) => false);
      } else {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer!.isActive) _timer!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Image.asset(
        'images/flix_anim.gif',
        height: MediaQuery.of(context).size.height,
        fit: BoxFit.contain,
      ),
    );
  }
}
