import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:learn/screens/add_quest.dart';
import '../ultils/colors.dart';
import 'Home.dart';

class AskMe extends StatefulWidget {
  const AskMe({super.key});

  @override
  State<AskMe> createState() => _AskMeState();
}

class _AskMeState extends State<AskMe> {
  File? _image;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.home),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
        iconTheme: IconThemeData(
          size: 30.0,
          color: primaryColor,
        ),
        titleTextStyle: TextStyle(
            color: primaryColor, fontWeight: FontWeight.bold, fontSize: 18),
        centerTitle: true,
        title: Text("Ask Question"),
        backgroundColor: mobileBackgroundColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              margin: EdgeInsets.only(top: 5),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  shape: BoxShape.rectangle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 0.0),
                // color: Colors.white,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddQuest(
                                      image: _image,
                                      currentUserId: currentUser!.uid,
                                    )));
                      },
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage:
                                NetworkImage(currentUser!.photoUrl),
                            radius: 25,
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            "  What\'s on your mind?",
                            style: TextStyle(fontSize: 15.5),
                          )
                        ],
                      ),
                    ),
                    const Divider(height: 10.0, thickness: 1),
                    Container(
                      height: 40.0,
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
                              if (_image != null) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AddQuest(
                                              image: _image,
                                              currentUserId: currentUser!.uid,
                                            )));
                              }
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
                          // ElevatedButton.icon(
                          //   style: ButtonStyle(
                          //     backgroundColor: MaterialStateProperty.all<Color>(
                          //         Colors.white),
                          //     elevation: MaterialStateProperty.all<double>(10),
                          //   ),
                          //   onPressed: () => print('Camera'),
                          //   icon: const Icon(
                          //     Icons.camera_enhance,
                          //     color: Colors.red,
                          //   ),
                          //   label: Text(
                          //     'Camera',
                          //     style: TextStyle(color: Colors.black),
                          //   ),
                          // ),
                          const VerticalDivider(width: 8.0, thickness: 1),
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
                              if (_image != null) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AddQuest(
                                              image: _image,
                                              currentUserId: currentUser!.uid,
                                            )));
                              }
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
                          // ElevatedButton.icon(
                          //    style: ButtonStyle(
                          //     backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                          //     elevation: MaterialStateProperty.all<double>(10),
                          //   ),
                          //   onPressed: () => print('Photo'),
                          //   icon: const Icon(
                          //     Icons.photo_library,
                          //     color: Colors.green,
                          //   ),
                          //   label: Text('Photo',style: TextStyle(color: Colors.black),),
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
