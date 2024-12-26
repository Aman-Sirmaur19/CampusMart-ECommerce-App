import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../helper/api.dart';
import '../../helper/constants.dart';
import '../../models/product.dart';
import '../../widgets/product_card.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatelessWidget {
  ProductsScreen({super.key, this.isHome = false, required this.itemType});

  final bool isHome;
  final ItemType itemType;
  final List<Product> products = [];

  @override
  Widget build(BuildContext context) {
    return !isHome
        ? Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Back',
                icon: const Icon(CupertinoIcons.back),
              ),
              title: Text(
                itemType == ItemType.sale
                    ? 'Products'
                    : itemType == ItemType.rental
                        ? 'Rental Items'
                        : 'Lost Items',
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: _body(),
          )
        : _body();
  }

  Widget _body() {
    return StreamBuilder(
      stream: APIs.getAllProducts(itemType: itemType),
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
                final productData = doc.data();
                if (itemType != ItemType.rental) {
                  productData.addAll({'days': 0}); // new line
                }
                if (itemType == ItemType.lost) {
                  productData.addAll({'price': 0});
                }
                if (productData['seller_id'] != APIs.user.uid) {
                  products.add(Product.fromJson(productData));
                }
              }
            }
            if (products.isNotEmpty) {
              return GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                shrinkWrap: true,
                physics: const ScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: .9,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: !isHome || products.length < 4 ? products.length : 4,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return InkWell(
                      onTap: () => Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (_) =>
                                  ProductDetailScreen(product: product))),
                      child: ProductCard(product: product, itemType: itemType));
                },
              );
            } else {
              return Center(
                child: Text(
                  itemType == ItemType.sale
                      ? 'No products found!'
                      : itemType == ItemType.rental
                          ? 'No rental items found!'
                          : 'No lost items found!',
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
    );
  }
}
