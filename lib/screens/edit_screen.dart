import 'dart:developer';
import 'dart:io';
import 'package:chat_gupshup/models/ui_helper.dart';
import 'package:chat_gupshup/screens/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';
import 'login_screen.dart';

class EditScreen extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const EditScreen(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  File? imageFile;

  void selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      cropImage(pickedFile);
    }
  }

  void cropImage(XFile file) async {
    File? croppedImage = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 5,
    );

    if (croppedImage != null) {
      setState(
        () {
          imageFile = croppedImage as File;
        },
      );
    }
  }

  void showPhotoOptions() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Upload Profile Picture"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    selectImage(ImageSource.gallery);
                  },
                  leading: const Icon(Icons.photo_album),
                  title: const Text("Select from Gallery"),
                ),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    selectImage(ImageSource.camera);
                  },
                  leading: const Icon(Icons.camera_alt),
                  title: const Text("Take a photo"),
                ),
              ],
            ),
          );
        });
  }

  void uploadData() async {
    UIHelper.showLoadingDialog(context, "Uploading image..");

    UploadTask uploadTask = FirebaseStorage.instance
        .ref("profilepictures")
        .child(widget.userModel.uid.toString())
        .putFile(imageFile!);

    TaskSnapshot snapshot = await uploadTask;

    String? imageUrl = await snapshot.ref.getDownloadURL();

    widget.userModel.profilepic = imageUrl;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userModel.uid)
        .set(widget.userModel.toMap())
        .then((value) {
      log("Data uploaded!");
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return HomePage(
              userModel: widget.userModel, firebaseUser: widget.firebaseUser);
        }),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          const BoxDecoration(color: Color.fromARGB(255, 236, 236, 236)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.keyboard_double_arrow_left),
          ),
          backgroundColor: const Color.fromARGB(255, 0, 150, 135),
          title: Text(
            "Edit",
            style: GoogleFonts.ubuntu(color: Colors.white),
          ),
        ),
        body: ListView(
          children: [
            Material(
              elevation: 3,
              child: Container(
                height: 350,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image:
                          NetworkImage(widget.userModel.profilepic.toString()),
                      fit: BoxFit.cover),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.userModel.fullname.toString(),
                    style:
                        GoogleFonts.ubuntu(fontSize: 26, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.userModel.email.toString(),
                    style:
                        GoogleFonts.ubuntu(fontSize: 20, color: Colors.black54),
                  ),
                  const SizedBox(height: 25),
                  GestureDetector(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Icon(
                          Icons.camera_alt,
                          color: Color(0xFF014A44),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Upload Image',
                          style: GoogleFonts.ubuntu(
                              fontSize: 20, color: const Color(0xFF014A44)),
                        ),
                      ],
                    ),
                    onTap: () {
                      showPhotoOptions();
                    },
                  ),
                  const SizedBox(height: 10.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: const Color(0xFF009688),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () => uploadData(),
                    child: const Text(
                      'Save',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            FirebaseAuth.instance.signOut();
            Navigator.popUntil(context, (route) => route.isFirst);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) {
                return const LoginPage();
              }),
            );
          },
          label: const Padding(
            padding: EdgeInsets.only(left: 18, right: 18),
            child: Text(
              'Log Out',
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
