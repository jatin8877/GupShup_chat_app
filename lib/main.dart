import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:chat_gupshup/firebase_options.dart';
import 'package:chat_gupshup/models/user_model.dart';
import 'package:chat_gupshup/screens/home_page.dart';
import 'package:chat_gupshup/screens/welcome_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'models/firebase_helper.dart';

var uuid = const Uuid();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    // Logged In
    UserModel? thisUserModel =
        await FirebaseHelper.getUserModelById(currentUser.uid);
    if (thisUserModel != null) {
      runApp(
          MyAppLoggedIn(userModel: thisUserModel, firebaseUser: currentUser));
    } else {
      runApp(const MyApp());
    }
  } else {
    // Not logged in
    runApp(const MyApp());
  }
}

// Not Logged In
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AnimatedSplashScreen(
        duration: 2000,
        splash: const Image(
          image: AssetImage('assets/images/splash_logo.png'),
          width: 600,
        ),
        splashTransition: SplashTransition.fadeTransition,
        nextScreen: const WelcomePage(),
      ),
    );
  }
}

// Already Logged In
class MyAppLoggedIn extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;

  const MyAppLoggedIn(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AnimatedSplashScreen(
        duration: 2000,
        splash: const Image(
          image: AssetImage('assets/images/splash_logo.png'),
          width: 600,
        ),
        splashTransition: SplashTransition.fadeTransition,
        nextScreen: HomePage(userModel: userModel, firebaseUser: firebaseUser),
      ),
    );
  }
}
