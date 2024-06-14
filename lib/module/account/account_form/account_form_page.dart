import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sunmolor_team/helper/dimension.dart';
import 'package:sunmolor_team/overlay/error_overlay.dart';
import 'package:sunmolor_team/overlay/no_account_registered.dart';
import 'package:sunmolor_team/overlay/success_overlay.dart';

class AccountFormPage extends StatefulWidget {
  @override
  _AccountFormPageState createState() => _AccountFormPageState();
}

class _AccountFormPageState extends State<AccountFormPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _nickNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  File? _image;
  String _gender = '';
  String? _imageUrl;
  String? _backgroundImageUrl;
  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    _loadBackgroundImage();
    _loadUserDataFromFirestore();
  }

  void _loadBackgroundImage() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String email = user.email!;
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(email)
            .get();

        if (userDoc.exists) {
          setState(() {
            _backgroundImageUrl = userDoc['backgroundImageURL'];
          });
        }
      }
    } catch (e) {
      print('Error loading background image: $e');
    }
  }

  void _loadProfileImage() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String email = user.email!;
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(email)
            .get();
        if (userDoc.exists) {
          setState(() {
            _imageUrl = userDoc['profileImageURL'];
          });
        }
      }
    } catch (e) {
      print('Error loading profile image: $e');
    }
  }

  void _loadUserDataFromFirestore() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String email = user.email!;
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(email)
            .get();

        if (userDoc.exists) {
          print('Data from Firestore: ${userDoc.data()}');
          setState(() {
            _fullNameController.text = userDoc['fullName'];
            _nickNameController.text = userDoc['nickName'];
            _addressController.text = userDoc['address'];
            _phoneNumberController.text = userDoc['phoneNumber'];
            _birthDateController.text = userDoc['birthDate'];
            _gender = userDoc['gender'];
          });
          String? profileImageURL = userDoc['profileImageURL'];
          if (profileImageURL != null && profileImageURL.isNotEmpty) {
            try {
              final response = await http.get(Uri.parse(profileImageURL));
              final bytes = response.bodyBytes;
              final directory = await getApplicationDocumentsDirectory();
              final imagePath = '${directory.path}/profile_image.jpg';
              File imageFile = File(imagePath);
              await imageFile.writeAsBytes(bytes);
              setState(() {
                _image = imageFile;
              });
            } catch (e) {
              print('Error downloading profile image: $e');
            }
          }
        }
      }
    } catch (e) {
      print('Error loading user data from Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String email = user != null ? user.email ?? "" : "";
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: _backgroundImageUrl != null
              ? DecorationImage(
                  image: NetworkImage(_backgroundImageUrl!), fit: BoxFit.cover)
              : null,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: Text(
                    "Hallo",
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic),
                  ),
                ),
                SizedBox(
                  height: Dimensions.size5,
                ),
                Text(
                  email,
                  style: const TextStyle(fontSize: 20),
                ),
                SizedBox(
                  height: Dimensions.size20,
                ),
                GestureDetector(
                  onTap: () {
                    _selectImage(context);
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.orange[200],
                    radius: 70,
                    backgroundImage: _image != null
                        ? FileImage(_image!) as ImageProvider<Object>?
                        : (_imageUrl != null ? NetworkImage(_imageUrl!) : null),
                  ),
                ),
                SizedBox(height: Dimensions.size10),
                const Text("Klik image untuk mengupload photo profile"),
                SizedBox(height: Dimensions.size30),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.black54),
                  child: TextFormField(
                    style: const TextStyle(color: Colors.white),
                    controller: _fullNameController,
                    decoration: const InputDecoration(
                      counterStyle: TextStyle(color: Colors.white),
                      labelText: 'Nama Lengkap',
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20.0),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.black54),
                  child: TextFormField(
                    style: const TextStyle(color: Colors.white),
                    controller: _nickNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Panggilan',
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20.0),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.black54),
                  child: TextFormField(
                    style: const TextStyle(color: Colors.white),
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelStyle: TextStyle(color: Colors.white),
                      labelText: 'Alamat Lengkap',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20.0),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.black54),
                  child: TextFormField(
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    controller: _phoneNumberController,
                    decoration: const InputDecoration(
                      labelText: 'No Handphone',
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20.0),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    _selectDate(context);
                  },
                  child: AbsorbPointer(
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.black54),
                      child: TextFormField(
                        style: const TextStyle(color: Colors.white),
                        controller: _birthDateController,
                        decoration: const InputDecoration(
                          labelText: 'Tanggal Lahir',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.black54),
                  child: DropdownButtonFormField<String>(
                    style: const TextStyle(color: Colors.white),
                    value: _gender,
                    onChanged: (value) {
                      setState(() {
                        _gender = value!;
                      });
                    },
                    items: <String>['', 'Pria', 'Wanita', 'Other']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20.0),
                        ),
                      ),
                      labelStyle: TextStyle(color: Colors.white),
                      labelText: 'Jenis Kelamin',
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    _uploadDataToFirestore(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text(
                    'Simpan',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.orange[200],
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _selectImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _imageUrl = null;
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _birthDateController.text =
            "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
      });
    }
  }

  void _uploadDataToFirestore(BuildContext context) async {
    try {
      String? email = FirebaseAuth.instance.currentUser?.email;
      if (email == null) {
        Navigator.of(context).push(
          ErrorNoAccount(
            message: "Akun tidak ada. Cek Akunmu\nAtau coba login ulang",
          ),
        );
        print('User email is null');
        return;
      }
      String fullName = _fullNameController.text.trim();
      String nickName = _nickNameController.text.trim();
      String address = _addressController.text.trim();
      String phoneNumber = _phoneNumberController.text.trim();
      String birthDate = _birthDateController.text.trim();
      String gender = _gender;
      if (fullName.isEmpty ||
          nickName.isEmpty ||
          address.isEmpty ||
          phoneNumber.isEmpty ||
          birthDate.isEmpty ||
          gender.isEmpty) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('Please fill in all fields.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        return;
      }
      await FirebaseFirestore.instance.collection('users').doc(email).set({
        'fullName': fullName,
        'nickName': nickName,
        'address': address,
        'phoneNumber': phoneNumber,
        'backgroundImageURL': '',
        'birthDate': birthDate,
        'gender': gender,
        'profileImageURL':
            _image != null ? await _uploadImageToFirebaseStorage() : null,
      });
      Navigator.of(context).push(
        SuccessOverlay(
          message: "Profile Berhasil diupload",
        ),
      );
    } catch (e) {
      print('Error uploading data to Firestore: $e');
      Navigator.of(context).push(
        ErrorOverlay(
          message: "Profile Gagal diupload",
        ),
      );
    }
  }

  Future<String> _uploadImageToFirebaseStorage() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User is not authenticated');
      }
      String userEmail = user.email ?? '';
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child('$userEmail.jpg');
      await ref.putFile(_image!);
      String imageUrl = await ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print('Error uploading image to Firebase Storage: $e');
      throw e;
    }
  }
}
