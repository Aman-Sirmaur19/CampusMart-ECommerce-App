import 'package:flutter/material.dart';

import '../helper/constants.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final ItemType itemType;

  const ProductCard({super.key, required this.product, required this.itemType});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: Icon(Icons.shopping_bag_rounded, size: 50)),
            const SizedBox(height: 20),
            Text(
              product.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 19,
              ),
            ),
            Text(
              itemType == ItemType.lost
                  ? product.description
                  : '₹${product.price}',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: itemType == ItemType.lost ? 15 : 19,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
