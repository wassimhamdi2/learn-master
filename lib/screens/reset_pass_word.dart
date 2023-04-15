import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../ultils/colors_utils.dart';

class resetScreen extends StatefulWidget {
  const resetScreen({super.key});

  @override
  State<resetScreen> createState() => _resetScreenState();
}

class _resetScreenState extends State<resetScreen> {
  TextEditingController emailTextContoller = TextEditingController();
  final auth = FirebaseAuth.instance;

  isEmailRegistered(String email) async {
    List<String> signInMethods =
        await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
    print(signInMethods);
    if (signInMethods.isNotEmpty == true) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.scale,
        title: 'Success',
        desc: 'Request send with success.\n Check your mail.',
        btnOkOnPress: () {
          auth.sendPasswordResetEmail(email: email);
          Navigator.of(context).pop();
        },
      )..show();
    } else {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.scale,
        title: 'Error',
        desc: 'No Account with this email',
        btnOkOnPress: () {},
      )..show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Reset Password'),
          centerTitle: true,
        ),
        body: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              hexStringToColor("CB2B93"),
              hexStringToColor("9546C4"),
              hexStringToColor("5E61F4"),
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
            child: ListView(
              children: [
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.3,
                          right: 15,
                          left: 15),
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
                        controller: emailTextContoller,
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
                    Padding(
                      padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          isEmailRegistered(emailTextContoller.text);
                        },
                        child: Text(
                          "Send Request",
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
                                    borderRadius: BorderRadius.circular(30)))),
                      ),
                    )
                  ],
                )
              ],
            )));
  }
}
