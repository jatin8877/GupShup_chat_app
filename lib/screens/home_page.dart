import 'package:chat_gupshup/screens/edit_screen.dart';
import 'package:chat_gupshup/screens/search_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/chat_room_model.dart';
import '../models/firebase_helper.dart';
import '../models/user_model.dart';
import 'chat_room.dart';

class HomePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const HomePage(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/images/img.jpg'),
            fit: BoxFit.cover,
            opacity: 1),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          toolbarHeight: 120,
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(
            "Messages",
            style: GoogleFonts.ubuntu(
                color: const Color(0xFF014A44),
                fontSize: 35,
                fontWeight: FontWeight.bold),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 14.0),
              child: GestureDetector(
                child: CircleAvatar(
                  radius: 33,
                  backgroundColor: const Color(0xFF009688),
                  child: CircleAvatar(
                    radius: 31,
                    backgroundImage:
                        NetworkImage(widget.userModel.profilepic.toString()),
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return EditScreen(
                          userModel: widget.userModel,
                          firebaseUser: widget.firebaseUser);
                    }),
                  );
                },
              ),
            )
          ],
        ),
        body: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black54,
              ),
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              image: const DecorationImage(
                  image: AssetImage('assets/images/background-image.jpg'),
                  fit: BoxFit.cover,
                  opacity: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 24),
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("chatrooms")
                    .where("participants.${widget.userModel.uid}",
                        isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      QuerySnapshot chatRoomSnapshot =
                          snapshot.data as QuerySnapshot;
                      return ListView.builder(
                        itemCount: chatRoomSnapshot.docs.length,
                        itemBuilder: (context, index) {
                          ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                              chatRoomSnapshot.docs[index].data()
                                  as Map<String, dynamic>);

                          Map<String, dynamic> participants =
                              chatRoomModel.participants!;

                          List<String> participantKeys =
                              participants.keys.toList();
                          participantKeys.remove(widget.userModel.uid);

                          return FutureBuilder(
                            future: FirebaseHelper.getUserModelById(
                                participantKeys[0]),
                            builder: (context, userData) {
                              if (userData.connectionState ==
                                  ConnectionState.done) {
                                if (userData.data != null) {
                                  UserModel targetUser =
                                      userData.data as UserModel;

                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                        color: Colors.black38,
                                      ),
                                      borderRadius: BorderRadius.circular(25.0),
                                    ),
                                    child: ListTile(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                              return ChatRoomPage(
                                                chatroom: chatRoomModel,
                                                firebaseUser:
                                                    widget.firebaseUser,
                                                userModel: widget.userModel,
                                                targetUser: targetUser,
                                              );
                                            }),
                                          );
                                        },
                                        leading: CircleAvatar(
                                          radius: 43,
                                          backgroundImage: NetworkImage(
                                              targetUser.profilepic.toString()),
                                        ),
                                        title: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Text(
                                            targetUser.fullname.toString(),
                                            style: GoogleFonts.ubuntu(
                                              color: Colors.black87,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                        subtitle: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                                maxHeight: 20),
                                            child: Text(
                                              chatRoomModel.lastMessage
                                                  .toString(),
                                              style: GoogleFonts.ubuntu(
                                                  color: const Color.fromARGB(
                                                      193, 0, 0, 0),
                                                  fontSize: 15),
                                            ),
                                          ),
                                        )),
                                  );
                                } else {
                                  return Container();
                                }
                              } else {
                                return Container();
                              }
                            },
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(snapshot.error.toString()),
                      );
                    } else {
                      return const Center(
                        child: Text("No Chats"),
                      );
                    }
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF009688),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return SearchPage(
                  userModel: widget.userModel,
                  firebaseUser: widget.firebaseUser);
            }));
          },
          child: const Icon(Icons.search),
        ),
      ),
    );
  }
}
