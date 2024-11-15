import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../helper/api.dart';
import '../product/chat_screen.dart';

class ChatUsers extends StatelessWidget {
  const ChatUsers({super.key});

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
          'Customers',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(APIs.user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No chat users found.'));
          }

          // Retrieve the list of chat_user_ids
          List<dynamic> chatUserIds = snapshot.data!.get('customers') ?? [];

          // Filter out invalid or empty IDs
          chatUserIds =
              chatUserIds.where((id) => id is String && id.isNotEmpty).toList();

          if (chatUserIds.isEmpty) {
            return const Center(child: Text('No chat users found.'));
          }

          // Fetch details of all users in the chatUserIds list
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where(FieldPath.documentId, whereIn: chatUserIds)
                .snapshots(),
            builder: (context, chatSnapshot) {
              if (chatSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (chatSnapshot.hasError) {
                return Center(child: Text('Error: ${chatSnapshot.error}'));
              }

              if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No chat users found.'));
              }

              final chatUsers = chatSnapshot.data!.docs;

              return ListView.builder(
                itemCount: chatUsers.length,
                itemBuilder: (context, index) {
                  final user = chatUsers[index].data() as Map<String, dynamic>;

                  return ListTile(
                    onTap: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (_) => ChatScreen(id: user['id']))),
                    title: Text(user['name']),
                    subtitle: Text(user['email'] ?? 'No Email'),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
