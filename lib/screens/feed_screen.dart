// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learn/screens/ask_page.dart';
import 'package:learn/screens/check_if_admin.dart';
import 'package:learn/screens/course_home.dart';
import 'package:learn/screens/msg_home.dart';
import 'package:learn/screens/quiz_home.dart';
import 'package:learn/ultils/colors.dart';
import '../models/post.dart';
import '../reusable_widgets/Progress.dart';
import '../ultils/colors_utils.dart';
import 'package:learn/screens/Home.dart';
import 'login.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  bool isLoading = false;
  String? rolee = '';
  bool isAdminn = false;
  List<Post> posts = [];
  @override
  void initState() {
    super.initState();
    getFollowingPosts();
    debugPrint(user!.uid);
  }

  getFollowingPosts() async {
    setState(() {
      isLoading = true;
    });
    List<String> followingIds = [];
    // First, get a reference to the current user's followers collection
    CollectionReference followingCollection =
        followingRef.doc(user!.uid).collection('userFollowing');
// Then, use a query to get all documents in the current user's followers collection
    QuerySnapshot followersSnapshot = await followingCollection.get();
// Loop through each document in the followers collection and add the user ID to the list

    followersSnapshot.docs.forEach((doc) {
      followingIds.add(doc.id);
    });
    // followingIds.add("Uc0KOmqlg8N4xMfjRujST6hcNSs2");

    for (String userId in followingIds) {
      // Get a reference to the user's posts collection
      CollectionReference postsCollection =
          postsRef.doc(userId).collection('userPosts');
      // Use a query to get all documents in the user's posts collection
      QuerySnapshot postsSnapshot =
          await postsCollection.orderBy('timestamp', descending: true).get();
      setState(() {
        isLoading = false;
        // Loop through each document in the user's posts collection and add it to the followingPosts list
        postsSnapshot.docs.forEach((doc) {
          posts.add(Post.fromDocument(doc));
        });
      });
    }
  }

  builfollowingPosts() {
    // if (isLoading) {
    //   return circularProgress();
    // } else
    if (posts.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/img/noPosts.png',
              height: 260.0,
            ),
            Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Text("No Posts",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      fontSize: 22.0,
                    )))
          ],
        ),
      );
    } else {
      if (isLoading) {
        return circularProgress();
      }

      return Column(children: posts);
    }
  }

  chat() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MsgHome()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
            backgroundColor: mobileBackgroundColor,
            iconTheme: IconThemeData(color: Colors.purple),
            centerTitle: true,
            actions: [IconButton(icon: Icon(Icons.send), onPressed: chat)],
            title: Image.asset(
              'assets/img/Learn_me_c.png',
              height: 50,
              color: Colors.purple,
            )),
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
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                hexStringToColor("CB2B93"),
                hexStringToColor("9546C4"),
                hexStringToColor("5E61F4"),
              ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
            ),
            ListTile(
              title: Text("Courses"),
              leading: Icon(Icons.book),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CourseHome()));
              },
            ),
            ListTile(
              title: Text("Groupe"),
              leading: Icon(Icons.group_rounded),
              onTap: () {},
            ),
            ListTile(
              title: Text("Questions"),
              leading: Icon(Icons.question_mark),
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => AskMe()));
              },
            ),
            ListTile(
              title: Text("Quiz"),
              leading: Icon(Icons.quiz),
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => HomeQuiz()));
              },
            ),
            ListTile(
              title: Text("Event"),
              leading: Icon(Icons.event),
              onTap: () {},
            ),
            ListTile(
              title: Text("E-mails  Managment"),
              leading: Icon(Icons.manage_accounts),
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => checkIfAdmin()));
              },
            ),
            ListTile(
              title: Text("Log Out"),
              leading: Icon(Icons.logout_outlined),
              onTap: () async {
                await FirebaseAuth.instance.signOut(); // clears the cache
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginPage()));
              },
            ),
          ],
        )),
        body: Container(
          child: ListView(
            children: [
              SizedBox(
                height: 10,
              ),
              Divider(
                height: 0.0,
              ),
              builfollowingPosts(),
            ],
          ),
        ));
  }
}
