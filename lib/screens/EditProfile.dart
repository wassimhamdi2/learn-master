// ignore_for_file: unnecessary_null_comparison

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:learn/reusable_widgets/Progress.dart';
import 'package:learn/screens/home.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as Im;

import '../models/user.dart';
import '../ultils/colors.dart';

class EditProfile extends StatefulWidget {
  final String currentUserId;
  const EditProfile({super.key, required this.currentUserId});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  FirebaseStorage storage = FirebaseStorage.instance;
  TextEditingController usernameControler = TextEditingController();
  TextEditingController bioControler = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isLoading = false;
  User? user;
  File? file;
  String ProfileImId = Uuid().v4();
  String secondPhotoUrl = "";
  String SecondBio = "";
  String SecondName = "";
  handleChooseFromGallery() async {
    Navigator.pop(context);
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    setState(() {
      file = pickedFile != null ? File(pickedFile.path) : null;
    });
  }

  compressImage() async {
    final tempDit = await getTemporaryDirectory();
    final path = tempDit.path;
    Im.Image? imageFile = Im.decodeImage(file!.readAsBytesSync());
    final compressedImageFile = File('$path/img_$ProfileImId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile!, quality: 85));
    setState(() {
      file = compressedImageFile;
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

  Future<String> uploadImage(File imageFile) async {
    UploadTask uploadTask =
        storageRef.child("post_$ProfileImId.jpg").putFile(imageFile);
    TaskSnapshot storageSnap = await uploadTask.whenComplete(() => null);
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  deletePhoto(String Url) async {
    final Reference ref = storage.refFromURL(Url);
    await ref.delete();
  }

  checkEmpty() {
    if (bioControler.text.isEmpty &&
        usernameControler.text.isEmpty &&
        file != null) {
      bioControler.text = SecondBio;
      usernameControler.text = SecondName;
    }
    if (bioControler.text.isEmpty && usernameControler.text.isNotEmpty) {
      bioControler.text = SecondBio;
    }
    if (bioControler.text.isNotEmpty && usernameControler.text.isEmpty) {
      usernameControler.text = SecondName;
    }
  }

  update() async {
    checkEmpty();
    var formdata = formKey.currentState;
    if (formdata!.validate()) {
      if (file == null) {
        usersRef.doc(widget.currentUserId).update(
            {"username": usernameControler.text, "bio": bioControler.text});
        SnackBar snackBar = SnackBar(content: Text("Profile updated"));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      } else {
        await compressImage();
        String mediaUrl = await uploadImage(file!);
        SnackBar snackBar = SnackBar(content: Text("Profile updated"));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        usersRef.doc(widget.currentUserId).update({
          "username": usernameControler.text,
          "bio": bioControler.text,
          "photoUrl": mediaUrl
        });
        deletePhoto(secondPhotoUrl);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      }
    }
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
    secondPhotoUrl = user.photoUrl;
    SecondBio = user.bio;
    SecondName = user.username;
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
                            Form(
                              key: formKey,
                              child: Column(
                                children: [
                                  Container(
                                    child: TextFormField(
                                      validator: (value) {
                                        if (value!.isEmpty ||
                                            !RegExp(r'^[a-zA-Z ]{3,}$')
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
                                            color:
                                                Colors.white.withOpacity(0.9)),
                                        filled: true,
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.never,
                                        fillColor:
                                            Colors.white.withOpacity(0.3),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                            borderSide: const BorderSide(
                                                width: 0,
                                                style: BorderStyle.none)),
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
                                            !RegExp(r'^.{1,50}$')
                                                .hasMatch(value)) {
                                          return "bio to long";
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
                                            color:
                                                Colors.white.withOpacity(0.9)),
                                        filled: true,
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.never,
                                        fillColor:
                                            Colors.white.withOpacity(0.3),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                            borderSide: const BorderSide(
                                                width: 0,
                                                style: BorderStyle.none)),
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
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            update();
                          },
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
