import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sunmolor_team/helper/dimension.dart';

class GroupChatPage extends StatefulWidget {
  final String groupId;

  GroupChatPage({required this.groupId});

  @override
  _GroupChatPageState createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final TextEditingController _messageController = TextEditingController();

  void _sendMessage(String text) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String email = user.email!;
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(email)
            .get();
        if (userDoc.exists) {
          String fullName = userDoc['fullName'];
          await FirebaseFirestore.instance
              .collection('groupChats')
              .doc(widget.groupId)
              .collection('messages')
              .add({
            'sender': fullName,
            'text': text,
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Widget _buildMessageItem(DocumentSnapshot message) {
    bool isMe = message['sender'] == FirebaseAuth.instance.currentUser?.email;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            message['sender'],
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isMe)
                CircleAvatar(
                  child: Text(message['sender'][0]),
                ),
              if (!isMe) const SizedBox(width: 10),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.blue[200] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    message['text'],
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ),
              if (isMe) const SizedBox(width: 10),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(right: 35),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: Colors.transparent,
                backgroundImage: AssetImage('assets/images/Sunmolor.png'),
              ),
              SizedBox(width: 10),
              Text('Sunmolor Team Chat'),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('groupChats')
                  .doc(widget.groupId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    reverse: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var message = snapshot.data!.docs[index];
                      return _buildMessageItem(message);
                    },
                  );
                } else {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        SizedBox(
                          height: Dimensions.size10,
                        ),
                        const Text("Tunggu sebentar pesan sedang dimuat")
                      ],
                    ),
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.black45),
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      controller: _messageController,
                      decoration: InputDecoration(
                        fillColor: Colors.black26,
                        hintText: '  Kirim sebuah pesan ...',
                        hintStyle: const TextStyle(color: Colors.white),
                        filled: true,
                        contentPadding: const EdgeInsets.all(10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: Colors.black),
                  onPressed: () {
                    String text = _messageController.text.trim();
                    if (text.isNotEmpty) {
                      _sendMessage(text);
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
