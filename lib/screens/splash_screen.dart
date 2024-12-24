import 'dart:developer';

import 'package:chat_app_hin/api/apis.dart';
import 'package:chat_app_hin/main.dart';
import 'package:chat_app_hin/screens/auth/login_screen.dart';
import 'package:chat_app_hin/screens/home_screen.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(
        const Duration(
          seconds: 2,
        ), () {
      // exit full screen
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
      );
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.white,
          statusBarColor: Colors.white,
          // statusBarColor: Colors.transparent,
        ),
      );
      // if (FirebaseAuth.instance.currentUser != null) {
      if (APIs.auth.currentUser != null) {
        // log('\nUser: ${FirebaseAuth.instance.currentUser}');
        log('\nUser: ${APIs.auth.currentUser}');
        // navigate to home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
        );
      } else {
        // navigate to home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
        );
      }
      /* // navigate to home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      ); */
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return Scaffold(
      // body
      body: Stack(
        children: [
          // Positioned(
          Positioned(
            top: mq.height * .15,
            right: mq.width * .25,
            width: mq.width * .5,
            child: Image.asset(
              'images/icon.png',
            ),
          ),
          Positioned(
            bottom: mq.height * .15,
            width: mq.width,
            height: mq.height * .07,
            child: const Text(
              'MADE IN Egypt WITH ❤️',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black87,
                letterSpacing: .5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
