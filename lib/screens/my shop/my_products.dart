import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'add_product.dart';

class MyProducts extends StatefulWidget {
  const MyProducts({super.key});

  @override
  State<MyProducts> createState() => _MyProductsState();
}

class _MyProductsState extends State<MyProducts> {
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
          'My Shop',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(context,
                CupertinoPageRoute(builder: (_) => const AddProduct())),
            tooltip: 'Add product',
            icon: const Icon(CupertinoIcons.add),
          ),
        ],
      ),
    );
  }
}
