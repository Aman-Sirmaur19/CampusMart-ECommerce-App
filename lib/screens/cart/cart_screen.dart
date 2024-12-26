import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../helper/api.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
          icon: const Icon(CupertinoIcons.back),
        ),
        title: const Text(
          'Cart',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: APIs.firestore
            .collection('users')
            .doc(APIs.user.uid)
            .snapshots(), // Listen to cart updates
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading cart items.'));
          }

          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return const Center(child: Text('Your cart is empty.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final cart = data['cart'] as Map<String, dynamic>? ?? {};

          // Convert cart to a list of items
          final cartItems = cart.entries
              .expand((entry) =>
              entry.value.map((item) => {'key': entry.key, 'value': item}))
              .toList();

          if (cartItems.isEmpty) {
            return const Center(child: Text('Your cart is empty.'));
          }

          return ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final item = cartItems[index];
              final sellerId = item['key'];
              final productId = item['value'];

              return ListTile(
                leading: const Icon(Icons.shopping_cart),
                title: Text('Product ID: $productId'),
                subtitle: Text('Seller ID: $sellerId'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    // Remove the item from the cart
                    await APIs.toggleItemInCart(sellerId, productId);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
