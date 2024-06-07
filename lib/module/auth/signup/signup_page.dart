import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sunmolor_team/helper/dimension.dart';
import 'package:sunmolor_team/module/auth/login/login_page.dart';
import 'package:sunmolor_team/module/auth/signup/verify_data_diri_page.dart';
import 'package:sunmolor_team/overlay/error_overlay.dart';
import 'package:sunmolor_team/overlay/success_overlay.dart';

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
  bool _isObscure = true; // State to determine if password is obscured or not

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
        MaterialPageRoute(
            builder: (context) => VerifyDataPage()), // Navigate back to login
      );
      Navigator.of(context).push(
        SuccessOverlay(
          message:
              "Register akun dengan email\n${userCredential.user!.email}\nBerhasil lanjutkan isi\nData diri anda",
        ),
      );
      print('User signed up: ${userCredential.user!.email}');
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        Navigator.of(context).push(
          ErrorOverlay(
            message: "$_errorMessage",
          ),
        );
      });
      print('Sign up error: $_errorMessage');
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
                    'assets/images/Sunmolor.png', // Add your sunmolor_teamee logo image asset
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: Dimensions.size10),
                Text(
                  "Daftar Akun\nSunmolor Team",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20.0), // Adjust the radius as needed
                      ),
                    ),
                  ),
                ),
                SizedBox(height: Dimensions.size15),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _isObscure, // Use the obscureText property
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20.0), // Adjust the radius as needed
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
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _signUpWithEmailAndPassword(context),
                  child: Text('Daftar'),
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              LoginScreen()), 
                    );
                  },
                  child: Text(
                    'Sudah punya akun? Login',
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
