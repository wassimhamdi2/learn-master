import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:learn/screens/Home.dart';
import 'package:learn/models/user.dart' as Usser;
import 'package:learn/screens/quest_comments.dart';
import '../reusable_widgets/Progress.dart';
import '../reusable_widgets/custom_image.dart';
import '../screens/profile_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class postQuestion extends StatelessWidget {
  final String username;
  final String userId;
  final String avatarUrl;
  final String mediaUrl;
  final String post;
  final String postId;
  final Timestamp timestamp;
  postQuestion({
    required this.mediaUrl,
    required this.post,
    required this.postId,
    required this.username,
    required this.userId,
    required this.avatarUrl,
    required this.timestamp,
  });
  factory postQuestion.fromDocument(DocumentSnapshot doc) {
    return postQuestion(
      mediaUrl: doc['mediaUrl'],
      post: doc['post'],
      postId: doc['postId'],
      username: doc['username'],
      userId: doc['userId'],
      timestamp: doc['timestamp'],
      avatarUrl: doc['avatarUrl'],
    );
  }
  deletePost() async {
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('Questions')
        .child('/${"imageOf${postId}"}');

    await FirebaseFirestore.instance
        .collection("postQuestion")
        .doc(postId)
        .delete();
    try {
      await ref.delete();
      debugPrint('File deleted successfully.');
    } catch (e) {
      debugPrint('Error deleting file: $e');
    }
  }

  final GlobalKey _buttonKey = GlobalKey();
  void showPopupMenu(BuildContext context) {
    final RenderBox buttonBox =
        _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final buttonPosition = buttonBox.localToGlobal(Offset.zero);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        buttonPosition.dx,
        buttonPosition.dy + buttonBox.size.height,
        buttonPosition.dx + buttonBox.size.width,
        buttonPosition.dy + buttonBox.size.height * 2,
      ),
      items: [
        PopupMenuItem(
          value: 'wishList',
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
              AwesomeDialog(
                  context: context,
                  dialogType: DialogType.info,
                  animType: AnimType.rightSlide,
                  title: 'Delete Verification',
                  desc: 'Are u sure to delete the question',
                  btnCancelOnPress: () {},
                  btnOkOnPress: () {
                    deletePost();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Document deleted successfully.'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }).show();
            },
            child: Row(children: [
              Icon(
                Icons.delete,
                size: 25.0,
                color: const Color.fromARGB(255, 255, 17, 0),
              ),
              SizedBox(
                width: 4,
              ),
              Text(
                "Delete",
                style: TextStyle(color: Colors.black),
              )
            ]),
          ),
        ),
      ],
    );
  }

  buildPostHeader() {
    var date = timestamp.toDate();
    var formattedDate = DateFormat.yMMMMd().add_jm().format(date);
    return FutureBuilder(
        future: usersRef.doc(userId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          Usser.User userr = Usser.User.fromDocument(
              snapshot.data as DocumentSnapshot<Object?>);
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(userr.photoUrl),
              backgroundColor: Colors.grey,
            ),
            title: GestureDetector(
              onTap: () {
                if (userr.uid != userId) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ProfileScreen(profileId: userr.uid)));
                }
              },
              child: Text(
                userr.username,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            subtitle: Text("$formattedDate"),
            trailing: IconButton(
              key: _buttonKey,
              onPressed: () {
                showPopupMenu(context);
              },
              icon: Icon(Icons.more_vert),
            ),
          );
        });
  }

  builPostImage() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: Text(
              "  ${post}",
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: mediaUrl != "" ? 16 : 18,
              ),
            ))
          ],
        ),
        SizedBox(
          height: 8,
        ),
        Container(
          child: mediaUrl != ""
              ? Container(
                  height: 480,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: cachedNetworkImage(mediaUrl),
                )
              : SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget buildPostFooter(context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(padding: EdgeInsets.only(top: 40.0, left: 20.0)),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => CommentsQues(
                            postId: postId,
                            postOwnerId: userId,
                            postMediaUrl: avatarUrl)));
              },
              // onTap: () => showComments(context,
              //     postId: postId, ownerId: ownerId, mediaUrl: mediaUrl),
              child: Container(
                alignment: Alignment.center,
                width: 170,
                height: 37,
                decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10)),
                child: Text(
                  'Answers',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Colors.purple),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 30,
        )
      ],
    );
  }

  get timeago => null;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      // height: 500,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildPostHeader(),
          builPostImage(),
          SizedBox(
            height: 8,
          ),
          buildPostFooter(context),
        ],
      ),
    );
  }
}
