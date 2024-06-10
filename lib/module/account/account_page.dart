import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunmolor_team/module/account/account_form/account_form_page.dart';
import 'package:sunmolor_team/module/auth/forgot_password/forgot_password_page.dart';
import 'package:sunmolor_team/module/auth/login/login_page.dart';
import 'package:sunmolor_team/module/kendaraan/kendaraan_page.dart';

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String? _imageUrl;
  String fullName = '';
  String nickName = '';
  String address = '';
  String phoneNumber = '';
  String birthDate = '';
  String gender = '';
  bool loading = true;
  String? _selectedAccount;
  String? _selectedStatus = 'Admin';
  bool isFounder = false;
  List<String> _accountEmails = [];
  String? _backgroundImageUrl;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    _loadAccountEmails();
    _checkFounderStatus();
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

  Widget _buildMakeAdminButton() {
    if (isFounder) {
      return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), color: Colors.blue[100]),
        width: 200,
        child: ElevatedButton(
          onPressed: () {
            _showMakeAdminDialog(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[100],
            padding:
                const EdgeInsets.symmetric(vertical: 15), // Increase padding
            minimumSize: const Size(double.infinity, 50), // Set button size
          ),
          child: const Text(
            'Ubah Status Member',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
      );
    } else {
      return const SizedBox(); // Jika bukan founder, kembalikan widget kosong
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

  Future<void> _checkFounderStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.email)
            .get();

        if (userDoc.exists) {
          setState(() {
            isFounder = userDoc['status'] == 'founder';
          });
        }
      } catch (e) {
        print('Error checking founder status: $e');
      }
    }
  }

  void _showMakeAdminDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return AlertDialog(
              title: const Text("Pilih Akun dan Status"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: _selectedAccount,
                    hint: const Text('Pilih Akun'),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedAccount = newValue;
                      });
                    },
                    items: _accountEmails
                        .map<DropdownMenuItem<String>>((String email) {
                      return DropdownMenuItem<String>(
                        value: email,
                        child: Text(email),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  DropdownButton<String>(
                    value: _selectedStatus,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedStatus = newValue;
                      });
                    },
                    items: <String>['Admin', 'Member']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Batal"),
                ),
                TextButton(
                  onPressed: () {
                    if (_selectedAccount != null && _selectedStatus != null) {
                      _toggleAdminStatus(
                          _selectedAccount!, _selectedStatus == 'Admin');
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text("Simpan"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _toggleAdminStatus(String email, bool isAdmin) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(email).update({
        'status': isAdmin ? 'admin' : 'member', // Update user status
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('$email has been set as ${isAdmin ? 'admin' : 'member'}')),
      );
    } catch (e) {
      print('Error toggling admin status: $e');
    }
  }

  void _loadUserDataFromFirestore() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String email = user.email!; // Get the current user's email

        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(email) // Fetch the document based on email
            .get();

        if (userDoc.exists) {
          setState(() {
            // Update the state with data from Firestore
            fullName = userDoc['fullName'];
            nickName = userDoc['nickName'];
            address = userDoc['address'];
            phoneNumber = userDoc['phoneNumber'];
            birthDate = userDoc['birthDate'];
            gender = userDoc['gender'];

            loading = false;
          });
        } else {
          setState(() {
            loading = false; // Data not found, stop showing shimmer
          });
        }
      }
    } catch (e) {
      print('Error loading user data from Firestore: $e');
      setState(() {
        loading = false; // Error occurred, stop showing shimmer
      });
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
            _imageUrl = userDoc[
                'profileImageURL']; // Ambil URL gambar profil dari Firestore
          });
        }
      }
    } catch (e) {
      print('Error loading profile image: $e');
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 100),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue[100],
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
                const SizedBox(height: 20),
                Text(
                  fullName.isNotEmpty ? fullName : email,
                  style: const TextStyle(
                      fontSize: 25, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AccountFormPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[100],
                      padding: const EdgeInsets.symmetric(
                          vertical: 15), // Increase padding
                      minimumSize:
                          const Size(double.infinity, 50), // Set button size
                    ),
                    child: const Text('Profilku',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => KendaraanPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[100],
                      padding: const EdgeInsets.symmetric(
                          vertical: 15), // Increase padding
                      minimumSize:
                          const Size(double.infinity, 50), // Set button size
                    ),
                    child: const Text(
                      'Kendaraan saya',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                _buildMakeAdminButton(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[100],
        onPressed: () {
          _showLogoutConfirmationDialog(context);
        },
        child: const Icon(
          Icons.logout_outlined,
          color: Colors.black,
        ),
      ),
    );
  }

  void _resetPassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: const Text(
            "Konfirmasi Logout",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          content: const Text(
            "Apakah Anda yakin ingin logout?",
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Batal",
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout(context);
              },
              child: const Text("Logout",
                  style: TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Bersihkan semua data dari SharedPreferences
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }
}
