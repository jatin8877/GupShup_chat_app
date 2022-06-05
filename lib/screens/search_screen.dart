import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../models/chat_room_model.dart';
import '../models/user_model.dart';
import 'chat_room.dart';

class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const SearchPage(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();

  Future<ChatRoomModel?> getChatroomModel(UserModel targetUser) async {
    ChatRoomModel? chatRoom;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("participants.${widget.userModel.uid}", isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .get();

    if (snapshot.docs.length > 0) {
      // Fetch the existing one
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatroom =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);

      chatRoom = existingChatroom;
    } else {
      // Create a new one
      ChatRoomModel newChatroom = ChatRoomModel(
        chatroomid: uuid.v1(),
        lastMessage: "",
        participants: {
          widget.userModel.uid.toString(): true,
          targetUser.uid.toString(): true,
        },
      );

      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(newChatroom.chatroomid)
          .set(newChatroom.toMap());

      chatRoom = newChatroom;

      log("New Chatroom Created!");
    }

    return chatRoom;
  }

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
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.keyboard_double_arrow_left),
          ),
          backgroundColor: const Color.fromARGB(255, 0, 150, 135),
          title: Text(
            "Search Person",
            style: GoogleFonts.ubuntu(color: Colors.white),
          ),
        ),
        body: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            child: Column(
              children: [
                const SizedBox(height: 40),
                TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xFF014A44), width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                      filled: true,
                      fillColor: Color.fromARGB(208, 255, 255, 255),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Color(0xFF014A44),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(30),
                        ),
                      ),
                      labelText: 'Email Address'),
                ),
                SizedBox(
                  height: 40,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(76, 50),
                    primary: const Color(0xFF009688),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    setState(() {});
                  },
                  child: const Text(
                    "Search",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("users")
                        .where("email", isEqualTo: searchController.text)
                        .where("email", isNotEqualTo: widget.userModel.email)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        if (snapshot.hasData) {
                          QuerySnapshot dataSnapshot =
                              snapshot.data as QuerySnapshot;

                          if (dataSnapshot.docs.length > 0) {
                            Map<String, dynamic> userMap = dataSnapshot.docs[0]
                                .data() as Map<String, dynamic>;

                            UserModel searchedUser = UserModel.fromMap(userMap);

                            return Card(
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  color: Colors.black38,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: ListTile(
                                onTap: () async {
                                  ChatRoomModel? chatroomModel =
                                      await getChatroomModel(searchedUser);

                                  if (chatroomModel != null) {
                                    Navigator.pop(context);
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return ChatRoomPage(
                                        targetUser: searchedUser,
                                        userModel: widget.userModel,
                                        firebaseUser: widget.firebaseUser,
                                        chatroom: chatroomModel,
                                      );
                                    }));
                                  }
                                },
                                leading: CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(searchedUser.profilepic!),
                                  backgroundColor: Colors.grey[500],
                                ),
                                title: Text(searchedUser.fullname!),
                                subtitle: Text(searchedUser.email!),
                                trailing: Icon(Icons.keyboard_arrow_right),
                              ),
                            );
                          } else {
                            return Text("No results found!");
                          }
                        } else if (snapshot.hasError) {
                          return Text("An error occured!");
                        } else {
                          return Text("No results found!");
                        }
                      } else {
                        return CircularProgressIndicator();
                      }
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
