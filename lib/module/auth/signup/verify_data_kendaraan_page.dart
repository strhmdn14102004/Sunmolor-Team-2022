import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sunmolor_team/helper/dimension.dart';
import 'package:sunmolor_team/module/auth/login/login_page.dart';
import 'package:sunmolor_team/overlay/error_overlay.dart';
import 'package:sunmolor_team/overlay/success_overlay.dart';

class VerifyDataKendaraanPage extends StatefulWidget {
  @override
  _VerifyDataKendaraanPageState createState() =>
      _VerifyDataKendaraanPageState();
}

class _VerifyDataKendaraanPageState extends State<VerifyDataKendaraanPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _nickNameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  File? _image;
  String _gender = '';
  String _phoneNumberController = '';
  String? _imageUrl;
  List<String> _pabrikanAsalList = [];
  List<String> _jenisbbm = [];
  String? selectedFuelType;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    _loadUserDataFromFirestore();
    _fetchPabrikanAsalList();
    _fetchJenisBBM();
  }

  void _fetchPabrikanAsalList() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Jenis Kendaraan').get();

      List<String> list = [];
      querySnapshot.docs.forEach((doc) {
        list.add(doc.id);
      });

      setState(() {
        _pabrikanAsalList = list;
      });
    } catch (e) {
      print('Error fetching pabrikan asal list: $e');
    }
  }

  void _fetchJenisBBM() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Jenis BBM').get();

      List<String> list = [];
      querySnapshot.docs.forEach((doc) {
        list.add(doc.id);
      });

      setState(() {
        _jenisbbm = list;
      });
    } catch (e) {
      print('Error fetching jenis bbm list: $e');
    }
  }

  void _loadProfileImage() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String email = user.email!;
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('kendaraan')
            .doc(email)
            .get();

        if (userDoc.exists) {
          setState(() {
            _imageUrl = userDoc['kendaraanImageURL'];
          });
        }
      }
    } catch (e) {
      print('Error loading photo kendaraan: $e');
    }
  }

  void _loadUserDataFromFirestore() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String email = user.email!;

        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('kendaraan')
            .doc(email)
            .get();

        if (userDoc.exists) {
          print('Data from Firestore: ${userDoc.data()}');
          setState(() {
            _fullNameController.text = userDoc['Nama Kendaraan'];
            _nickNameController.text = userDoc['Nomor Polisi Kendaraan'];
            _birthDateController.text = userDoc['Exp Pajak Kendaraan'];
            _phoneNumberController = userDoc['Jenis BBM'];
            _gender = userDoc['Pabrikan Asal'];
          });

          String? profileImageURL = userDoc['kendaraanImageURL'];
          if (profileImageURL != null && profileImageURL.isNotEmpty) {
            try {
              final response = await http.get(Uri.parse(profileImageURL));
              final bytes = response.bodyBytes;

              final directory = await getApplicationDocumentsDirectory();
              final imagePath = '${directory.path}/kendaraan_image.jpg';
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
      body: Padding(
        padding: const EdgeInsets.only(top: 150),
        child: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _selectImage(context);
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.orange[200],
                        radius: 70,
                        backgroundImage: _image != null
                            ? FileImage(_image!) as ImageProvider<Object>?
                            : (_imageUrl != null
                                ? NetworkImage(_imageUrl!)
                                : null),
                      ),
                    ),
                    SizedBox(height: Dimensions.size10),
                    const Text(
                        "Klik image untuk mengupload photo kendaraan kamu"),
                    SizedBox(height: Dimensions.size10),
                    const Text(
                      "Hallo isi data kendaraan kamu ya",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic),
                    ),
                    SizedBox(
                      height: Dimensions.size20,
                    ),
                    TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Kendaraan',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(20.0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nickNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nomor Polisi Kendaraan',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(20.0),
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
                    value: _phoneNumberController,
                    onChanged: (value) {
                      setState(() {
                        _phoneNumberController = value!;
                      });
                    },
                    items: <String>[
                      '',
                      'Pertalite',
                      'Pertamax 92',
                      'Pertamax Turbo',
                      'Other'
                    ].map<DropdownMenuItem<String>>((String value) {
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
                      labelText: 'Jenis BBM',
                      labelStyle: TextStyle(color: Colors.white),
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
                            labelText: 'Exp Pajak Kendaraan',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(20.0),
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
                    items: <String>['', 'Honda', 'Yamaha', 'Piaggio', 'Suzuki', 'Kawasaki']
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
                      labelText: 'Pabrikan Asal Kendaraan',
                    ),
                  ),
                ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        _uploadDataToFirestore(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: Text(
                        'Simpan',
                        style:
                            TextStyle(fontSize: 16, color: Colors.orange[200]),
                      ),
                    ),
                  ])),
        ),
      ),
    );
  }

  void _selectImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _imageUrl = null;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2050),
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
      String phoneNumber = _phoneNumberController;
      String birthDate = _birthDateController.text.trim();
      String gender = _gender;
      if (fullName.isEmpty ||
          nickName.isEmpty ||
          phoneNumber.isEmpty ||
          birthDate.isEmpty ||
          gender.isEmpty) {
        Navigator.of(context).push(
          ErrorOverlay(
            message: "Isi data kendaraan terlebih dahulu",
          ),
        );
        return;
      }
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(
              value: null,
              strokeWidth: 6,
            ),
          );
        },
      );
      await FirebaseFirestore.instance.collection('kendaraan').doc(email).set({
        'Nama Kendaraan': fullName,
        'Nomor Polisi Kendaraan': nickName,
        'Exp Pajak Kendaraan': birthDate,
        'Jenis BBM': phoneNumber,
        'Pabrikan Asal': gender,
        'kendaraanImageURL':
            _image != null ? await _uploadImageToFirebaseStorage() : null,
      });
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
      Navigator.of(context).push(
        SuccessOverlay(
          message: "Data Kendaraan Berhasil Diupload\nRegister Akun Berhasil",
        ),
      );
    } catch (e) {
      print('Error uploading data to Firestore: $e');
      Navigator.of(context).pop();
      Navigator.of(context).push(
        ErrorOverlay(
          message: "Profile Kendaraan Gagal diupload",
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
          .child('kendaraan_images')
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
