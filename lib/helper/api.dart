import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/main_user.dart';
import '../models/message.dart';
import '../models/product.dart';
import 'constants.dart';

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

  // for storing seller info
  static late MainUser sellerOrBuyer;

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
      }
    });
  }

  // for getting user info
  static Future<void> getUserInfo(String id) async {
    await firestore.collection('users').doc(id).get().then((user) async {
      if (user.exists) {
        sellerOrBuyer = MainUser.fromJson(user.data()!);
        log('Data: ${user.data()}');
      }
    });
  }

  // for creating a new user
  static Future<void> createUser(MainUser mainUser) async {
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
  static Future<void> uploadProduct(
      {required Product item, required ItemType itemType}) async {
    try {
      // Product to upload
      final Product product = Product(
        id: item.id,
        seller_id: item.seller_id,
        title: item.title,
        description: item.description,
        price: item.price,
        quantity: item.quantity,
        days: item.days,
      );
      String folder = itemType == ItemType.sale
          ? 'products'
          : itemType == ItemType.rental
              ? 'rentals'
              : 'lost';

      // Reference to the Firestore document
      final ref = firestore.collection(
          'colleges/${me.college.trim()}/sellers/${me.email.trim()}/$folder');

      // Upload the product
      await ref.doc(item.id).set(product.toJson());

      if (itemType != ItemType.rental) {
        await ref.doc(item.id).update({'days': FieldValue.delete()});
      }
      if (itemType == ItemType.lost) {
        await ref.doc(item.id).update({'price': FieldValue.delete()});
      }
    } catch (e) {
      print('Error uploading product: $e');
      rethrow;
    }
  }

  // for deleting product
  static Future<void> deleteProduct(
      {required String id, required ItemType itemType}) async {
    String folder = itemType == ItemType.sale
        ? 'products'
        : itemType == ItemType.rental
            ? 'rentals'
            : 'lost';
    firestore
        .collection(
            'colleges/${me.college.trim()}/sellers/${me.email.trim()}/$folder')
        .doc(id)
        .delete();
  }

  // for fetching all the products of college
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllProducts(
      {required ItemType itemType}) {
    return firestore
        .collectionGroup(itemType == ItemType.sale
            ? 'products'
            : itemType == ItemType.rental
                ? 'rentals'
                : 'lost')
        .snapshots();
  }

  // for fetching my products
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyProducts(
      {required ItemType itemType}) {
    return firestore
        .collection('colleges')
        .doc(me.college)
        .collection('sellers')
        .doc(me.email)
        .collection(itemType == ItemType.sale
            ? 'products'
            : itemType == ItemType.rental
                ? 'rentals'
                : 'lost')
        .snapshots();
  }

  // for checking if the product is already in the cart or not
  static Future<bool> isItemInCart(String key, String value) async {
    try {
      // Get the existing cart from Firestore
      final doc = await firestore.collection('users').doc(user.uid).get();
      final data = doc.data();

      if (data != null && data['cart'] is Map) {
        // Parse the cart to a Map<String, List<String>>
        Map<String, List<String>> cart =
            (data['cart'] as Map).map<String, List<String>>(
          (key, value) => MapEntry(
            key as String,
            (value as List).map((item) => item.toString()).toList(),
          ),
        );

        // Check if the key exists and the value is in the list
        if (cart.containsKey(key) && cart[key]!.contains(value)) {
          return true; // Item is in the cart
        }
      }
      return false; // Item is not in the cart
    } catch (e) {
      print('Error checking item in cart: $e');
      return false; // Return false in case of an error
    }
  }

  // for adding and removing product from cart
  static Future<void> toggleItemInCart(String key, String value) async {
    try {
      // Check if the item is already in the cart
      bool isInCart = await isItemInCart(key, value);

      // Get the existing cart from Firestore
      final doc = await firestore.collection('users').doc(user.uid).get();
      final data = doc.data();

      if (data != null && data['cart'] is Map) {
        // Parse the cart to a Map<String, List<String>>
        Map<String, List<String>> cart =
            (data['cart'] as Map).map<String, List<String>>(
          (key, value) => MapEntry(
            key as String,
            (value as List).map((item) => item.toString()).toList(),
          ),
        );

        if (isInCart) {
          // Remove the value if it exists
          cart[key]!.remove(value);
          if (cart[key]!.isEmpty) {
            cart.remove(key); // Remove the key if the list becomes empty
          }
        } else {
          // Add the value if it doesn't exist
          if (!cart.containsKey(key)) {
            cart[key] = [];
          }
          cart[key]!.add(value);
        }

        // Update the cart in Firestore
        await firestore
            .collection('users')
            .doc(user.uid)
            .update({'cart': cart});
        print('Cart updated successfully');
      } else if (!isInCart) {
        // If no cart exists, initialize and add the item
        await firestore.collection('users').doc(user.uid).update({
          'cart': {
            key: [value]
          }
        });
        print('Cart initialized and item added');
      }
    } catch (e) {
      print('Error toggling item in cart: $e');
    }
  }

  /// ******** ChatScreen related API *********

  // chats (collection) -> conversation_id (doc) -> messages -> (collection) -> message (doc)

  // useful for getting conversation id
  static String getConversationId(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  // for getting all messages of a specific conversation from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      MainUser user) {
    return firestore
        .collection('chats/${getConversationId(user.id)}/messages/')
        .snapshots();
  }

  // for sending message
  static Future<void> sendMessage(MainUser receiver, String msg) async {
    // message sending time (also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    // message to send
    final Message message = Message(
      msg: msg,
      toId: receiver.id,
      read: '',
      type: Type.text,
      sent: time,
      fromId: user.uid,
    );

    final ref = firestore
        .collection('chats/${getConversationId(receiver.id)}/messages/');
    await ref.doc(time).set(message.toJson());

    // Reference to the current user's document
    final userRef = firestore.collection('users').doc(receiver.id);

    log(receiver.id);
    await userRef.update({
      'customers': FieldValue.arrayUnion([user.uid]),
    });
  }

  // update read status of sent message
  static Future<void> updateMessageStatus(Message message) async {
    firestore
        .collection('chats/${getConversationId(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  // get only last message of a specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessages(
      MainUser user) {
    return firestore
        .collection('chats/${getConversationId(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }
}
