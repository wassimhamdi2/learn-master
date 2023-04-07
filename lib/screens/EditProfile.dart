import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:learn/reusable_widgets/Progress.dart';
import 'package:learn/screens/home.dart';

import '../models/user.dart';
import '../ultils/colors.dart';

class EditProfile extends StatefulWidget {
  final String currentUserId;
  const EditProfile({super.key, required this.currentUserId});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController usernameControler = TextEditingController();
  TextEditingController bioControler = TextEditingController();
  bool isLoading = false;
  User? user;
  File? file;
  String secondPhotoUrl = "";
  handleChooseFromGallery() async {
    Navigator.pop(context);
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    setState(() {
      file = pickedFile != null ? File(pickedFile.path) : null;
    });
  }

  handleTakePhoto() async {
    Navigator.pop(context);
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      file = pickedFile != null ? File(pickedFile.path) : null;
    });
  }

  selectImage(parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text("Create post"),
            children: [
              SimpleDialogOption(
                child: Text("Photo with Camera"),
                onPressed: handleTakePhoto,
              ),
              SimpleDialogOption(
                child: Text("Image from Gallery"),
                onPressed: handleChooseFromGallery,
              ),
              SimpleDialogOption(
                child: Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await usersRef.doc(widget.currentUserId).get();
    User user = User.fromDocument(doc);
    usernameControler.text = user.username;
    bioControler.text = user.bio;
    secondPhotoUrl = user.photoUrl;
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        automaticallyImplyLeading:
            false, // Disables the default leading icon behavior.

        iconTheme: IconThemeData(
          size: 30.0,
          color: primaryColor,
        ),
        title: Text('Edit Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.done),
            iconSize: 30,
            onPressed: () => Navigator.pop(context),
          ),
        ],
        titleTextStyle: TextStyle(
            color: primaryColor, fontWeight: FontWeight.bold, fontSize: 18),
        centerTitle: true,
        backgroundColor: mobileBackgroundColor,
      ),
      body: isLoading
          ? circularProgress()
          : ListView(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.8735,
                  color: Colors.black.withOpacity(0.5),
                  child: Column(
                    children: [
                      Padding(
                          padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 50.0,
                                backgroundImage: file == null
                                    ? NetworkImage(secondPhotoUrl)
                                    : FileImage(file!)
                                        as ImageProvider<Object>?,
                              ),
                              Positioned(
                                bottom: 0.0,
                                right: 0.0,
                                child: IconButton(
                                  icon: Icon(Icons.camera_alt,
                                      color: Colors.white),
                                  onPressed: () {
                                    selectImage(context);
                                  },
                                ),
                              ),
                            ],
                          )),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Container(
                              child: TextFormField(
                                validator: (value) {
                                  if (value!.isEmpty ||
                                      !RegExp(r'^[a-z A-z]+$')
                                          .hasMatch(value)) {
                                    return "Enter correct name";
                                  } else {
                                    return null;
                                  }
                                },
                                controller: usernameControler,
                                obscureText: false,
                                enableSuggestions: true,
                                cursorColor: Colors.white,
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.9)),
                                decoration: InputDecoration(
                                  errorStyle: TextStyle(
                                    color: Colors.white54,
                                  ),
                                  // ignore: prefer_const_constructors
                                  prefixIcon: Icon(
                                    Icons.person_outline,
                                    color: Colors.white70,
                                  ),
                                  labelText: "Enter New User name",
                                  labelStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.9)),
                                  filled: true,
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.never,
                                  fillColor: Colors.white.withOpacity(0.3),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                      borderSide: const BorderSide(
                                          width: 0, style: BorderStyle.none)),
                                ),
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                            // ignore: prefer_const_constructors
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              child: TextFormField(
                                validator: (value) {
                                  if (value!.isEmpty ||
                                      !RegExp(r'^[a-z A-z]+$')
                                          .hasMatch(value)) {
                                    return "Enter correct name";
                                  } else {
                                    return null;
                                  }
                                },
                                controller: bioControler,
                                obscureText: false,
                                enableSuggestions: true,
                                cursorColor: Colors.white,
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.9)),
                                decoration: InputDecoration(
                                  errorStyle: TextStyle(
                                    color: Colors.white54,
                                  ),
                                  // ignore: prefer_const_constructors
                                  prefixIcon: Icon(
                                    Icons.text_fields_sharp,
                                    color: Colors.white70,
                                  ),
                                  labelText: "Enter New Bio",
                                  labelStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.9)),
                                  filled: true,
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.never,
                                  fillColor: Colors.white.withOpacity(0.3),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                      borderSide: const BorderSide(
                                          width: 0, style: BorderStyle.none)),
                                ),
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                            // ignore: prefer_const_constructors
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
                        child: ElevatedButton(
                          onPressed: () {},
                          child: Text(
                            "Update Profile",
                            style: const TextStyle(
                                color: Colors.purple,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith((states) {
                                if (states.contains(MaterialState.pressed)) {
                                  return Colors.black26;
                                }
                                return Colors.white;
                              }),
                              shape: MaterialStatePropertyAll<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(30)))),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
