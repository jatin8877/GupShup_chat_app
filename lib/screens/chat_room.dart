import 'dart:developer';
import 'package:chat_gupshup/models/messages_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../models/chat_room_model.dart';
import '../models/user_model.dart';

class ChatRoomPage extends StatefulWidget {
  final UserModel targetUser;
  final ChatRoomModel chatroom;
  final UserModel userModel;
  final User firebaseUser;

  const ChatRoomPage(
      {Key? key,
      required this.targetUser,
      required this.chatroom,
      required this.userModel,
      required this.firebaseUser})
      : super(key: key);

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  TextEditingController messageController = TextEditingController();

  void sendMessage() async {
    String msg = messageController.text.trim();
    messageController.clear();

    if (msg != "") {
      // Send Message
      MessageModel newMessage = MessageModel(
          messageid: uuid.v1(),
          sender: widget.userModel.uid,
          createdon: DateTime.now(),
          text: msg,
          seen: false);

      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .collection("messages")
          .doc(newMessage.messageid)
          .set(newMessage.toMap());

      widget.chatroom.lastMessage = msg;
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .set(widget.chatroom.toMap());

      log("Message Sent!");
    }
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
          toolbarHeight: 100,
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.keyboard_double_arrow_left,
                color: Color(0xFF014A44)),
          ),
          title: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey[300],
                backgroundImage:
                    NetworkImage(widget.targetUser.profilepic.toString()),
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                widget.targetUser.fullname.toString(),
                style: GoogleFonts.ubuntu(
                    color: const Color(0xFF014A44),
                    fontSize: 20,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
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
            child: Column(
              children: [
                // This is where the chats will go
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.only(top: 20, left: 10, right: 10),
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("chatrooms")
                          .doc(widget.chatroom.chatroomid)
                          .collection("messages")
                          .orderBy("createdon", descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.active) {
                          if (snapshot.hasData) {
                            QuerySnapshot dataSnapshot =
                                snapshot.data as QuerySnapshot;

                            return ListView.builder(
                              reverse: true,
                              itemCount: dataSnapshot.docs.length,
                              itemBuilder: (context, index) {
                                MessageModel currentMessage =
                                    MessageModel.fromMap(
                                        dataSnapshot.docs[index].data()
                                            as Map<String, dynamic>);

                                return Row(
                                  mainAxisAlignment: (currentMessage.sender ==
                                          widget.userModel.uid)
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 2,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 12,
                                      ),
                                      decoration: BoxDecoration(
                                          // borderRadius: BorderRadius.all(Radius.circular(20),
                                          color: (currentMessage.sender ==
                                                  widget.userModel.uid)
                                              ? const Color(0xFF009688)
                                              : const Color.fromARGB(
                                                  255, 131, 131, 131),
                                          borderRadius: (currentMessage
                                                      .sender ==
                                                  widget.userModel.uid)
                                              ? const BorderRadius.only(
                                                  bottomRight: Radius.zero,
                                                  bottomLeft:
                                                      Radius.circular(8),
                                                  topLeft: Radius.circular(8),
                                                  topRight: Radius.circular(8),
                                                )
                                              : const BorderRadius.only(
                                                  bottomLeft: Radius.zero,
                                                  bottomRight:
                                                      Radius.circular(8),
                                                  topLeft: Radius.circular(8),
                                                  topRight: Radius.circular(8),
                                                )),
                                      child: ConstrainedBox(
                                        constraints:
                                            const BoxConstraints(maxWidth: 300),
                                        child: Text(
                                          currentMessage.text.toString(),
                                          style: GoogleFonts.ubuntu(
                                              height: 1.2,
                                              color: Colors.white,
                                              fontSize: 15),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else if (snapshot.hasError) {
                            return const Center(
                              child: Text(
                                  "An error occured! Please check your internet connection."),
                            );
                          } else {
                            return const Center(
                              child: Text("Say hi to your new friend"),
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

                const SizedBox(height: 10.0),
                Container(
                  color: Colors.grey[200],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: Row(
                    children: [
                      Flexible(
                        child: TextField(
                          controller: messageController,
                          maxLines: null,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            hintText: "Enter message",
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xFF014A44), width: 2.0),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                            ),
                            filled: true,
                            fillColor: Color.fromARGB(208, 255, 255, 255),
                            prefixIcon: Icon(
                              Icons.emoji_emotions_outlined,
                              color: Colors.grey,
                            ),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Container(
                        decoration: BoxDecoration(
                            color: const Color(0xFF009688),
                            borderRadius: BorderRadius.circular(30)),
                        child: IconButton(
                          onPressed: () {
                            sendMessage();
                          },
                          icon: const Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                        ),
                      ),
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
