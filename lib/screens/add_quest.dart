import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:learn/models/user.dart';

final userssRef = FirebaseFirestore.instance.collection("users");

class AddQuest extends StatefulWidget {
  final File? image;
  final String currentUserId;
  const AddQuest({
    super.key,
    this.image,
    required this.currentUserId,
  });

  @override
  State<AddQuest> createState() => _AddQuestState();
}

class _AddQuestState extends State<AddQuest> {
  File? lastImg;
  String secondPhotoUrl = "";
  String SecondName = "";
  String SecondRole = "";
  File? _image = null;
  Widget imageExemple() {
    if (_image != null) {
      return Container(
        alignment: Alignment.topRight,
        height: 150,
        width: 150,
        child: IconButton(
          onPressed: () {
            setState(() {
              _image = null;
            });
          },
          icon: Icon(Icons.close),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
              fit: BoxFit.cover,
              image: FileImage(_image!) as ImageProvider<Object>),
        ),
      );
    } else if (lastImg != null) {
      return Container(
        alignment: Alignment.topRight,
        height: 150,
        width: 150,
        child: IconButton(
          onPressed: () {
            setState(() {
              lastImg = null;
            });
          },
          icon: Icon(Icons.close),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
              fit: BoxFit.cover,
              image: FileImage(lastImg!) as ImageProvider<Object>),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  @override
  void initState() {
    getUser();
    lastImg = widget.image;
    super.initState();
  }

  getUser() async {
    DocumentSnapshot doc = await userssRef.doc(widget.currentUserId).get();
    User user = User.fromDocument(doc);
    setState(() {
      secondPhotoUrl = user.photoUrl;
      SecondName = user.username;
      SecondRole = user.role;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade200,
        appBar: AppBar(
          title: Text("you can ask !"),
        ),
        body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              color: Colors.grey.shade200,
              padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 0.0),
              // color: Colors.white,
              child: Column(children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(secondPhotoUrl),
                    backgroundColor: Colors.grey,
                    radius: 25,
                  ),
                  title: Text(
                    SecondName,
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 17),
                  ),
                  subtitle: Text(
                    SecondRole,
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                        fontSize: 14),
                  ),
                ),
                const SizedBox(height: 10.0),
                Container(
                  color: Colors.white.withOpacity(0.4),
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: 6,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      hintText: 'What\'s on your mind?',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final pickedFile = await ImagePicker().pickImage(
                            source: ImageSource.camera,
                            maxHeight: 675,
                            maxWidth: 960,
                          );
                          setState(() {
                            _image = pickedFile != null
                                ? File(pickedFile.path)
                                : null;
                          });
                        },
                        child: Container(
                          child: const Row(
                            children: [
                              Icon(
                                Icons.camera_enhance,
                                color: Colors.red,
                              ),
                              SizedBox(
                                width: 12,
                              ),
                              Text(
                                'Camera',
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ),
                      ),
                      //
                      const VerticalDivider(width: 8.0, thickness: 3),
                      GestureDetector(
                        onTap: () async {
                          final pickedFile = await ImagePicker().pickImage(
                            source: ImageSource.gallery,
                          );
                          setState(() {
                            _image = pickedFile != null
                                ? File(pickedFile.path)
                                : null;
                          });
                        },
                        child: Container(
                          child: const Row(
                            children: [
                              Icon(
                                Icons.photo_library,
                                color: Colors.green,
                              ),
                              SizedBox(
                                width: 12,
                              ),
                              Text(
                                'Photo',
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                imageExemple(),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () async {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.send,
                        color: Colors.purple,
                        size: 24.0,
                      ),
                      SizedBox(
                        width: 15.0,
                      ),
                      Text(
                        "publish",
                        style: const TextStyle(
                            color: Colors.purple,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                    ],
                  ),
                  style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all<Size>(
                          Size(200, 50)), // set the minimum size
                      maximumSize: MaterialStateProperty.all<Size>(
                          Size(200, 50)), // set the minimum size

                      backgroundColor:
                          MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.pressed)) {
                          return Colors.black26;
                        }
                        return Colors.white;
                      }),
                      shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)))),
                ),
                // Container(
                //   height: 200,
                //   width: 200,
                //   child: Text(""),
                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(20),
                //     image: DecorationImage(
                //         fit: BoxFit.cover,
                //         image: widget.image == null
                //             ? NetworkImage(
                //                 "https://www.aquaportail.com/pictures1106/anemone-clown_1307889811-fleur.jpg")
                //             : FileImage(widget.image!)
                //                 as ImageProvider<Object>),
                //   ),
                // )
              ]),
            )));
  }
}
