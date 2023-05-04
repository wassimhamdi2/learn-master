import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:learn/screens/login.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../reusable_widgets/reusable_widget.dart';
import '../ultils/colors_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:image/image.dart' as Im;
import 'package:http/http.dart' as http;

final Reference storageR = FirebaseStorage.instance.ref();

class LogupPage extends StatefulWidget {
  const LogupPage({super.key});

  @override
  State<LogupPage> createState() => _LogupPageState();
}

class _LogupPageState extends State<LogupPage> {
  File? file;
  String ProfileImId = Uuid().v4();
  String rrole = "";
  List Role = [];
  List<String> FinalRole = [];
  List mail = [];
  List<String> listMail = [];
  CollectionReference Emails =
      FirebaseFirestore.instance.collection("email validation");
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
        storageR.child("post_$ProfileImId.jpg").putFile(imageFile);
    TaskSnapshot storageSnap = await uploadTask.whenComplete(() => null);
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
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

  GetRole() async {
    Emails.where("email", isEqualTo: _emailTextContoller.text)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        print(element.data());
        setState(() {
          Role.add(element.data());
        });
      });
      Role.forEach((map) {
        setState(() {
          FinalRole.add(map['role']);
        });
      });
      if (FinalRole != []) {
        FinalRole.forEach((element) {
          rrole = element;
          print("im $rrole");
        });
      }
    });
    // print("===================");
    // print(rrole);
  }

  EmailVerife() async {
    QuerySnapshot querySnapshot = await Emails.get();
    List<QueryDocumentSnapshot> listdocs = querySnapshot.docs;
    listdocs.forEach((element) {
      // print("==================================");
      // print(element.data());
      setState(() {
        mail.add(element.data());
      });
    });
    // print(mail);
    mail.forEach((map) {
      // print(map['email']);
      setState(() {
        listMail.add(map['email']);
      });
    });
    // print(listMail);
  }

