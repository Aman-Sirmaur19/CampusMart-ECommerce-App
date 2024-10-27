import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../main.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    priceController.dispose();
    quantityController.dispose();
    descriptionController.dispose();
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
          title: const Text(
            'Add Product',
            style: TextStyle(
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
                  controller: titleController,
                  isNumber: false,
                ),
                const SizedBox(height: 12),
                customTextFormField(
                  name: 'Price',
                  controller: priceController,
                  isNumber: true,
                ),
                const SizedBox(height: 12),
                customTextFormField(
                  name: 'Quantity',
                  controller: quantityController,
                  isNumber: true,
                ),
                const SizedBox(height: 12),
                customTextFormField(
                  name: 'Description',
                  controller: descriptionController,
                  isNumber: false,
                ),
                const SizedBox(height: 20),
                isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.lightBlue))
                    : ElevatedButton(
                        onPressed: () {},
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
                        child: const Text('Save'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
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
