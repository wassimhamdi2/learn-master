// ignore_for_file: prefer_const_constructors, use_build_context_synchronously
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learn/reusable_widgets/reusable_widget.dart';
import 'package:learn/ultils/colors_utils.dart';
import 'package:learn/screens/home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  GlobalKey<FormState> formKey2 = GlobalKey<FormState>();
  TextEditingController _passwordTextContoller = TextEditingController();
  TextEditingController _emailTextContoller = TextEditingController();

  signinn() async {
    var formdata = formKey2.currentState;
    User? user = FirebaseAuth.instance.currentUser;
    if (formdata!.validate()) {
      try {
        // ignore: unused_local_variable
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: _emailTextContoller.text,
                password: _passwordTextContoller.text);
        if (user != null && user.emailVerified == false) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.scale,
            title: 'Error',
            desc: 'Sorry your email not verified.',
            btnOkOnPress: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => LoginPage()));
            },
          )..show();
        } else {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomePage()));
        }
        print("sign in");
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.scale,
            title: 'Error',
            desc: 'No user found for that email.',
            btnOkOnPress: () {},
          )..show();
        } else if (e.code == 'wrong-password') {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.scale,
            title: 'Error',
            desc: 'Wrong password provided for that user.',
            btnOkOnPress: () {},
          )..show();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
          hexStringToColor("CB2B93"),
          hexStringToColor("9546C4"),
          hexStringToColor("5E61F4"),
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 120, 20, 0),
          children: [
            Form(
              key: formKey2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      child: Image.asset(
                    "assets/img/Learn_me_c.png",
                    color: Colors.white,
                  )),
                  SizedBox(height: 50),
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
                  SizedBox(
                    height: 20,
                  ),
                  signInSignUpButton(context, true, () {
                    signinn();
                    // Navigator.push(
                    //     context, MaterialPageRoute(builder: (context) => homePage()));
                  }),
                  SizedBox(
                    height: 20,
                  ),
                  signUpOption(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
