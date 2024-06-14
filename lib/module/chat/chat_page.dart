import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:sunmolor_team/helper/dimension.dart';
import 'package:sunmolor_team/overlay/error_overlay.dart';

class GroupChatPage extends StatefulWidget {
  final String groupId;

  GroupChatPage({required this.groupId});

  @override
  _GroupChatPageState createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final TextEditingController _messageController = TextEditingController();
  String? _editingMessageId;

  void _sendMessage(String text) async {
    try {
      String? email = FirebaseAuth.instance.currentUser?.email;
      if (email == null) {
        Navigator.of(context).push(
          ErrorOverlay(
            message: "Akun tidak ada. Cek Akunmu\nAtau coba login ulang",
          ),
        );
        print('User email is null');
        return;
      }
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String email = user.email!;
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(email)
            .get();
        if (userDoc.exists) {
          String fullName = userDoc['fullName'];
          if (_editingMessageId == null) {
            await FirebaseFirestore.instance
                .collection('Sunmolor Team Chat Group')
                .doc('Chat Group')
                .collection('Pesan')
                .add({
              'Pengirim': email, // Ensure this is storing the email
              'Pesan': text,
              'Tanggal Dikirim Pesan': FieldValue.serverTimestamp(),
            });
          } else {
            await FirebaseFirestore.instance
                .collection('Sunmolor Team Chat Group')
                .doc('Chat Group')
                .collection('Pesan')
                .doc(_editingMessageId)
                .update({'Pesan': text});
            setState(() {
              _editingMessageId = null;
            });
          }
        }
      }
    } catch (e) {
      Navigator.of(context).push(
        ErrorOverlay(
          message: "$e",
        ),
      );
      print('Error sending message: $e');
    }
  }

  void _deleteMessage(String messageId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Sunmolor Team Chat Group')
          .doc('Chat Group')
          .collection('Pesan')
          .doc(messageId)
          .delete();
    } catch (e) {
      Navigator.of(context).push(
        ErrorOverlay(
          message: "$e",
        ),
      );
      print('Error deleting message: $e');
    }
  }

  void _editMessage(DocumentSnapshot message) {
    setState(() {
      _messageController.text = message['Pesan'];
      _editingMessageId = message.id;
    });
  }

  Widget _buildMessageItem(DocumentSnapshot message) {
    bool isMe = message['Pengirim'] == FirebaseAuth.instance.currentUser?.email;
    return Dismissible(
      key: Key(message.id),
      background: Container(
        color: Colors.blue,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Icon(Icons.edit, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Edit action
          DateTime sentTime = (message['Tanggal Dikirim Pesan'] as Timestamp).toDate();
          bool canEdit = DateTime.now().difference(sentTime).inMinutes <= 10;
          if (canEdit && isMe) {
            _editMessage(message);
            return false; // To avoid dismissing the item
          } else {
            return false; // Edit not allowed
          }
        } else if (direction == DismissDirection.endToStart) {
          // Delete action
          if (isMe) {
            _deleteMessage(message.id);
            return true; // To dismiss the item
          } else {
            return false; // Delete not allowed
          }
        }
        return false;
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message['Pengirim'],
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment:
                  isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                if (!isMe)
                  CircleAvatar(
                    child: Text(message['Pengirim'][0]),
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
                      message['Pesan'],
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                if (isMe) const SizedBox(width: 10),
              ],
            ),
          ],
        ),
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
                  .collection('Sunmolor Team Chat Group')
                  .doc('Chat Group')
                  .collection('Pesan')
                  .orderBy('Tanggal Dikirim Pesan', descending: true)
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
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Lottie.asset(
                                "assets/lottie/load_message.json",
                                frameRate: const FrameRate(60),
                                width: 200,
                                repeat: true,
                              ),
                              Text(
                                "Memuat data chat...",
                                style: TextStyle(
                                  fontSize: Dimensions.text20,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
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
                        hintStyle: TextStyle(color: Colors.orange[200]),
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
                  icon: Icon(Icons.send_rounded, color: Colors.orange[200]),
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