Future<File> getImageFileFromNetwork(String url) async {
    var response = await http.get(Uri.parse(url));
    var bytes = response.bodyBytes;
    var fileName = url.split('/').last;
    String tempPath = (await getTemporaryDirectory()).path;
    File file = File('$tempPath/$fileName');
    await file.writeAsBytes(bytes);
    return file;
  }

  sginUUp() async {
    if (file == null) {
      file = await getImageFileFromNetwork('https://firebasestorage.googleapis.com/v0/b/learnme-b296f.appspot.com/o/pf.jpg?alt=media&token=33128262-a9ac-49cc-a836-42ac68959d7f');
    }
    var formdata = formKey.currentState;
    if (formdata!.validate()) {
      if (listMail.contains(_emailTextContoller.text)) {
        try {
          final FirebaseFirestore _firestore = FirebaseFirestore.instance;
          //add auth for user
          final credential =
              await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailTextContoller.text,
            password: _passwordTextContoller.text,
          );
          User? user = FirebaseAuth.instance.currentUser;
          if (user != null && !user.emailVerified) {
            await user.sendEmailVerification();
          }
          await compressImage();
          String mediaUrl = await uploadImage(file!);
                    // adding user in our database
          await _firestore.collection("users").doc(credential.user!.uid).set({
            "username": _userNameTextContoller.text,
            "uid": credential.user!.uid,
            "photoUrl": mediaUrl,
            "email": _emailTextContoller.text,
            "bio": bioControler.text,
            "role": rrole,
            "is_online":false,
            "last_active":"0",
            "push_token":"0"

          });
          // ignore: use_build_context_synchronously
          AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.scale,
            title: 'Success',
            desc:
                'Account create with success.Go to your mail and validate it .',
            btnOkOnPress: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => LoginPage()));
            },
          ).show();

        } on FirebaseAuthException catch (e) {
          if (e.code == 'weak-password') {
            AwesomeDialog(
              context: context,
              dialogType: DialogType.error,
              animType: AnimType.scale,
              title: 'Error',
              desc: 'The password provided is too weak.',
              btnOkOnPress: () {},
            )..show();
          } else if (e.code == 'email-already-in-use') {
            AwesomeDialog(
              context: context,
              dialogType: DialogType.error,
              animType: AnimType.scale,
              title: 'Dialog Title',
              desc: 'The account already exists for that email.',
              btnOkOnPress: () {},
            )..show();
          }
        } catch (e) {
          print(e);
        }
      } else {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.scale,
          title: 'Error',
          desc: 'The email  does not exist in departement dataBase.',
          btnOkOnPress: () {},
        )..show();
      }
    }
  }

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController _userNameTextContoller = TextEditingController();
  TextEditingController _passwordTextContoller = TextEditingController();
  TextEditingController _emailTextContoller = TextEditingController();
  TextEditingController bioControler = TextEditingController();

  @override
  void initState() {
    super.initState();
    EmailVerife();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Sign Up",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
          hexStringToColor("CB2B93"),
          hexStringToColor("9546C4"),
          hexStringToColor("5E61F4"),
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child:
            ListView(padding: EdgeInsets.fromLTRB(20, 120, 20, 0), children: [
          Center(
            child: Padding(
                padding: EdgeInsets.only(top: 16.0, bottom: 20.0),
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50.0,
                      backgroundImage: file == null
                          ? AssetImage("assets/img/pf.jpg")
                          : FileImage(file!) as ImageProvider<Object>?,
                    ),
                    Positioned(
                      bottom: 0.0,
                      right: 0.0,
                      child: IconButton(
                        icon: Icon(Icons.camera_alt,
                            color: Colors.purple.withOpacity(0.8)),
                        onPressed: () {
                          selectImage(context);
                        },
                      ),
                    ),
                  ],
                )),
          ),
          Form(
            key: formKey,
            child: Column(
              children: [
                Container(
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty ||
                          !RegExp(r'^[a-z A-z]+$').hasMatch(value)) {
                        return "Enter correct name";
                      } else {
                        return null;
                      }
                    },
                    controller: _userNameTextContoller,
                    obscureText: false,
                    enableSuggestions: true,
                    cursorColor: Colors.white,
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                    decoration: InputDecoration(
                      errorStyle: TextStyle(
                        color: Colors.white54,
                      ),
                      // ignore: prefer_const_constructors
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: Colors.white70,
                      ),
                      labelText: "Enter User name",
                      labelStyle:
                          TextStyle(color: Colors.white.withOpacity(0.9)),
                      filled: true,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
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
                          !RegExp(r'^.{1,50}$').hasMatch(value)) {
                        return "bio to long";
                      } else {
                        return null;
                      }
                    },
                    controller: bioControler,
                    obscureText: false,
                    enableSuggestions: true,
                    cursorColor: Colors.white,
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                    decoration: InputDecoration(
                      errorStyle: TextStyle(
                        color: Colors.white54,
                      ),
                      // ignore: prefer_const_constructors
                      prefixIcon: Icon(
                        Icons.text_fields_sharp,
                        color: Colors.white70,
                      ),
                      labelText: "Enter Bio",
                      labelStyle:
                          TextStyle(color: Colors.white.withOpacity(0.9)),
                      filled: true,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
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
                          !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                        return "Enter correct mail";
                      } else {
                        return null;
                      }
                    },
                    controller: _emailTextContoller,
                    obscureText: false,
                    enableSuggestions: true,
                    cursorColor: Colors.white,
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                    decoration: InputDecoration(
                      errorStyle: TextStyle(
                        color: Colors.white54,
                      ),
                      // ignore: prefer_const_constructors
                      prefixIcon: Icon(
                        Icons.mail,
                        color: Colors.white70,
                      ),
                      labelText: "Enter Email",
                      labelStyle:
                          TextStyle(color: Colors.white.withOpacity(0.9)),
                      filled: true,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      fillColor: Colors.white.withOpacity(0.3),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(
                              width: 0, style: BorderStyle.none)),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty ||
                          !RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.{8,})')
                              .hasMatch(value)) {
                        return "Enter hard Password";
                      } else {
                        return null;
                      }
                    },
                    controller: _passwordTextContoller,
                    obscureText: true,
                    enableSuggestions: !true,
                    cursorColor: Colors.white,
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                    decoration: InputDecoration(
                      errorStyle: TextStyle(
                        color: Colors.white54,
                      ),
                      // ignore: prefer_const_constructors
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: Colors.white70,
                      ),
                      labelText: "Enter Password",
                      labelStyle:
                          TextStyle(color: Colors.white.withOpacity(0.9)),
                      filled: true,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      fillColor: Colors.white.withOpacity(0.3),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(
                              width: 0, style: BorderStyle.none)),
                    ),
                    keyboardType: TextInputType.visiblePassword,
                  ),
                ),
                // ),
                SizedBox(
                  height: 20,
                ),
                signInSignUpButton(context, false, () {
                  sginUUp();
                  GetRole();
                  // Navigator.push(context,
                  //     MaterialPageRoute(builder: (context) => LoginPage()));
                }),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
