import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../helper/api.dart';
import '../../helper/dialogs.dart';
import '../../models/product.dart';
import '../../widgets/custom_title.dart';
import '../../widgets/main_drawer.dart';
import '../../widgets/product_card.dart';
import '../auth/login_screen.dart';
import 'product_detail_screen.dart';

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
          customIconButton(const Icon(CupertinoIcons.search), 'Search', () {}),
          customIconButton(
              const Icon(Icons.logout), 'Logout', showLogOutAlertDialog),
        ],
      ),
      drawer: const MainDrawer(),
      body: StreamBuilder(
        stream: APIs.getAllProducts(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            // if data is loading
            case ConnectionState.waiting:
            case ConnectionState.none:
              return const Center(child: CircularProgressIndicator());

            // if data is loaded then show it
            case ConnectionState.active:
            case ConnectionState.done:
              final data = snapshot.data?.docs;
              products.clear();
              if (data != null) {
                for (var doc in data) {
                  final productData = doc.data(); // Access the document data
                  if (productData['seller_id'] != APIs.user.uid) {
                    products.add(Product.fromJson(productData));
                  }
                }
              }
              if (products.isNotEmpty) {
                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Shops',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'See all',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                              // fontSize: 20,
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 150,
                      child: GridView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          childAspectRatio: 1,
                        ),
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          return InkWell(
                              onTap: () {
                                // => Navigator.push(
                                //     context,
                                //     CupertinoPageRoute(
                                //         builder: (_) =>
                                //             ProductDetailScreen(product: product)))
                              },
                              child: Card(
                                elevation: 1,
                                child: ListTile(
                                  title:
                                      const Icon(Icons.store_rounded, size: 70),
                                  subtitle: Text(
                                    'Vendor',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ));
                        },
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Products',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const ScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: .9,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return InkWell(
                            onTap: () => Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (_) =>
                                        ProductDetailScreen(product: product))),
                            child: ProductCard(product: product));
                      },
                    ),
                  ],
                );
              } else {
                return Center(
                  child: Text(
                    'No products found!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black.withOpacity(.68),
                    ),
                  ),
                );
              }
          }
        },
      ),
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
