import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
          await FirebaseFirestore.instance
              .collection('Sunmolor Team Chat Group')
              .doc('Chat Group')
              .collection('Pesan')
              .add({
            'Pengirim': fullName,
            'Pesan': text,
            'Tanggal Dikirim Pesan': FieldValue.serverTimestamp(),
          });
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

  Widget _buildMessageItem(DocumentSnapshot message) {
    bool isMe = message['Pengirim'] == FirebaseAuth.instance.currentUser?.email;
    return Container(
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
                  icon: const Icon(Icons.send_rounded,),
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
