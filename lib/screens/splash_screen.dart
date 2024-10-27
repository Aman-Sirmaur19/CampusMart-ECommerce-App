import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../main.dart';
import '../helper/api.dart';
import '../helper/dialogs.dart';
import '../widgets/custom_title.dart';
import 'auth/login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    await Future.delayed(const Duration(seconds: 2));

    try {
      // Reloading current user data each time when the app starts
      await FirebaseAuth.instance.currentUser?.reload();

      if (APIs.auth.currentUser != null &&
          APIs.auth.currentUser!.emailVerified) {
        // Navigate to home screen
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        // Navigate to login screen
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        // Handle the case where the user is not found (probably deleted)
        // You can log the error or take appropriate action
        Dialogs.showErrorSnackBar(
            context, 'User not found. The user may have been deleted.');
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        // Handle other FirebaseAuthExceptions if needed
        dev.log('Error checking authentication: $e');
        Dialogs.showErrorSnackBar(context,
            'Something went wrong! (Check internet connection and "TAP ANYWHERE")');
      }
    } catch (e) {
      // Handle generic errors
      dev.log('Unexpected error checking authentication: $e');
    } finally {
      // Set loading to false regardless of the result
      // setState(() {
      //   isLoading = false;
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return Scaffold(
      body: InkWell(
        onTap: _checkAuthentication,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const CustomTitle(),
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.3,
                      color: Colors.black),
                  children: [
                    TextSpan(text: 'MADE WITH ❤️ IN 🇮🇳'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
