import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:sunmolor_team/helper/dimension.dart';
import 'package:sunmolor_team/module/account/account_form/account_form_page.dart';
import 'package:sunmolor_team/module/account/account_page.dart';
import 'package:sunmolor_team/module/chat/chat_page.dart';
import 'package:sunmolor_team/module/home/home_bloc.dart';
import 'package:sunmolor_team/module/home/home_state.dart';
import 'package:sunmolor_team/module/kendaraan/kendaraan_page.dart';
import 'package:sunmolor_team/module/upload/upload_page.dart';
import 'package:sunmolor_team/overlay/comming_soon.dart';

import '../../../helper/app_colors.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController tecSearch = TextEditingController();
  bool loading = true;
  String fullName = '';
  String nickName = '';
  String address = '';
  String phoneNumber = '';
  String birthDate = '';
  String gender = '';
  String nama_kendaraan = '';
  String Nomor_polisi_kendaraan = '';
  String jenis_bbm = '';
  String Exp_pajak = '';
  String pabrikan_asal = '';
  int points = 0;
  File? profileImage;
  File? kendaraanImage;
  List<String> _accountEmails = [];
  String? _imageUrl;
  String? _imagekendaraanUrl;
  String? _groupId;
  File? backgroundImage;

  String? _backgroundImageUrl;

  @override
  void initState() {
    super.initState();
    _loadKendaraanImage();
    _loadUserDataFromFirestore();
    _loadkendaraanDataFromFirestore();

    _loadProfileImage();
    _loadBackgroundImage();
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

  Future<void> _loadAccountEmails() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').get();
      setState(() {
        _accountEmails =
            snapshot.docs.map((doc) => doc.id).toList(); // Get email addresses
      });
    } catch (e) {
      print('Error loading account emails: $e');
    }
  }

  Future<void> _uploadPhoto(File imageFile) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String email = user.email!;

        CollectionReference userCollection =
            FirebaseFirestore.instance.collection('users');

        DocumentReference userDocRef = userCollection.doc(email);

        String photoURL = await _uploadImage(imageFile);
        await userDocRef.update({'backgroundImageURL': photoURL});

        _loadBackgroundImage();
      }
    } catch (e) {
      print('Error uploading photo: $e');
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String email = user.email!;
        Reference storageRef =
            FirebaseStorage.instance.ref().child('background_images/$email');
        UploadTask uploadTask = storageRef.putFile(imageFile);
        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadURL = await taskSnapshot.ref.getDownloadURL();
        return downloadURL;
      }
    } catch (e) {
      print('Error uploading image: $e');
      throw Exception('Failed to upload image');
    }
    return '';
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        backgroundImage = File(image.path);
      });
      await _uploadPhoto(backgroundImage!);
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

  void _loadKendaraanImage() async {
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
            _imagekendaraanUrl = userDoc['kendaraanImageURL'];
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
            fullName = userDoc['fullName'];
            nickName = userDoc['nickName'];
            address = userDoc['address'];
            phoneNumber = userDoc['phoneNumber'];
            birthDate = userDoc['birthDate'];
            gender = userDoc['gender'];
            points = userDoc['points'] ?? 0;
          });
        }
      }
    } catch (e) {
      print('Error loading user data from Firestore: $e');
      setState(() {
        loading = false;
      });
    }
  }

  void _loadkendaraanDataFromFirestore() async {
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
            nama_kendaraan = userDoc['Nama Kendaraan'];
            Nomor_polisi_kendaraan = userDoc['Nomor Polisi Kendaraan'];
            Exp_pajak = userDoc['Exp Pajak Kendaraan'];
            jenis_bbm = userDoc['Jenis BBM'];
            pabrikan_asal = userDoc['Pabrikan Asal'];
          });
        }
      }
    } catch (e) {
      print('Error loading user data from Firestore: $e');
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is HomeLoading) {
          setState(() {
            loading = true;
          });
        } else if (state is HomeFinished) {
          setState(() {
            loading = false;
          });
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: _backgroundImageUrl != null
                ? DecorationImage(
                    image: NetworkImage(_backgroundImageUrl!),
                    fit: BoxFit.cover)
                : null,
          ),
          child: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                _loadUserDataFromFirestore();
                _loadkendaraanDataFromFirestore();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                    height: MediaQuery.of(context).size.height, child: body()),
              ),
            ),
          ),
        ),
        floatingActionButton: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                  backgroundColor: Colors.black,
                  heroTag: 'account',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AccountPage()),
                    );
                  },
                  child: Icon(Icons.person, color: Colors.orange[200]),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 35),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: FloatingActionButton(
                  backgroundColor: Colors.black,
                  heroTag: 'Chat',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              GroupChatPage(groupId: _groupId.toString())),
                    );
                  },
                  child: Icon(Icons.chat, color: Colors.orange[200]),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 35),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: FloatingActionButton(
                  backgroundColor: Colors.black,
                  heroTag: 'upload',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UploadPage()),
                    );
                  },
                  child:
                      Icon(Icons.cloud_upload_sharp, color: Colors.orange[200]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget body() {
    if (loading) {
      return Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              "assets/lottie/motor.json",
              frameRate: const FrameRate(60),
              width: Dimensions.size100 * 2,
              repeat: true,
            ),
            const Text("Tunggu data sedang dimuat")
          ],
        ),
      );
    } else {
      return Center(
        child: Container(
          padding: EdgeInsets.all(Dimensions.size20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.wallpaper_rounded))
                ],
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AccountFormPage()),
                  );
                },
                child: Stack(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.orange[200],
                      radius: 70,
                      backgroundImage:
                          _imageUrl != null ? NetworkImage(_imageUrl!) : null,
                    ),
                    if (_imageUrl == null)
                      const Positioned.fill(
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
              ),
              SizedBox(height: Dimensions.size20),
              Text(
                fullName.isNotEmpty
                    ? fullName
                    : 'Lengkapi Datamu terlebih dahulu',
                style:
                    const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: Dimensions.size20),
              Container(
                padding: EdgeInsets.all(Dimensions.size10),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.black54),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.orange[200],
                          radius: 30,
                          backgroundImage: _imagekendaraanUrl != null
                              ? NetworkImage(_imagekendaraanUrl!)
                              : null,
                        ),
                        if (_imagekendaraanUrl == null)
                          const Positioned.fill(
                            child: CircularProgressIndicator(),
                          ),
                      ],
                    ),
                    SizedBox(width: Dimensions.size20),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => KendaraanPage()),
                        );
                      },
                      child: Expanded(
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nama_kendaraan.isNotEmpty
                                    ? nama_kendaraan
                                    : 'Perbarui Info kendaraan',
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    Nomor_polisi_kendaraan.isNotEmpty
                                        ? Nomor_polisi_kendaraan
                                        : 'Isi data kendaraan terlebih dahulu',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 50),
                                    child: Text(
                                      pabrikan_asal.isNotEmpty
                                          ? pabrikan_asal
                                          : '',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    Exp_pajak.isNotEmpty
                                        ? Exp_pajak
                                        : 'Isi data kendaraan terlebih dahulu',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 30),
                                    child: Text(
                                      jenis_bbm.isNotEmpty ? jenis_bbm : '',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: Dimensions.size20),
              Container(
                height: 200,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Terjadi kesalahan: ${snapshot.error}'),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text('Tidak ada data pengguna.'),
                      );
                    }
                    List<String> emails = _accountEmails ?? [];
                    if (_accountEmails == null) {
                      emails =
                          snapshot.data!.docs.map((doc) => doc.id).toList();
                    }
                    return ListView.builder(
                      itemCount: emails.length,
                      itemBuilder: (context, index) {
                        var email = emails[index];
                        return ListTile(
                          title: Text(email),
                          subtitle: Text(email),
                        );
                      },
                    );
                  },
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black38,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        CommingSoonOverlay(
                          message: "COMMING SOON",
                        ),
                      );
                    },
                    child: Text("Lihat Lokasi Teman saya",
                        style: TextStyle(color: Colors.orange[200]))),
              )
            ],
          ),
        ),
      );
    }
  }

  Widget listItemShimmer() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(Dimensions.size20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: Dimensions.size100,
                      height: Dimensions.size10,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.size5),
                        color: AppColors.background(),
                      ),
                    ),
                    SizedBox(
                      height: Dimensions.size10,
                    ),
                    Container(
                      width: Dimensions.size100 * 2,
                      height: Dimensions.size20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.size5),
                        color: AppColors.background(),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: Dimensions.size20,
              ),
              Container(
                width: Dimensions.size80,
                alignment: Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: Dimensions.size100,
                      height: Dimensions.size10,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.size5),
                        color: AppColors.background(),
                      ),
                    ),
                    SizedBox(
                      height: Dimensions.size10,
                    ),
                    Container(
                      width: Dimensions.size100 * 2,
                      height: Dimensions.size20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.size5),
                        color: AppColors.background(),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: Dimensions.size20,
              ),
              Container(
                width: Dimensions.size80,
                alignment: Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: Dimensions.size100,
                      height: Dimensions.size10,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.size5),
                        color: AppColors.background(),
                      ),
                    ),
                    SizedBox(
                      height: Dimensions.size10,
                    ),
                    Container(
                      width: Dimensions.size100 * 2,
                      height: Dimensions.size20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.size5),
                        color: AppColors.background(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: Dimensions.size20,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: Dimensions.size100,
                      height: Dimensions.size10,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.size5),
                        color: AppColors.background(),
                      ),
                    ),
                    SizedBox(
                      height: Dimensions.size10,
                    ),
                    Container(
                      width: Dimensions.size100 * 2,
                      height: Dimensions.size20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.size5),
                        color: AppColors.background(),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: Dimensions.size20,
              ),
              Container(
                width: Dimensions.size80,
                alignment: Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: Dimensions.size100,
                      height: Dimensions.size10,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.size5),
                        color: AppColors.background(),
                      ),
                    ),
                    SizedBox(
                      height: Dimensions.size10,
                    ),
                    Container(
                      width: Dimensions.size100 * 2,
                      height: Dimensions.size20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.size5),
                        color: AppColors.background(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
