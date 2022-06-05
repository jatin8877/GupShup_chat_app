import 'package:chat_gupshup/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);
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
              height: 600,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.all(17),
                    child: Text(
                      'A new way to connect with your favourite people.',
                      style: GoogleFonts.ubuntu(
                          fontSize: 31,
                          letterSpacing: 1,
                          height: 1.3,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF014A44)),
                    ),
                  ),
                  Center(
                    child: Image.asset(
                      'assets/images/png.png',
                      width: 300,
                    ),
                  ),
                  Center(
                    child: Expanded(
                      child: Text(
                        'Connect - Chat - Share - Enjoy',
                        style: GoogleFonts.ubuntu(fontSize: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const LoginPage()));
          },
          label: const Padding(
            padding: EdgeInsets.only(left: 18, right: 18),
            child: Text(
              'Welcome',
              style: TextStyle(fontSize: 20),
            ),
          ),
          backgroundColor: const Color(0xFF009688),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
