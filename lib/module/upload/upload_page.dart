import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class UploadPage extends StatefulWidget {
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _uploadImageToFirestore();
    }
  }

  Future<void> _uploadImageToFirestore() async {
    if (_image == null) return;

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String email = user.email!;
        Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('uploads')
            .child(email)
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
        UploadTask uploadTask = storageReference.putFile(_image!);
        await uploadTask.whenComplete(() => null);
        String imageUrl = await storageReference.getDownloadURL();

        await FirebaseFirestore.instance.collection('uploads').add({
          'email': email,
          'imageUrl': imageUrl,
          'timestamp': Timestamp.now(),
        });
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> _downloadImage(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    final bytes = response.bodyBytes;

    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/downloaded_image.jpg';
    File imageFile = File(imagePath);
    await imageFile.writeAsBytes(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Image'),
      ),
      body: Column(
        children: [
          _image != null
              ? Image.file(
                  _image!,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : Placeholder(
                  fallbackHeight: 300,
                  fallbackWidth: double.infinity,
                ),
          ElevatedButton(
            onPressed: _pickImage,
            child: Text('Pick Image'),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('uploads')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0,
                  ),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    String imageUrl = doc['imageUrl'];
                    return GestureDetector(
                      onTap: () {
                        _downloadImage(imageUrl);
                      },
                      child: GridTile(
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Image.network(imageUrl, fit: BoxFit.cover),
                            ElevatedButton(
                              onPressed: () {
                                _downloadImage(imageUrl);
                              },
                              child: Text('Download'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
