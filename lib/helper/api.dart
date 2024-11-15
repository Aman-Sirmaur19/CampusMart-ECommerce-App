import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/main_user.dart';
import '../models/message.dart';
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
      } else {
        await createUser('').then((value) => getSelfInfo());
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
  static Future<void> createUser(String college) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final mainUser = MainUser(
      id: user.uid,
      pushToken: '',
      name: 'Unknown',
      college: college,
      email: user.email!,
      createdAt: time,
      customers: [],
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
      seller_id: item.seller_id,
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
