import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../helper/dialogs.dart';
import '../main.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/my shop/my_products.dart';
import '../screens/profile_screen.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({super.key});

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  Widget buildListTile(String title, IconData icon, VoidCallback tapHandler) {
    return ListTile(
      leading: Icon(icon, size: 26),
      title: Text(
        title,
        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
      ),
      onTap: tapHandler,
    );
  }

  Future<void> _launchInBrowser(BuildContext context, Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      Dialogs.showErrorSnackBar(context, 'Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Column(
      children: <Widget>[
        Container(
          height: 120,
          padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
          alignment: Alignment.centerLeft,
          color: Theme.of(context).colorScheme.primary,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Dashboard',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 25,
                  color: Colors.white,
                ),
              ),
              Image.asset('assets/images/icon.png', height: mq.width * .15),
            ],
          ),
        ),
        const SizedBox(height: 10),
        buildListTile(
          'Profile',
          CupertinoIcons.person,
          () => Navigator.push(context,
              CupertinoPageRoute(builder: (_) => const ProfileScreen())),
        ),
        buildListTile(
          'Cart',
          CupertinoIcons.cart,
          () => Navigator.push(
              context, CupertinoPageRoute(builder: (_) => const CartScreen())),
        ),
        buildListTile(
          'My Shop',
          Icons.store_outlined,
          () => Navigator.push(
              context, CupertinoPageRoute(builder: (_) => const MyProducts())),
        ),
        buildListTile(
          'More Apps!',
          CupertinoIcons.app_badge,
          () async {
            const url =
                'https://play.google.com/store/apps/developer?id=SIRMAUR';
            _launchInBrowser(context, Uri.parse(url));
          },
        ),
        buildListTile(
          'Copyright',
          Icons.copyright_rounded,
          () => showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(mq.width * .15),
                        child: Image.asset(
                          'assets/images/avatar.png',
                          width: mq.width * .3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Aman Sirmaur',
                        style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.secondary,
                          letterSpacing: 1,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: mq.width * .01),
                        child: Text(
                          'MECHANICAL ENGINEERING',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: mq.width * .03),
                        child: Text(
                          'NIT AGARTALA',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Theme.of(context).colorScheme.secondary,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      InkWell(
                        child: Image.asset('assets/images/linkedin.png',
                            width: mq.width * .07),
                        onTap: () async {
                          const url =
                              'https://www.linkedin.com/in/aman-kumar-257613257/';
                          _launchInBrowser(context, Uri.parse(url));
                        },
                      ),
                      InkWell(
                        child: Image.asset('assets/images/github.png',
                            width: mq.width * .07),
                        onTap: () async {
                          const url = 'https://github.com/Aman-Sirmaur19';
                          _launchInBrowser(context, Uri.parse(url));
                        },
                      ),
                      InkWell(
                        child: Image.asset('assets/images/instagram.png',
                            width: mq.width * .07),
                        onTap: () async {
                          const url =
                              'https://www.instagram.com/aman_sirmaur19/';
                          _launchInBrowser(context, Uri.parse(url));
                        },
                      ),
                      InkWell(
                        child: Image.asset('assets/images/twitter.png',
                            width: mq.width * .07),
                        onTap: () async {
                          const url =
                              'https://x.com/AmanSirmaur?t=2QWiqzkaEgpBFNmLI38sbA&s=09';
                          _launchInBrowser(context, Uri.parse(url));
                        },
                      ),
                      InkWell(
                        child: Image.asset('assets/images/youtube.png',
                            width: mq.width * .07),
                        onTap: () async {
                          const url = 'https://www.youtube.com/@AmanSirmaur';
                          _launchInBrowser(context, Uri.parse(url));
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Close'),
                    ),
                  ],
                );
              }),
        ),
        const Spacer(),
        const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text('MADE WITH ❤️ IN 🇮🇳',
              style: TextStyle(
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              )),
        ),
      ],
    ));
  }
}
