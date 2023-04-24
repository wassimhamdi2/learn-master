import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learn/reusable_widgets/Progress.dart';
import 'package:learn/screens/home.dart';

import '../models/post.dart';
import '../ultils/colors.dart';

class PostScreen extends StatelessWidget {
  final String userId;
  final String postId;
  PostScreen({required this.userId, required this.postId});


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: postsRef.doc(userId).collection('userPosts').doc(postId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        Post post =
            Post.fromDocument(snapshot.data as DocumentSnapshot<Object?>);
        return Center(
          child: Scaffold(
            appBar: AppBar(
              iconTheme: IconThemeData(color: Colors.purple),
              titleTextStyle: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
              centerTitle: true,
              title: Text(
                post.description,
                overflow: TextOverflow.ellipsis,
              ),
              backgroundColor: mobileBackgroundColor,
            ),
            body: ListView(
              children: [
                Container(
                  margin: EdgeInsets.only(top:15),
                  child: post,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
