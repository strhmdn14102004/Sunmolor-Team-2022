import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sunmolor_team/helper/dimension.dart';
import 'package:sunmolor_team/module/auth/login/login_page.dart';
import 'package:sunmolor_team/module/auth/signup/verify_data_diri_page.dart';
import 'package:sunmolor_team/overlay/error_overlay.dart';
import 'package:sunmolor_team/overlay/register.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _isObscure = true;

  Future<void> _signUpWithEmailAndPassword(BuildContext context) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      _emailController.clear();
      _passwordController.clear();
      setState(() {
        _errorMessage = '';
      });
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => VerifyDataPage()),
      );
      Navigator.of(context).push(
        RegisterOverlay(
          message:
              "Register akun dengan email\n${userCredential.user!.email}\nBerhasil lanjutkan isi\nData diri anda",
        ),
      );
      print('User signed up: ${userCredential.user!.email}');
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('[firebase_auth/email-already-in-use]')) {
        errorMessage =
            'The email address is already in use by another account.';
      } else if (errorMessage.contains('[firebase_auth/channel-error]')) {
        errorMessage = 'Isi Email Dan Passwordnya Terlebih Dahulu';
      } else if (errorMessage.contains('[firebase_auth/weak-password]')) {
        errorMessage = 'Password minimal harus memiliki 6 Karakter';
      }
      setState(() {
        _errorMessage = errorMessage;
        Navigator.of(context).push(
          ErrorOverlay(
            message: _errorMessage,
          ),
        );
      });
      print(_errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/images/Sunmolor.png',
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: Dimensions.size10),
                const Text(
                  "Daftar Akun\nSunmolor Team",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                     ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: Dimensions.size15),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _isObscure,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20.0),
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscure ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  onPressed: () => _signUpWithEmailAndPassword(context),
                  child: Text(
                    'Daftar',
                    style: TextStyle(
                        color: Colors.orange[200], fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                    );
                  },
                  child: Text(
                    'Sudah punya akun? Login',
                    style: TextStyle(color: Colors.orange[200]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
