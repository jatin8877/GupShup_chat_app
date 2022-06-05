import 'package:chat_gupshup/screens/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/ui_helper.dart';
import '../models/user_model.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController unameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cPasswordController = TextEditingController();

  void checkValues() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String cPassword = cPasswordController.text.trim();
    String uname = unameController.text.trim();

    if (email == "" || password == "" || cPassword == "" || uname == "") {
      UIHelper.showAlertDialog(
          context, "Incomplete Data", "Please fill all the fields");
    } else if (password != cPassword) {
      UIHelper.showAlertDialog(context, "Password Mismatch",
          "The passwords you entered do not match!");
    } else {
      signUp(email, password, uname);
    }
  }

  void signUp(String email, String password, String uname) async {
    UserCredential? credential;

    UIHelper.showLoadingDialog(context, "Creating new account..");

    try {
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      Navigator.pop(context);

      UIHelper.showAlertDialog(
          context, "An error occured", ex.message.toString());
    }

    if (credential != null) {
      String uid = credential.user!.uid;
      UserModel newUser = UserModel(
        uid: uid,
        email: email,
        fullname: uname,
        profilepic: "",
      );
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set(newUser.toMap())
          .then((value) {
        print("New User Created!");
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) {
            return LoginPage();
          }),
        );
      });
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
                // mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Create New Account.',
                      style: GoogleFonts.ubuntu(
                          fontSize: 31,
                          letterSpacing: 1,
                          height: 1.3,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF014A44)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Text(
                          'Already A Member ?',
                          style: GoogleFonts.ubuntu(
                              color: Colors.black87, fontSize: 18),
                        ),
                        const SizedBox(width: 8.0),
                        GestureDetector(
                            child: Text(
                              'Log In.',
                              style: GoogleFonts.ubuntu(
                                  color: const Color(0xFF009688), fontSize: 18),
                            ),
                            onTap: () => Navigator.pop(context)),
                      ],
                    ),
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: unameController,
                          keyboardType: TextInputType.name,
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
                              Icons.person,
                              color: Color(0xFF014A44),
                            ),
                            labelText: 'Name',
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30))),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Name Field cant be Empty';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12.0),
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
                            } else if (!value.contains('@')) {
                              return 'Invalid Emial';
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
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: cPasswordController,
                          obscureText: true,
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
                              Icons.lock_outline,
                              color: Color(0xFF014A44),
                            ),
                            labelText: 'Confirm Password',
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30))),
                          ),
                          validator: (value) {
                            if (value!.isEmpty && value.length < 2) {
                              return 'Name Field cant be Empty';
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
                            borderRadius: BorderRadius.circular(30))),
                    onPressed: () {
                      checkValues();
                    },
                    child: const Padding(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: Text(
                        'Register',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
