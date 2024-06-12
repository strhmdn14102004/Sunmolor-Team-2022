import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sunmolor_team/helper/dimension.dart';
import 'package:sunmolor_team/module/auth/signup/verify_data_kendaraan_page.dart';
import 'package:sunmolor_team/overlay/error_overlay.dart';
import 'package:sunmolor_team/overlay/success_overlay.dart';

class VerifyDataPage extends StatefulWidget {
  @override
  _VerifyDataPageState createState() => _VerifyDataPageState();
}

class _VerifyDataPageState extends State<VerifyDataPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _nickNameController =
      TextEditingController(); // Added nickname field
  final TextEditingController _addressController =
      TextEditingController(); // Added address field
  final TextEditingController _phoneNumberController =
      TextEditingController(); // Added phone number field
  final TextEditingController _birthDateController = TextEditingController();
  File? _image;
  String _gender = '';
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    _loadUserDataFromFirestore();
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
            _imageUrl = userDoc[
                'profileImageURL']; // Ambil URL gambar profil dari Firestore
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
        String email = user.email!; // Ambil email pengguna saat ini

        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(email) // Ambil dokumen berdasarkan email
            .get();

        if (userDoc.exists) {
          print(
              'Data from Firestore: ${userDoc.data()}'); // Print data from Firestore
          setState(() {
            // Isi kontrol formulir berdasarkan data yang diambil dari Firestore
            _fullNameController.text = userDoc['fullName'];
            _nickNameController.text =
                userDoc['nickName']; // Set nickname field
            _addressController.text = userDoc['address']; // Set address field
            _phoneNumberController.text =
                userDoc['phoneNumber']; // Set phone number field
            _birthDateController.text = userDoc['birthDate'];
            _gender = userDoc['gender'];
          });

          // Load profile image URL if exists
          String? profileImageURL = userDoc['profileImageURL'];
          if (profileImageURL != null && profileImageURL.isNotEmpty) {
            // Load profile image from URL if exists
            // Download the image and store it locally
            try {
              final response = await http.get(Uri.parse(profileImageURL));
              final bytes = response.bodyBytes;

              // Save the image to local storage
              final directory = await getApplicationDocumentsDirectory();
              final imagePath = '${directory.path}/profile_image.jpg';
              File imageFile = File(imagePath);
              await imageFile.writeAsBytes(bytes);

              // Set the image file to the state
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
      body: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Hallo",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic),
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
                    radius: 70,
                    backgroundImage: _image != null
                        ? FileImage(_image!) as ImageProvider<Object>?
                        : (_imageUrl != null ? NetworkImage(_imageUrl!) : null),
                  ),
                ),
                SizedBox(height: Dimensions.size10),
                const Text("Klik image untuk mengupload photo profile"),
                SizedBox(height: Dimensions.size30),
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20.0), // Adjust the radius as needed
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nickNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Panggilan',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20.0), // Adjust the radius as needed
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Alamat Lengkap',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20.0), // Adjust the radius as needed
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  keyboardType: TextInputType.number,
                  controller: _phoneNumberController,
                  decoration: const InputDecoration(
                    labelText: 'No Handphone',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20.0), // Adjust the radius as needed
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
                    child: TextFormField(
                      controller: _birthDateController,
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Lahir',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(
                                20.0), // Adjust the radius as needed
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
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
                        Radius.circular(20.0), // Adjust the radius as needed
                      ),
                    ),
                    labelText: 'Jenis Kelamin',
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    _uploadDataToFirestore(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15), // Increase padding
                    minimumSize:
                        const Size(double.infinity, 50), // Set button size
                  ),
                  child: const Text(
                    'Simpan',
                    style: TextStyle(fontSize: 16),
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
        _imageUrl = null; // Reset imageUrl to null since a new image is chosen
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
        print('User email is null');
        return;
      }

      String fullName = _fullNameController.text.trim();
      String nickName = _nickNameController.text.trim();
      String address = _addressController.text.trim();
      String phoneNumber = _phoneNumberController.text.trim();
      String birthDate = _birthDateController.text.trim();
      String gender = _gender;

      // Validate that all fields are filled
      if (fullName.isEmpty ||
          nickName.isEmpty ||
          address.isEmpty ||
          phoneNumber.isEmpty ||
          birthDate.isEmpty ||
          gender.isEmpty) {
        Navigator.of(context).push(
          ErrorOverlay(
            message: "Isi data diri terlebih dahulu",
          ),
        );

        return; // Stop execution if any field is empty
      }

      // Add data to Firestore
      await FirebaseFirestore.instance.collection('users').doc(email).set({
        'fullName': fullName,
        'nickName': nickName,
        'address': address,
        'phoneNumber': phoneNumber,
        'birthDate': birthDate,
        'gender': gender,
        'profileImageURL':
            _image != null ? await _uploadImageToFirebaseStorage() : null,
      });

      // Navigate to the next page after successful upload
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => VerifyDataKendaraanPage(),
        ),
      );
      // Show success overlay
      Navigator.of(context).push(
        SuccessOverlay(
          message:
              "Data diri berhasil disimpan\nLanjutkan Isi Informasi Kendaraan kamu",
        ),
      );
    } catch (e) {
      print('Error uploading data to Firestore: $e');
      // Show error overlay
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
        .child('$userEmail.jpg'); // Nama file disesuaikan dengan email pengguna
    await ref.putFile(_image!);
    String imageUrl = await ref.getDownloadURL();
    return imageUrl;
  } catch (e) {
    print('Error uploading image to Firebase Storage: $e');
    throw e;
  }
}
}
