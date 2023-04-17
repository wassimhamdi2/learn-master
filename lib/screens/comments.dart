import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learn/models/user.dart';
import 'package:learn/reusable_widgets/Progress.dart';
import '../ultils/colors.dart';
import 'home.dart';
import 'package:timeago/timeago.dart' as timeago;

class Comments extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  Comments(
      {required this.postId,
      required this.postOwnerId,
      required this.postMediaUrl});

  @override
  State<Comments> createState() => _CommentsState(
      postId: this.postId,
      postOwnerId: this.postOwnerId,
      postMediaUrl: this.postMediaUrl);
}

class _CommentsState extends State<Comments> {
  User? currentUserr = null;
  TextEditingController commentController = TextEditingController();
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  _CommentsState(
      {required this.postId,
      required this.postOwnerId,
      required this.postMediaUrl});

  @override
  initState() {
    super.initState();
    giveUser();
  }

  giveUser() async {
    final doc = await usersRef.doc(user!.uid).get();
    currentUserr = User.fromDocument(doc);
  }

  Widget buildComments() {
  return StreamBuilder(
    stream: commentsRef
        .doc(postId)
        .collection("comments")
        .orderBy("timestamp", descending: false)
        .snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return circularProgress();
      }
      List<Comment> comments = [];
      snapshot.data?.docs.forEach((doc){
        comments.add(Comment.fromDocument(doc));
        print(comments);
      });
      return ListView(
        children: comments,
      );
    },
  );
}

  addComment() {
    print("posted");
    commentsRef.doc(postId).collection("comments").add({
      "username": currentUserr?.username,
      "comment": commentController.text,
      "timestamp": timestamp,
      "avatarUrl": currentUserr?.photoUrl,
      "userId": currentUserr?.uid
    });
    bool  isNotPostOwner = postOwnerId != currentUserr!.uid;
    if (isNotPostOwner) {
    activityFeedRef
    .doc(postOwnerId)
    .collection('feedItems')
    .add({
       "type": "comment",
       "commentData" : commentController.text ,
        "timestamp": timestamp,
        "postId": postId,
        "userId": currentUserr!.uid,
        "username": currentUserr!.username,
        "userProfileImg": currentUserr!.photoUrl,
        "mediaUrl": postMediaUrl,
    });
    }
    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color:Colors.purple),
        titleTextStyle: TextStyle(
            color: primaryColor, fontWeight: FontWeight.bold, fontSize: 18),
        centerTitle: true,
        title: Text("Comments"),
        backgroundColor: mobileBackgroundColor,
      ),
      body: Column(children: [
        Expanded(child: buildComments()),
        Divider(),
        ListTile(
          title: TextFormField(
            controller: commentController,
            decoration: InputDecoration(labelText: "write a comment..."),
          ),
          trailing: OutlinedButton(
            onPressed: () => addComment(),
            style:
                ButtonStyle(side: MaterialStateProperty.resolveWith((states) {
              return BorderSide.none;
            })),
            child: Text(
              'Post',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
          ),
        )
      ]),
    );
  }
}

class Comment extends StatelessWidget {
  final String username;
  final String userId;
  final String avatarUrl;
  final String comment;
  final Timestamp timestamp;
  Comment({
    required this.username,
    required this.userId,
    required this.avatarUrl,
    required this.comment,
    required this.timestamp,
  });
  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      username: doc['username'],
      userId: doc['userId'],
      comment: doc['comment'],
      timestamp: doc['timestamp'],
      avatarUrl: doc['avatarUrl'],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(comment),
          leading: CircleAvatar(
            backgroundImage:CachedNetworkImageProvider(avatarUrl),
          ),
          subtitle: Text(timeago.format(timestamp.toDate())),
        )
      ],
    );
  }
}
