import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import '../../helper/api.dart';
import '../../helper/constants.dart';
import '../../helper/dialogs.dart';
import '../../models/product.dart';

class ManageProduct extends StatefulWidget {
  final Product? product;
  final ItemType itemType;

  const ManageProduct({super.key, this.product, required this.itemType});

  @override
  State<ManageProduct> createState() => _ManageProductState();
}

class _ManageProductState extends State<ManageProduct> {
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;

  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _daysController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _titleController.text = widget.product!.title;
      _priceController.text = widget.product!.price.toString();
      _quantityController.text = widget.product!.quantity.toString();
      _daysController.text = widget.product!.days.toString();
      _descriptionController.text = widget.product!.description;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _daysController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Back',
            icon: const Icon(CupertinoIcons.back),
          ),
          title: Text(
            widget.itemType == ItemType.sale
                ? 'Add Product'
                : widget.itemType == ItemType.rental
                    ? 'Add Rental'
                    : 'Add Lost Item',
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.only(
              left: mq.width * .1, right: mq.width * .1, top: mq.height * .15),
          child: Form(
            key: formKey,
            child: ListView(
              children: [
                customTextFormField(
                  name: 'Title',
                  controller: _titleController,
                  isNumber: false,
                ),
                if (widget.itemType != ItemType.lost)
                  const SizedBox(height: 12),
                if (widget.itemType != ItemType.lost)
                  customTextFormField(
                    name: 'Price',
                    controller: _priceController,
                    isNumber: true,
                  ),
                const SizedBox(height: 12),
                customTextFormField(
                  name: 'Quantity',
                  controller: _quantityController,
                  isNumber: true,
                ),
                if (widget.itemType == ItemType.rental)
                  const SizedBox(height: 12),
                if (widget.itemType == ItemType.rental)
                  customTextFormField(
                    name: 'No.of days for rent',
                    controller: _daysController,
                    isNumber: true,
                  ),
                const SizedBox(height: 12),
                customTextFormField(
                  name: 'Description',
                  controller: _descriptionController,
                  isNumber: false,
                ),
                const SizedBox(height: 20),
                isLoading
                    ? const Center(
                        child:
                            CircularProgressIndicator(color: Colors.lightBlue))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (widget.product != null)
                            ElevatedButton(
                              onPressed: () => showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Are you sure?'),
                                  content:
                                      const Text('Do you want to delete this?'),
                                  actions: <Widget>[
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          TextButton(
                                              child: const Text('Yes'),
                                              onPressed: () {
                                                setState(() {
                                                  isLoading = true;
                                                  deleteItem(
                                                      id: widget.product!.id);
                                                });
                                              }),
                                          TextButton(
                                              child: const Text('No'),
                                              onPressed: () {
                                                Navigator.of(ctx).pop();
                                              }),
                                        ])
                                  ],
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                  fontSize: 15,
                                ),
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('Delete'),
                            ),
                          ElevatedButton(
                            onPressed: () => setState(() {
                              isLoading = true;
                              uploadOrUpdateItem(
                                  id: widget.product?.id ??
                                      DateTime.now()
                                          .millisecondsSinceEpoch
                                          .toString());
                            }),
                            style: ElevatedButton.styleFrom(
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                                fontSize: 15,
                              ),
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.lightBlue,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text(
                                widget.product != null ? 'Update' : 'Save'),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void uploadOrUpdateItem({required String id}) {
    if (_titleController.text.trim().isNotEmpty &&
        _quantityController.text.trim().isNotEmpty &&
        _descriptionController.text.trim().isNotEmpty &&
        (widget.itemType == ItemType.lost ||
            (widget.itemType == ItemType.sale &&
                _priceController.text.trim().isNotEmpty) ||
            (widget.itemType == ItemType.rental &&
                _priceController.text.trim().isNotEmpty &&
                _daysController.text.trim().isNotEmpty))) {
      Product item = Product(
        id: id,
        seller_id: APIs.user.uid,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        price: widget.itemType != ItemType.lost
            ? int.parse(_priceController.text.trim())
            : 0,
        quantity: int.parse(_quantityController.text.trim()),
        days: widget.itemType == ItemType.rental
            ? int.parse(_daysController.text.trim())
            : 0,
      );
      try {
        APIs.uploadProduct(item: item, itemType: widget.itemType).then((value) {
          isLoading = false;
          Dialogs.showSnackBar(
              context,
              widget.product == null
                  ? 'Product added successfully!'
                  : 'Product updated successfully!');
          Navigator.pop(context);
        });
      } catch (error) {
        setState(() {
          isLoading = false;
        });
        Dialogs.showErrorSnackBar(context, error.toString());
      }
    } else {
      Dialogs.showErrorSnackBar(context, 'Fill all the fields!');
      isLoading = false;
      return;
    }
  }

  void deleteItem({required String id}) {
    try {
      APIs.deleteProduct(id: id, itemType: widget.itemType).then((value) {
        Dialogs.showSnackBar(context, 'Product deleted successfully!');
        Navigator.pop(context);
        Navigator.pop(context);
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      Dialogs.showErrorSnackBar(context, error.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget customTextFormField({
    required String name,
    required TextEditingController controller,
    required bool isNumber,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.name,
      cursorColor: Colors.blue,
      style: const TextStyle(
          fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1),
      decoration: InputDecoration(
        labelText: name,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.secondary.withOpacity(.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.lightBlue),
        ),
      ),
    );
  }
}
