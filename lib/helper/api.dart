import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/main_user.dart';
import '../models/product.dart';

class APIs {
  // for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  // for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // for accessing firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  /// ******** User related API *********

  // for storing self info
  static late MainUser me;

  static User get user => auth.currentUser!;

  // for getting current user info
  static Future<void> getSelfInfo() async {
    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .get()
        .then((user) async {
      if (user.exists) {
        me = MainUser.fromJson(user.data()!);
        log('My Data: ${user.data()}');
      } else {
        await createUser('').then((value) => getSelfInfo());
      }
    });
  }

  // for creating a new user
  static Future<void> createUser(String college) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final mainUser = MainUser(
      id: user.uid,
      name: 'Unknown',
      college: college,
      email: user.email!,
      createdAt: time,
      isVerified: false,
    );

    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(mainUser.toJson());
  }

  // for getting all users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firestore.collection('users').snapshots();
  }

  // for updating user info
  static Future<void> updateUserInfo() async {
    await firestore.collection('users').doc(user.uid).update({
      'name': me.name,
      'college': me.college,
      'email': me.email,
    });
  }

  // for uploading product
  static Future<void> uploadProduct(Product item) async {
    // product to upload
    final Product product = Product(
      id: item.id,
      title: item.title,
      description: item.description,
      price: item.price,
      quantity: item.quantity,
    );

    final ref = firestore.collection(
        'colleges/${me.college.trim()}/sellers/${me.email.trim()}/products');
    await ref.doc(item.id).set(product.toJson());
  }

  // for deleting product
  static Future<void> deleteProduct(String id) async {
    firestore
        .collection(
            'colleges/${me.college.trim()}/sellers/${me.email.trim()}/products')
        .doc(id)
        .delete();
  }

  // for fetching all the products of college
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllProducts() {
    return firestore.collectionGroup('products').snapshots();
  }

  // for fetching my products
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyProducts() {
    return firestore
        .collection('colleges')
        .doc(me.college)
        .collection('sellers')
        .doc(me.email)
        .collection('products')
        .snapshots();
  }
}
