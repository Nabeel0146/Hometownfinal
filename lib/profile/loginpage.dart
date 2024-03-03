import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:apptest/main.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;

  Future<void> _login(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _loading = true;
      });

      String email = _emailController.text;
      String password = _passwordController.text;

      try {
        // Check if the user exists in the users collection
        await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: email).get().then((querySnapshot) {
          if (querySnapshot.docs.isNotEmpty) {
            FirebaseAuth.instance.signInWithEmailAndPassword(
              email: email,
              password: password,
            ).then((userCredential) async {
              String selectedCity = await _getUserSelectedCity(userCredential.user!.uid);
              _navigateToHomePage(context, userCredential.user!.uid, selectedCity);
            }).catchError((e) {
              _showErrorDialog(context, 'Wrong password');
            });
          } else {
            _showErrorDialog(context, 'No user found');
          }
        });
      } catch (e) {
        print('Unexpected error: $e');
      } finally {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<String> _getUserSelectedCity(String userUid) async {
    DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userUid).get();

    return userSnapshot.exists ? userSnapshot['location'] ?? '' : '';
  }

  void _navigateToHomePage(BuildContext context, String userUid, String selectedCity) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MyHomePage(userUid: userUid, selectedCity: selectedCity),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sorry Boss'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network("https://raw.githubusercontent.com/Nabeel0146/Hometown-project-images/main/loginpageimage.png"),
                Center(child: Text("Login to your account", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16),)),
                SizedBox(height: 20,),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !RegExp(r"^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+$").hasMatch(value)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter a password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                Center(
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: _loading ? null : () => _login(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 160, vertical: 19),
                        ),
                        child: _loading
                            ? CircularProgressIndicator()
                            : Text('Login', style: TextStyle(color: Colors.white)),
                      ),
                      SizedBox(height: 10),
                      
                    ],
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
