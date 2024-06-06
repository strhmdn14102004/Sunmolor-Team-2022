import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sunmolor_team/helper/dimension.dart';
import 'package:sunmolor_team/module/auth/forgot_password/forgot_password_page.dart';
import 'package:sunmolor_team/module/auth/signup/signup_page.dart';
import 'package:sunmolor_team/module/home/home_page.dart';
import 'package:sunmolor_team/overlay/error_overlay.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  Future<void> _signInWithEmailAndPassword(BuildContext context) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      _emailController.clear();
      _passwordController.clear();
      setState(() {
        _errorMessage = '';
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
      print('User signed in: ${userCredential.user!.email}');
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      print('Sign in error: $_errorMessage');

      Navigator.of(context).push(
        ErrorOverlay(
          message: "Login Gagal, Periksa Kembali Password Kamu",
        ),
      );
    }
  }

  void _navigateToForgotPassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
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
          const Text(
            "Login\nSunmolor Team 2022",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
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
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(20.0), // Adjust the radius as needed
                    ),
                  ),
                ),
              ),
              SizedBox(height: Dimensions.size5),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () {
                    _navigateToForgotPassword(context);
                  },
                  child: const Text(
                    'Lupa Password?',
                    style: TextStyle(),
                  ),
                ),
              ),
              SizedBox(height: Dimensions.size15),
              ElevatedButton(
                onPressed: () => _signInWithEmailAndPassword(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 15), // Increase padding
                  minimumSize:
                      const Size(double.infinity, 50), // Set button size
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 10),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUp()),
                  );
                },
                child: const Text(
                  'Belum punya akun? Daftar Sekarang',
                  style: TextStyle(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
