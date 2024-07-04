import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunmolor_team/helper/dimension.dart';
import 'package:sunmolor_team/module/auth/forgot_password/forgot_password_page.dart';
import 'package:sunmolor_team/module/auth/signup/signup_page.dart';
import 'package:sunmolor_team/module/home/home_page.dart';
import 'package:sunmolor_team/overlay/no_data_account.dart';

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
  bool _isObscure = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('isLoggedIn') == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  Future<void> _saveLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
  }

  Future<void> _signInWithEmailAndPassword(BuildContext context) async {
  try {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    );
    _emailController.clear();
    _passwordController.clear();
    if (mounted) {
      setState(() {
        _errorMessage = '';
      });
    }
    await _saveLoginStatus();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
    print('User signed in: ${userCredential.user!.email}');
  } catch (e) {
    String errorMessage = e.toString();
    if (errorMessage.contains('[firebase_auth/channel-error]')) {
      errorMessage = 'Isi username dan password terlebih dahulu';
    } else if (errorMessage.contains('[firebase_auth/invalid-credential]')) {
      errorMessage =
          'Akun tidak ditemukan, pastikan kamu Telah Register Akun.\nAtau Cek Kembali Password dan Email kamu';
    } else if (errorMessage.contains('[firebase_auth/network-request-failed]')) {
      errorMessage = 'Jaringan bermasalah, cek koneksi internetmu';
    } else if (errorMessage.contains('[firebase_auth/unknown]')) {
      errorMessage =
          'Jaringan Mu Bermasalah, Silahkan Cek Koneksi Internet Kamu';
    }

    if (mounted) {
      setState(() {
        _errorMessage = errorMessage;
      });
    }
    print('Sign in error: $_errorMessage');

    Navigator.of(context).push(
      ErrorNoDataAccount(
        message: "$_errorMessage",
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
                  "Login\nSunmolor Team",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
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
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                      icon: Icon(
                        _isObscure ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
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
                    child: Text(
                      'Lupa Password?',
                      style: TextStyle(color: Colors.orange[200]),
                    ),
                  ),
                ),
                SizedBox(height: Dimensions.size15),
                ElevatedButton(
                  onPressed: () => _signInWithEmailAndPassword(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.orange[200],
                        fontWeight: FontWeight.bold),
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
                  child: Text(
                    'Belum memiliki akun? Daftar Sekarang',
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
