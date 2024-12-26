import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../helper/api.dart';
import '../helper/constants.dart';
import '../helper/dialogs.dart';
import '../models/product.dart';
import '../widgets/custom_title.dart';
import '../widgets/main_drawer.dart';
import 'auth/login_screen.dart';
import 'product/products_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    try {
      await APIs.getSelfInfo();
      setState(() {
        // isLoading = false;
      });
    } catch (e) {
      print("Error loading data: $e");
      setState(() {
        // isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomTitle(),
        actions: [
          _customIconButton(const Icon(CupertinoIcons.search), 'Search', () {}),
          _customIconButton(
              const Icon(Icons.logout), 'Logout', _showLogOutAlertDialog),
        ],
      ),
      drawer: const MainDrawer(),
      body: ListView(
        children: [
          _customRow(
              title: 'Products',
              context: context,
              onPressed: () => Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (context) =>
                          ProductsScreen(itemType: ItemType.sale)))),
          ProductsScreen(isHome: true, itemType: ItemType.sale),
          const SizedBox(height: 15),
          _customRow(
              title: 'Rental Items',
              context: context,
              onPressed: () => Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (context) =>
                          ProductsScreen(itemType: ItemType.rental)))),
          ProductsScreen(isHome: true, itemType: ItemType.rental),
          const SizedBox(height: 15),
          _customRow(
              title: 'Lost Items',
              context: context,
              onPressed: () => Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (context) =>
                          ProductsScreen(itemType: ItemType.lost)))),
          ProductsScreen(isHome: true, itemType: ItemType.lost),
        ],
      ),
    );
  }

  Widget _customRow({
    required String title,
    required BuildContext context,
    required void Function()? onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          TextButton(
            onPressed: onPressed,
            child: const Text("Show All",
                style: TextStyle(fontSize: 13, color: Colors.blue)),
          )
        ],
      ),
    );
  }

  Widget _customIconButton(Icon icon, String tip, void Function()? onPressed) {
    return IconButton(
      icon: icon,
      tooltip: tip,
      onPressed: onPressed,
    );
  }

  Future _showLogOutAlertDialog() {
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
