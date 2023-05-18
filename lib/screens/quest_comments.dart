import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learn/models/user.dart' as usser;
import 'package:learn/screens/profile_screen.dart';
import 'package:random_string/random_string.dart';
import '../ultils/colors.dart';
import 'home.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentsQues extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  CommentsQues(
      {required this.postId,
      required this.postOwnerId,
      required this.postMediaUrl});

  @override
  State<CommentsQues> createState() => _CommentsQuesState(
      postId: this.postId,
      postOwnerId: this.postOwnerId,
      postMediaUrl: this.postMediaUrl);
}

class _CommentsQuesState extends State<CommentsQues> {
  usser.User? currentUserr = null;
  TextEditingController commentController = TextEditingController();
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  _CommentsQuesState(
      {required this.postId,
      required this.postOwnerId,
      required this.postMediaUrl});
  String AnswerId = "";
  @override
  initState() {
    super.initState();
    giveUser();
  }

  giveUser() async {
    final doc = await usersRef.doc(user!.uid).get();
    currentUserr = usser.User.fromDocument(doc);
  }

  Widget buildComments() {
    return StreamBuilder(
      stream: postQuestionn
          .doc(postId)
          .collection("Answers")
          .orderBy("timestamp", descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.data?.docs.length == 0) {
          return Center(
            child: Text("No Answers Yet",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.normal
            ),
            ),
          );
        }
        List<Commentt> comments = [];
        snapshot.data?.docs.forEach((doc) {
          comments.add(Commentt.fromDocument(doc));
          print(comments);
        });
        return ListView(
          children: comments,
        );
      },
    );
  }

  addComment() {
    AnswerId = randomAlphaNumeric(16);
    print("posted");
    postQuestionn.doc(postId).collection("Answers").doc(AnswerId).set({
      "username": currentUserr?.username,
      "comment": commentController.text,
      "timestamp": timestamp,
      "avatarUrl": currentUserr?.photoUrl,
      "userId": currentUserr?.uid,
      "AnswerId": AnswerId,
      "postId":postId
    });
    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.purple),
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
            decoration: InputDecoration(labelText: "write a Answer..."),
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

class Commentt extends StatelessWidget {
  
  final String username;
  final String postId;
  final String AnswerId;
  final String userId;
  final String avatarUrl;
  final String comment;
  final Timestamp timestamp;
  Commentt({
    required this.username,
    required this.postId,
    required this.AnswerId,
    required this.userId,
    required this.avatarUrl,
    required this.comment,
    required this.timestamp,
  });
  factory Commentt.fromDocument(DocumentSnapshot doc) {
    return Commentt(
      username: doc['username'],
      postId: doc['postId'],
      AnswerId: doc['AnswerId'],
      userId: doc['userId'],
      comment: doc['comment'],
      timestamp: doc['timestamp'],
      avatarUrl: doc['avatarUrl'],
    );
  }
  deleteAnswer() async {
    await FirebaseFirestore.instance
        .collection("postQuestion")
        .doc(postId)
        .collection("Answers")
        .doc(AnswerId)
        .delete();
    try {
      debugPrint('File deleted successfully.');
    } catch (e) {
      debugPrint('Error deleting file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        if (user!.uid == userId) {
          AwesomeDialog(
              context: context,
              dialogType: DialogType.info,
              animType: AnimType.rightSlide,
              title: 'Delete Verification',
              desc: 'Are u sure to delete the Answer',
              btnCancelOnPress: () {},
              btnOkOnPress: () {
                deleteAnswer();
                // ScaffoldMessenger.of(context).showSnackBar(
                //   SnackBar(
                //     content: Text('Document deleted successfully.'),
                //     duration: Duration(seconds: 3),
                //   ),
                // );
              }).show();
        }
      },
      child: Column(
        children: [
          ListTile(
            title: Text(comment),
            leading: GestureDetector(
              onTap: (){
                if (user!.uid != userId) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ProfileScreen(profileId: userId)));
                }
              },
              child: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(avatarUrl),
              ),
            ),
            subtitle: Text(timeago.format(timestamp.toDate())),
          )
        ],
      ),
    );
  }
}
