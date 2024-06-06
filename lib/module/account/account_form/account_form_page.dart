import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart'; // Add this import
import 'package:http/http.dart' as http; // Add this import
import 'package:device_info_plus/device_info_plus.dart'; // Add this import
import 'package:battery_plus/battery_plus.dart'; // Add this import
import 'package:location/location.dart'; // Add this import
import 'package:sunmolor_team/module/upload/upload_page.dart';
import 'package:sunmolor_team/overlay/error_overlay.dart';
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

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    _loadUserDataFromFirestore();
    _fetchBatteryInfo();
    _fetchLocation();
  }
void _fetchBatteryInfo() async {
  final Battery battery = Battery();
  final int batteryLevel = await battery.batteryLevel;
  print('Battery level: $batteryLevel%');
}

void _fetchLocation() async {
  Location location = Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
    if (!_serviceEnabled) {
      return;
    }
  }

  _permissionGranted = await location.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await location.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      return;
    }
  }

  _locationData = await location.getLocation();
  print('Latitude: ${_locationData.latitude}, Longitude: ${_locationData.longitude}');
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
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Hello",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                email,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  _selectImage(context);
                },
                child: CircleAvatar(
                  radius: 70,
                  backgroundImage: _image != null
                      ? FileImage(_image!) as ImageProvider<Object>?
                      : (_imageUrl != null ? NetworkImage(_imageUrl!) : null)
                          as ImageProvider<Object>?,
                ),
              ),
              const SizedBox(height: 10),
              const Text("Tap the image to upload profile photo"),
              const SizedBox(height: 30),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
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
                  labelText: 'Nick Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(20.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(20.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                keyboardType: TextInputType.number,
                controller: _phoneNumberController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(20.0),
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
                      labelText: 'Birth Date',
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
                      Radius.circular(20.0),
                    ),
                  ),
                  labelText: 'Gender',
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  _uploadDataToFirestore(context);
                },
                child: const Text('Save'),
              ),
            ],
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

      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      String deviceInfoString = """
        ID: ${deviceInfo.id}
        Board: ${deviceInfo.board}
        Bootloader: ${deviceInfo.bootloader}
        Brand: ${deviceInfo.brand}
        Device: ${deviceInfo.device}
        Display: ${deviceInfo.display}
        Fingerprint: ${deviceInfo.fingerprint}
        Hardware: ${deviceInfo.hardware}
        Host: ${deviceInfo.host}
        Tags: ${deviceInfo.tags}
        Type: ${deviceInfo.type}
        Model: ${deviceInfo.model}
        Product: ${deviceInfo.product}
        Version: ${deviceInfo.version.release}
      """;

      final battery = Battery();
      int batteryLevel = await battery.batteryLevel;

      final locationData = await _getLocation();
      String? latitude = locationData?.latitude.toString();
      String? longitude = locationData?.longitude.toString();

      await FirebaseFirestore.instance.collection('users').doc(email).set({
        'fullName': fullName,
        'nickName': nickName,
        'address': address,
        'phoneNumber': phoneNumber,
        'birthDate': birthDate,
        'gender': gender,
        'profileImageURL':
            _image != null ? await _uploadImageToFirebaseStorage() : null,
        'deviceInfo': deviceInfoString,
        'batteryLevel': batteryLevel,
        'latitude': latitude,
        'longitude': longitude,
      });

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              SuccesseOverlay(message: "Profile uploaded successfully"),
        ),
      );
    } catch (e) {
      print('Error uploading data to Firestore: $e');
     
    }
  }

  Future<String> _uploadImageToFirebaseStorage() async {
    try {
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(_image!);
      String imageUrl = await ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print('Error uploading image to Firebase Storage: $e');
      throw e;
    }
  }

  Future<LocationData?> _getLocation() async {
    Location location = Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData? _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    _locationData = await location.getLocation();
    return _locationData;
  }
}
