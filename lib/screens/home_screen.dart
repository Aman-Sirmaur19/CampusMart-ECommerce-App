import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../helper/dialogs.dart';
import '../widgets/custom_title.dart';
import '../widgets/main_drawer.dart';
import 'auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomTitle(),
        actions: [
          customIconButton(
              const Icon(Icons.logout), 'Logout', showLogOutAlertDialog)
        ],
      ),
      drawer: const MainDrawer(),
    );
  }

  Widget customIconButton(Icon icon, String tip, void Function()? onPressed) {
    return IconButton(
      icon: icon,
      tooltip: tip,
      onPressed: onPressed,
    );
  }

  Future showLogOutAlertDialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'Do you want to logout?',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  child: Text(
                    'Yes',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                  onPressed: () async {
                    // for showing progress dialog
                    Dialogs.showProgressBar(context);

                    // sign out from app
                    await FirebaseAuth.instance.signOut().then((value) async {
                      // for hiding progress dialog
                      Navigator.pop(context);

                      // for moving to home screen
                      Navigator.pop(context);

                      // for replacing home screen with login screen
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()));
                    });
                  },
                ),
                TextButton(
                    child: Text(
                      'No',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                    onPressed: () => Navigator.pop(context)),
              ],
            ),
          );
        });
  }
}
