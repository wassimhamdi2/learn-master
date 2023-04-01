// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../ultils/colors_utils.dart';
import 'login.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.black),
      drawer: Drawer(
          child: Column(
        // ignore: prefer_const_literals_to_create_immutables
        children: [
          Container(
            child: Center(
              child: Image.asset(
                  "assets/img/learn.png",
                  color: Colors.white,
                ),
            ),
            height: screenHeight * 0.25,
            decoration: BoxDecoration(gradient: LinearGradient(colors: [
          hexStringToColor("CB2B93"),
          hexStringToColor("9546C4"),
          hexStringToColor("5E61F4"),
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          ),
          ListTile(
            title: Text("cours"),
            leading: Icon(Icons.book),
            onTap: () {},
          ),
          ListTile(
            title: Text("Groupe"),
            leading: Icon(Icons.group_rounded),
            onTap: () {},
          ),
          ListTile(
            title: Text("Questions"),
            leading: Icon(Icons.question_mark),
            onTap: () {},
          ),
          ListTile(
            title: Text("Quiz"),
            leading: Icon(Icons.quiz),
            onTap: () {},
          ),
          ListTile(
            title: Text("event"),
            leading: Icon(Icons.event),
            onTap: () {},
          ),
          ListTile(
            title: Text("Log Out"),
            leading: Icon(Icons.logout_outlined),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LoginPage()));
            },
          ),
        ],
      )),
      body: Container(
        child: Text("helosqdqsdqsddqsdqsdqsdqsdqsd"),
      ),
    );
  }
}
