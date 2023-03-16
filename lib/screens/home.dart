import 'package:flutter/material.dart';
import 'package:learn/screens/login.dart';

class homePage extends StatefulWidget {
  const homePage({super.key});

  @override
  State<homePage> createState() => _HomePageState();
}

class _HomePageState extends State<homePage> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body:Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(context  ,MaterialPageRoute(builder: (context) => LoginPage()));
          }, child: Text("Log Out"),
        ),
      ) ,
    );
  }
}