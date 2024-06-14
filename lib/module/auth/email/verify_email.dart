import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sunmolor_team/helper/dimension.dart';
import 'package:sunmolor_team/overlay/error_overlay.dart';
import 'package:sunmolor_team/overlay/success_overlay.dart';

class ChangeEmailPage extends StatefulWidget {
  @override
  _ChangeEmailPageState createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage> {
  final TextEditingController _newEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscure = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Verifikasi Email'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 100, right: 16.0, left: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/Sunmolor.png',
                          width: 250,
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: Dimensions.size15),
                    TextFormField(
                      controller: _newEmailController,
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
                          onPressed: () {
                            setState(() {
                              _isObscure = !_isObscure;
                            });
                          },
                          icon: Icon(
                            _isObscure
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () => _changeEmail(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: Text(
                          'Verifikasi',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.orange[200],
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _changeEmail() async {
    try {
      String newEmail = _newEmailController.text.trim();
      String password = _passwordController.text.trim();
      if (newEmail.isNotEmpty && password.isNotEmpty) {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          AuthCredential credential = EmailAuthProvider.credential(
            email: user.email!,
            password: password,
          );
          await user.reauthenticateWithCredential(credential);
          await user.verifyBeforeUpdateEmail(newEmail);
          await user.sendEmailVerification();
          Navigator.of(context).push(
            SuccessOverlay(
              message: "Link verifikasi berhasil dikirim ke email\n$newEmail",
            ),
          );
        }
      } else {
        Navigator.of(context).push(
          ErrorOverlay(
            message: "Tolong lengkapi email dan passwordnya terlebih dahulu",
          ),
        );
      }
    } catch (e) {
      print('Error changing email: $e');
      String errorMessage = '';
      if (e is FirebaseAuthException) {
        if (e.code == 'too-many-requests') {
          errorMessage =
              'Terlalu banyak permintaan verifikasi email, coba lagi beberapa saat kemudian.';
        } else {
          errorMessage =
              e.message ?? 'Failed to change email. Please try again.';
        }
      }
      Navigator.of(context).push(
        ErrorOverlay(
          message: errorMessage,
        ),
      );
    }
  }
}
