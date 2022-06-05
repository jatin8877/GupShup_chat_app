import 'package:chat_gupshup/screens/chat_room.dart';
import 'package:chat_gupshup/screens/sign_up_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/ui_helper.dart';
import '../models/user_model.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void checkValues() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email == "" || password == "") {
      UIHelper.showAlertDialog(
          context, "Incomplete Data", "Please fill all the fields");
    } else {
      logIn(email, password);
    }
  }

  void logIn(String email, String password) async {
    UserCredential? credential;

    UIHelper.showLoadingDialog(context, "Logging In..");

    try {
      credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      // Close the loading dialog
      Navigator.pop(context);

      // Show Alert Dialog
      UIHelper.showAlertDialog(
          context, "An error occured", ex.message.toString());
    }

    if (credential != null) {
      String uid = credential.user!.uid;

      DocumentSnapshot userData =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      UserModel userModel =
          UserModel.fromMap(userData.data() as Map<String, dynamic>);

      // Go to HomePage
      print("Log In Successful!");
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return HomePage(
              userModel: userModel, firebaseUser: credential!.user!);
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/images/background-image.jpg'),
            fit: BoxFit.cover,
            opacity: 1),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'GupShup',
            style: GoogleFonts.arefRuqaa(
                fontSize: 40,
                color: const Color(0xFF009688),
                fontWeight: FontWeight.bold),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              margin: const EdgeInsets.only(top: 20),
              height: 450,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Let's sign you in.",
                      style: GoogleFonts.ubuntu(
                          fontSize: 31,
                          letterSpacing: 1,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF014A44)),
                    ),
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Welocme back\nYou've been missed!",
                      style: GoogleFonts.ubuntu(
                          fontSize: 24,
                          letterSpacing: 1,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF014A44)),
                    ),
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xFF014A44), width: 2.0),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                            ),
                            filled: true,
                            fillColor: Color.fromARGB(208, 255, 255, 255),
                            prefixIcon: Icon(
                              Icons.email,
                              color: Color(0xFF014A44),
                            ),
                            labelText: 'Email',
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30))),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Email Field cant be Empty';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12.0),
                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0xFF014A44), width: 2.0),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                              ),
                              filled: true,
                              fillColor: Color.fromARGB(208, 255, 255, 255),
                              prefixIcon: Icon(
                                Icons.lock,
                                color: Color(0xFF014A44),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30))),
                              labelText: 'Password'),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Password Filed cant be Empty';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: const Color(0xFF009688),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      checkValues();
                    },
                    child: const Padding(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: Text(
                        'Sign In',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(
                      "Don't have an account ?",
                      style: GoogleFonts.ubuntu(
                          color: Colors.black87, fontSize: 18),
                    ),
                    const SizedBox(width: 8.0),
                    GestureDetector(
                      child: Text(
                        'Register',
                        style: GoogleFonts.ubuntu(
                            color: const Color(0xFF009688), fontSize: 18),
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignUpPage(),
                        ),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
