import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sunmolor_team/helper/dimension.dart';
import 'package:sunmolor_team/module/auth/login/login_page.dart';
import 'package:sunmolor_team/overlay/error_overlay.dart';
import 'package:sunmolor_team/overlay/success_overlay.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _errorMessage = '';

  Future<void> _sendPasswordResetEmail(BuildContext context) async {
    final email = _emailController.text;
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _emailController.clear();
      setState(() {
        _errorMessage = '';
      });
      Navigator.of(context).push(
        SuccessOverlay(
          message: "Link Reset Password Berhasil Dikirimkan Ke Email Kamu.",
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
      Navigator.of(context).push(
        SuccessOverlay(
          message: "Link Reset Password Berhasil Dikirimkan Ke Email Kamu.",
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      print('Password reset error: $_errorMessage');
      Navigator.of(context).push(
        ErrorOverlay(
          message: "$_errorMessage",
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
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
            "Reset Password",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextFormField(
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
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
            ),
            onPressed: () => _sendPasswordResetEmail(context),
            child: Text(
              'Reset Password',
              style: TextStyle(
                  color: Colors.orange[200], fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
