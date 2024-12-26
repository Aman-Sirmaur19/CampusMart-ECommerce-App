import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../helper/api.dart';
import '../main.dart';
import '../models/main_user.dart';
import '../models/message.dart';
import '../widgets/message_card.dart';

class ChatScreen extends StatefulWidget {
  final String id;

  const ChatScreen({super.key, required this.id});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  MainUser? sellerOrBuyer;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    await APIs.getUserInfo(widget.id);
    setState(() {
      sellerOrBuyer = APIs.sellerOrBuyer;
    });
  }

  // for storing all messages
  List<Message> _list = [];

  // for handling message text changes
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Back',
            icon: const Icon(CupertinoIcons.back),
          ),
          title: sellerOrBuyer == null
              ? const Center(child: CircularProgressIndicator())
              : Text(
                  sellerOrBuyer!.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
          actions: [
            IconButton(
              icon: const Icon(CupertinoIcons.ellipsis_vertical),
              onPressed: () {},
            ),
          ],
        ),
        body: sellerOrBuyer == null
            ? const Center(child: CircularProgressIndicator())
            : SizedBox(
                height: mq.height,
                child: Column(
                  children: [
                    Expanded(
                      child: StreamBuilder(
                        stream: APIs.getAllMessages(sellerOrBuyer!),
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                            case ConnectionState.none:
                              return const Center(
                                  child: CircularProgressIndicator());

                            case ConnectionState.active:
                            case ConnectionState.done:
                              final data = snapshot.data?.docs;
                              _list = data
                                      ?.map((e) => Message.fromJson(e.data()))
                                      .toList() ??
                                  [];
                              if (_list.isNotEmpty) {
                                return ListView.builder(
                                  padding:
                                      EdgeInsets.only(top: mq.height * .01),
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: _list.length,
                                  itemBuilder: (context, index) {
                                    return MessageCard(message: _list[index]);
                                  },
                                );
                              } else {
                                return Center(
                                  child: Text(
                                    'Say Hi! 👋',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black.withOpacity(.68),
                                    ),
                                  ),
                                );
                              }
                          }
                        },
                      ),
                    ),
                    _chatInput(),
                  ],
                ),
              ),
      ),
    );
  }

  // bottom chat text input field
  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mq.height * .005, horizontal: mq.width * .02),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.emoji_emotions,
                      color: Colors.black54,
                    ),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: 'Send message...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.image,
                      color: Colors.black54,
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.black54,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          MaterialButton(
            onPressed: () {
              if (_textController.text.trim().isNotEmpty) {
                APIs.sendMessage(sellerOrBuyer!, _textController.text);
                _textController.text = '';
              }
            },
            minWidth: 0,
            padding: const EdgeInsets.only(
              right: 5,
              left: 10,
              top: 10,
              bottom: 10,
            ),
            shape: const CircleBorder(),
            color: Colors.green[300],
            child: const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
