import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunmolor_team/module/account/account_form/account_form_page.dart';
import 'package:sunmolor_team/module/auth/email/verify_email.dart';
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
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
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
            borderRadius: BorderRadius.circular(20), color: Colors.black),
        width: 200,
        child: ElevatedButton(
          onPressed: () {
            _showMakeAdminDialog(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 15),
            minimumSize: const Size(double.infinity, 50),
          ),
          child: Text(
            'Change Member Status',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.orange[200]),
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  void _showPasswordInputDialog(BuildContext context) {
    final TextEditingController _passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black54,
          title: const Text(
            "Masukkan Password\nUntuk Menghapus Akun Anda",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'Masukan Password Disini',
              hintStyle: TextStyle(color: Colors.white70),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Icon(Icons.cancel, color: Colors.red),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAccount(context, _passwordController.text);
              },
              child: const Icon(Icons.delete_forever, color: Colors.green),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount(BuildContext context, String password) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && mounted) {
      // Check if widget is mounted
      String email = user.email!;
      try {
        AuthCredential credential = EmailAuthProvider.credential(
          email: email,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(email)
            .delete();
        await FirebaseFirestore.instance
            .collection('kendaraan')
            .doc(email)
            .delete();
        await user.delete();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        if (mounted) {
          _scaffoldMessengerKey.currentState?.showSnackBar(
            const SnackBar(content: Text('Account deleted successfully')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        }
      } catch (e) {
        print('Error deleting account: $e');
        String errorMessage = 'Error deleting account';
        if (e is FirebaseAuthException) {
          if (e.code == 'invalid-credential') {
            errorMessage =
                'Invalid credentials. Please check your password and try again.';
          } else if (e.code == 'wrong-password') {
            errorMessage = 'Incorrect password. Please try again.';
          }
        }
        if (mounted) {
          _scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      }
    }
  }

  Future<void> _loadAccountEmails() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').get();
      setState(() {
        _accountEmails = snapshot.docs.map((doc) => doc.id).toList();
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
              backgroundColor: Colors.black54,
              title: const Text(
                "Pilih\nAkun dan Status",
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              alignment: Alignment.center,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: _selectedAccount,
                    hint: const Text(
                      'Pilih Akun',
                      style: TextStyle(color: Colors.white),
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedAccount = newValue;
                      });
                    },
                    items: _accountEmails
                        .map<DropdownMenuItem<String>>((String email) {
                      return DropdownMenuItem<String>(
                        value: email,
                        child: Text(
                          email,
                          style: TextStyle(color: Colors.grey),
                        ),
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
                        child: Text(
                          value,
                          style: TextStyle(color: Colors.grey),
                        ),
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
                  child: const Icon(Icons.cancel, color: Colors.red),
                ),
                TextButton(
                  onPressed: () {
                    if (_selectedAccount != null && _selectedStatus != null) {
                      _toggleAdminStatus(
                          _selectedAccount!, _selectedStatus == 'Admin');
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Icon(Icons.save, color: Colors.green),
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
        'status': isAdmin ? 'admin' : 'member',
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
            loading = false;
          });
        } else {
          setState(() {
            loading = false;
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

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String email = user != null ? user.email ?? "" : "";

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: Scaffold(
        floatingActionButton: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 35),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: FloatingActionButton(
                  backgroundColor: Colors.black,
                  heroTag: 'delete',
                  onPressed: () {
                    _showPasswordInputDialog(context);
                  },
                  child: Icon(
                    Icons.no_accounts_rounded,
                    color: Colors.orange[200],
                    size: 30,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                  backgroundColor: Colors.black,
                  heroTag: 'Logout',
                  onPressed: () {
                    _showLogoutConfirmationDialog(context);
                  },
                  child: Icon(
                    Icons.logout,
                    color: Colors.orange[200],
                    size: 30,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: Container(
            decoration: BoxDecoration(
              image: _backgroundImageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(_backgroundImageUrl!),
                      fit: BoxFit.cover)
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
                          backgroundColor: Colors.orange[200],
                          radius: 70,
                          backgroundImage: _imageUrl != null
                              ? NetworkImage(_imageUrl!)
                              : null,
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
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: Text('My Profile',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.orange[200],
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
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: Text(
                          'My Vehicle',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[200]),
                        ),
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
                                builder: (context) => ChangeEmailPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: Text(
                          'Verifikasi Email',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[200]),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    _buildMakeAdminButton(),
                    const SizedBox(height: 20),
                  
                  ],
                ),
              ),
            ),
          ),
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
          backgroundColor: Colors.black54,
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
                child: Icon(Icons.cancel, color: Colors.red)),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _logout(context);
                },
                child: Icon(
                  Icons.door_front_door,
                  color: Colors.green,
                ))
          ],
        );
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }
}
