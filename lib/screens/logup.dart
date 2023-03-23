import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learn/screens/home.dart';
import 'package:learn/screens/login.dart';
import '../reusable_widgets/reusable_widget.dart';
import '../ultils/colors_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class LogupPage extends StatefulWidget {
  const LogupPage({super.key});

  @override
  State<LogupPage> createState() => _LogupPageState();
}

class _LogupPageState extends State<LogupPage> {
  String rrole = "";
  List Role = [];
  List<String> FinalRole = [];
  List mail = [];
  List<String> listMail = [];
  CollectionReference Emails =
      FirebaseFirestore.instance.collection("email validation");
  GetRole() async {
    Emails.where("email", isEqualTo: _emailTextContoller.text).get().then((value) {
      value.docs.forEach((element) {
        print(element.data());
        setState(() {
          Role.add(element.data());
        });
      });
      Role.forEach((map) {
        setState(() { FinalRole.add(map['role']); });
      });
      if (FinalRole != []){
        FinalRole.forEach((element){
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

  sginUUp() async {
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
          // adding user in our database
          await _firestore.collection("users").doc(credential.user!.uid).set({
            "username": _userNameTextContoller.text,
            "uid": credential.user!.uid,
            // "photoUrl": photoUrl,
            "email": _emailTextContoller.text,
            // "bio": bio,
            "followers": [],
            "following": [],
            "role":rrole
          });

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
          )..show();
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
