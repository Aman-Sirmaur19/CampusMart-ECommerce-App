import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../helper/api.dart';
import '../../helper/dialogs.dart';
import '../../models/product.dart';
import '../chat_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _currentImageIndex = 0;
  int _quantity = 1;
  bool _isInCart = false;

  @override
  void initState() {
    super.initState();
    _checkCart();
  }

  Future<void> _checkCart() async {
    _isInCart =
        await APIs.isItemInCart(widget.product.seller_id, widget.product.id);
    setState(() {});
  }

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
          'Product Details',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        foregroundColor: Colors.white,
        backgroundColor: Colors.green,
        shape: const CircleBorder(),
        tooltip: 'Call the seller',
        child: const Icon(CupertinoIcons.phone, size: 30),
      ),
      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        height: 55,
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              onPressed: () => setState(() {
                APIs.toggleItemInCart(
                        widget.product.seller_id, widget.product.id)
                    .then((value) => _checkCart())
                    .then((value) => Dialogs.showSnackBar(
                        context,
                        _isInCart
                            ? 'Item added to cart!'
                            : 'Item removed from cart!'));
              }),
              icon: const Icon(Icons.shopping_cart_rounded),
              label: Text(_isInCart ? 'Added ✔️' : 'Add to cart',
                  textAlign: TextAlign.center),
              style: ButtonStyle(
                minimumSize: MaterialStateProperty.all(const Size(142, 40)),
                iconColor: MaterialStateProperty.all(Colors.black),
                backgroundColor: MaterialStateProperty.all(Colors.amber),
                foregroundColor: MaterialStateProperty.all(Colors.black),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (_) =>
                          ChatScreen(id: widget.product.seller_id))),
              icon: const Icon(CupertinoIcons.chat_bubble_2),
              label: const Text('Chat', textAlign: TextAlign.center),
              style: ButtonStyle(
                minimumSize: MaterialStateProperty.all(const Size(142, 40)),
                iconColor: MaterialStateProperty.all(Colors.white),
                backgroundColor: MaterialStateProperty.all(Colors.blue),
                foregroundColor: MaterialStateProperty.all(Colors.white),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
        child: ListView(
          children: [
            Text(
              widget.product.title,
              style: const TextStyle(
                letterSpacing: 1,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            // Image slider
            SizedBox(
              height: 200,
              child: PageView.builder(
                itemCount: 5,
                onPageChanged: (index) {
                  setState(() {
                    _currentImageIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return const Icon(
                    Icons.shopping_bag_rounded,
                    size: 100,
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            // Indicator for image slider
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        _currentImageIndex == index ? Colors.blue : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'MRP: ',
                                style: TextStyle(
                                  fontSize: 17,
                                  letterSpacing: 1,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                width: 130,
                                child: Text(
                                  '₹${widget.product.price}',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    letterSpacing: 1,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            '(incl. of all taxes.)',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.blueGrey,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                              onPressed: () => setState(() {
                                    if (_quantity > 1) {
                                      _quantity--;
                                    }
                                  }),
                              tooltip: 'Remove',
                              icon: const Icon(Icons.remove_rounded)),
                          Chip(
                              padding: const EdgeInsets.all(2),
                              label: Text('$_quantity',
                                  style: const TextStyle(fontSize: 20))),
                          IconButton(
                              onPressed: () => setState(() {
                                    if (_quantity < widget.product.quantity) {
                                      _quantity++;
                                    }
                                  }),
                              tooltip: 'Add',
                              icon: const Icon(Icons.add_rounded)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                          text: const TextSpan(
                              text: 'Payment: ',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                            TextSpan(
                              text: 'Cash On Delivery',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ])),
                      Text(
                        'Quantity: ${widget.product.quantity}',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Description:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        widget.product.description,
                        style: const TextStyle(
                          fontSize: 17,
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
