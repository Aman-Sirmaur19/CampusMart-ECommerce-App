import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../helper/api.dart';
import '../../helper/constants.dart';
import '../../models/product.dart';
import 'manage_product.dart';

class MyStore extends StatefulWidget {
  final ItemType itemType;

  const MyStore({super.key, required this.itemType});

  @override
  State<MyStore> createState() => _MyStoreState();
}

class _MyStoreState extends State<MyStore> {
  List<Product> products = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
          icon: const Icon(CupertinoIcons.back),
        ),
        title: Text(
          widget.itemType == ItemType.sale
              ? 'My Store'
              : widget.itemType == ItemType.rental
                  ? 'Rentals'
                  : 'Lost Items',
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            tooltip: 'Search',
            icon: const Icon(CupertinoIcons.search),
          ),
          IconButton(
            onPressed: () => Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (_) => ManageProduct(itemType: widget.itemType))),
            tooltip: 'Add product',
            icon: const Icon(CupertinoIcons.add),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: APIs.getMyProducts(itemType: widget.itemType),
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
              // products =
              //     data?.map((e) => Product.fromJson(e.data())).toList() ?? [];
              products = data?.map(
                    (e) {
                      final map = Map<String, dynamic>.from(e.data());
                      if (widget.itemType != ItemType.rental) {
                        map['days'] = 0;
                      }
                      if (widget.itemType == ItemType.lost) {
                        map['price'] = 0;
                      }
                      return Product.fromJson(map);
                    },
                  ).toList() ??
                  [];

              if (products.isNotEmpty) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Card(
                      child: ListTile(
                        onTap: () => Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (_) => ManageProduct(
                                      product: product,
                                      itemType: widget.itemType,
                                    ))),
                        leading: const Icon(Icons.shopping_basket_outlined),
                        title: Text(
                          product.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              widget.itemType != ItemType.lost
                                  ? '₹${product.price}'
                                  : product.description,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade600),
                            ),
                            const SizedBox(width: 50),
                            Text(
                              'Qty.: ${product.quantity}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else {
                return Center(
                  child: Text(
                    widget.itemType == ItemType.sale
                        ? 'No products found!'
                        : widget.itemType == ItemType.rental
                            ? 'No rentals found!'
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
      ),
    );
  }
}
