// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:learn/reusable_widgets/reusable_widget.dart';
import 'package:learn/screens/logup.dart';
import 'package:learn/ultils/colors_utils.dart';
import 'home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _passwordTextContoller = TextEditingController();
  TextEditingController _emailTextContoller = TextEditingController();
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
              child: reusableTextField("Enter UserName", Icons.person_outline,
                  false, _emailTextContoller),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              child: reusableTextField("Enter Password", Icons.lock_outline,
                  true, _passwordTextContoller),
            ),
            SizedBox(
              height: 20,
            ),
            signInSignUpButton(context, true, () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => homePage()));
            }),
            SizedBox(
              height: 20,
            ),
            signUpOption(context),
          ],
        ),
      ),
    );
  }
}
