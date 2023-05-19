import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learn/screens/home.dart';
import '../ultils/colors.dart';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../api/apis.dart';
// import '../helper/dialogs.dart';
import '../models/chat_user.dart';
import '../widgets/chat_user_card.dart';

class MsgHome extends StatefulWidget {
  const MsgHome({super.key});

  @override
  State<MsgHome> createState() => _MsgHomeState();
}

class _MsgHomeState extends State<MsgHome> {
  // for storing all users
  List<ChatUser> _list = [];
  List<ChatUser> listChat = [];
  // List userchat= ["Uc0KOmqlg8N4xMfjRujST6hcNSs2_BAldnu43GgeyslvyBXguv91ejdh1"];
  List<String> userchat = [];

  // for storing searched items
  final List<ChatUser> _searchList = [];
  // for storing search status
  bool _isSearching = false;

  @override
  void initState() {
    fetchDocumentIds();
    super.initState();
    APIs.getSelfInfo();

    //for updating user active status according to lifecycle events
    //resume -- active or online
    //pause  -- inactive or offline
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message: $message');

      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
      }

      return Future.value(message);
    });
  }

 getDocumentIds() async {
  List<String> documentIds = [];

  try {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chats")
        .get();

    snapshot.docs.forEach((doc) {
      documentIds.add(doc.id.toString());
      debugPrint(doc.id);
    });
    setState(() {
      userchat = documentIds;
    });
  } catch (e) {
    print('Error fetching document IDs: $e');
  }

  
}

  void fetchDocumentIds() {
  FirebaseFirestore.instance.collection('chats').get().then((snapshot) {
    if (snapshot != null && snapshot.docs.isNotEmpty) {
      List<String> documentIds = snapshot.docs.map((doc) => doc.id).toList();
      // Use the documentIds list as needed
          setState(() {
      userchat = documentIds;
    });
      print(documentIds);
    }
  }).catchError((error) {
    print('Error getting document IDs: $error');
  });
}
  // void fetchDocumentIds() async {
  //   CollectionReference col =
  //       FirebaseFirestore.instance.collection('chats');
  //   QuerySnapshot querySnapshot = await col.get();

  //   List<String> documentIds = [];

  //   querySnapshot.docs.forEach((doc) {
  //     documentIds.add(doc.id);
  //   });
  //     for (String i in documentIds) {
  //       userchat.add(i);
  //     }
  //   log("${userchat.isEmpty}");
  // }

  // void listUserChat() {
  //   for (var i in _list) {
  //     for (var j in userchat) {
  //       String id1 = "${user!.uid}_${i.uid}";
  //       String id2 = "${i.uid}_${user!.uid}";
  //       if (id1 == j || id2 == j) {
  //         setState(() {
  //           listChat.add(i);
  //         });

  //       }
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //for hiding keyboard when a tap is detected on screen
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        //if search is on & back button is pressed then close search
        //or else simple close current screen on back button click
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          //app bar
          appBar: AppBar(
              leading: IconButton(
                icon: const Icon(CupertinoIcons.home),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
              ),
              iconTheme: const IconThemeData(
                size: 30.0,
                color: primaryColor,
              ),
              titleTextStyle: const TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
              centerTitle: true,
              title: _isSearching
                  ? TextField(
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Name, Email, ...'),
                      autofocus: true,
                      style: const TextStyle(fontSize: 17, letterSpacing: 0.5),
                      //when search text changes then updated search list
                      onChanged: (val) {
                        log("ser $_isSearching");
                        log("ser ${_searchList.length}");
                        //search logic
                        _searchList.clear();

                        for (var i in _list) {
                          if (i.username
                                  .toLowerCase()
                                  .contains(val.toLowerCase()) ||
                              i.email
                                  .toLowerCase()
                                  .contains(val.toLowerCase())) {
                            _searchList.add(i);
                            setState(() {
                              _searchList;
                            });
                          }
                        }
                      },
                    )
                  : const Text('Chat'),
              backgroundColor: mobileBackgroundColor,
              actions: [
                //search user button
                IconButton(
                    onPressed: () {
                      setState(() {
                        _isSearching = !_isSearching;
                      });
                    },
                    icon: Icon(_isSearching
                        ? CupertinoIcons.clear_circled_solid
                        : Icons.search)),
              ]),

          //floating button to add new user
          // floatingActionButton: Padding(
          //   padding: const EdgeInsets.only(bottom: 10),
          //   child: FloatingActionButton(
          //       onPressed: () {
          //       },
          //       child: const Icon(Icons.add_comment_rounded)),
          // ),

          //body
          body: StreamBuilder(
            stream: APIs.getMyUsersId(),

            //get id of only known users
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                //if data is loading
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(child: CircularProgressIndicator());

                //if some or all data is loaded then show it
                case ConnectionState.active:
                case ConnectionState.done:
                  return StreamBuilder(
                    stream: APIs.getAllUsers(
                        snapshot.data?.docs.map((e) => e.id).toList() ?? []),

                    //get only those user, who's ids are provided
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        //if data is loading
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                        // return const Center(
                        //     child: CircularProgressIndicator());

                        //if some or all data is loaded then show it
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _list = data
                                  ?.map((e) => ChatUser.fromJson(e.data()))
                                  .toList() ??
                              [];
                      //fetch user from chat for show it in msg screen  
                      debugPrint("${userchat}");
                      //     for (var i in _list) {
                      //       for (String j in userchat) {
                      //         String id1 = "${user!.uid}_${i.uid}";
                      //         String id2 = "${i.uid}_${user!.uid}";
                      //         if (id1 == j || id2 == j) {
                      //           listChat.add(i);
                      //         }
                      //       }
                      //     }


                          if (_list.isNotEmpty) {
                            var mq = MediaQuery.of(context).size;
                            return ListView.builder(
                                itemCount: _isSearching
                                    ? _searchList.length
                                    : _list.length,
                                padding: EdgeInsets.only(top: mq.height * .01),
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return ChatUserCard(
                                      user: _isSearching
                                          ? _searchList[index]
                                          : _list[index]);
                                });
                          } else {
                            return const Center(
                              child: Text('No Message Found',
                                  style: TextStyle(fontSize: 20)),
                            );
                          }
                      }
                    },
                  );
              }
            },
          ),
        ),
      ),
    );
  }
}
