import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:sunmolor_team/helper/dimension.dart';
import 'package:sunmolor_team/module/account/account_page.dart';
import 'package:sunmolor_team/module/home/home_bloc.dart';
import 'package:sunmolor_team/module/home/home_state.dart';
import 'package:sunmolor_team/module/upload/upload_page.dart';

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
  String joined = '';
  String? _imageUrl;
  String? _imagekendaraanUrl;

  @override
  void initState() {
    super.initState();
    _loadKendaraanImage();
    _loadUserDataFromFirestore();
    _loadkendaraanDataFromFirestore();
    _loadUserPoints();
    _loadProfileImage();
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
            joined = userDoc['joined'];
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

  void _loadUserPoints() async {
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
            points = userDoc['points'] ?? 0;
          });
        }
      }
    } catch (e) {
      print('Error loading user points from Firestore: $e');
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
        appBar: AppBar(
          centerTitle: true,
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  "Sunmolor Team",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.monetization_on,
                    color: Colors.yellow,
                  ),
                  SizedBox(width: 5),
                  Text(
                    points.toString(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              _loadUserDataFromFirestore();
              _loadkendaraanDataFromFirestore();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: body(),
            ),
          ),
        ),
        floatingActionButton: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(right:35),
              child: Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                  heroTag: 'account',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AccountPage()),
                    );
                  },
                  child: const Icon(Icons.person),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left:35),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: FloatingActionButton(
                  heroTag: 'upload',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UploadPage()),
                    );
                  },
                  child: const Icon(Icons.upload),
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
              "assets/lottie/loading_clock.json",
              frameRate: const FrameRate(60),
              width: Dimensions.size100 * 2,
              repeat: true,
            ),
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
              Stack(
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundImage:
                        _imageUrl != null ? NetworkImage(_imageUrl!) : null,
                  ),
                  if (_imageUrl == null)
                    Positioned.fill(
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
              SizedBox(height: Dimensions.size20),
              Text(
                fullName.isNotEmpty
                    ? fullName
                    : 'Lengkapi Datamu terlebih dahulu',
                style:
                    const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: Dimensions.size20),
              Container(
                padding: EdgeInsets.all(Dimensions.size10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: _imagekendaraanUrl != null
                              ? NetworkImage(_imagekendaraanUrl!)
                              : null,
                        ),
                        if (_imagekendaraanUrl == null)
                          Positioned.fill(
                            child: CircularProgressIndicator(),
                          ),
                      ],
                    ),
                    SizedBox(width: Dimensions.size20),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nama_kendaraan.isNotEmpty
                                ? nama_kendaraan
                                : 'Perbarui Info kendaraan',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(Nomor_polisi_kendaraan.isNotEmpty
                              ? Nomor_polisi_kendaraan
                              : 'Isi data kendaraan terlebih dahulu'),
                          Text(Exp_pajak.isNotEmpty
                              ? Exp_pajak
                              : 'Isi data kendaraan terlebih dahulu')
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
