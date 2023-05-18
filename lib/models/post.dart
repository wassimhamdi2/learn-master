import 'dart:async';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:learn/screens/comments.dart';
import 'package:learn/models/user.dart';
import 'package:learn/reusable_widgets/Progress.dart';
import 'package:learn/screens/home.dart';
import 'package:intl/intl.dart';
import 'package:learn/screens/profile_screen.dart';
import '../reusable_widgets/custom_image.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  final dynamic likes;
  final Timestamp timestamp;
  Post(
      {required this.postId,
      required this.ownerId,
      required this.username,
      required this.location,
      required this.description,
      required this.mediaUrl,
      this.likes,
      required this.timestamp});
  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc['postId'],
      ownerId: doc['ownerId'],
      username: doc['username'],
      location: doc['location'],
      description: doc['description'],
      mediaUrl: doc['mediaUrl'],
      likes: doc['likes'],
      timestamp: doc['timestamp'],
    );
  }

  int getLikeCount(likes) {
    // if no likes, return 0
    if (likes == null) {
      return 0;
    }
    int count = 0;
    void addLike(val) {
      if (val == true) {
        count += 1;
      }
    }

    likes.values.forEach(addLike);
    return count;
  }

  @override
  State<Post> createState() => _PostState(
        postId: this.postId,
        ownerId: this.ownerId,
        username: this.username,
        location: this.location,
        description: this.description,
        mediaUrl: this.mediaUrl,
        likes: this.likes,
        timestamp: this.timestamp,
        likeCount: this.getLikeCount(this.likes),
      );
}

class _PostState extends State<Post> {
  User? currentU;
  final String? currentUserId = user?.uid;
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  final Timestamp timestamp;
  int likeCount;
  Map likes;
  bool isLiked = false;
  bool showHeart = false;
  _PostState(
      {required this.postId,
      required this.ownerId,
      required this.username,
      required this.location,
      required this.description,
      required this.mediaUrl,
      required this.likeCount,
      required this.likes,
      required this.timestamp});

  Future<void> getUser() async {
    final doc = await usersRef.doc(user!.uid).get();
    currentU = User.fromDocument(doc);
  }

  String SecondName = "";
  User? currentUer;
  @override
  void initState() {
    getUser();
    super.initState();
    isLiked = likes[currentUserId] == true;
    getUserr();
  }

  getUserr() async {
    DocumentSnapshot doc = await usersRef.doc(ownerId).get();
    currentUer = User.fromDocument(doc);
    setState(() {
      SecondName = currentUer!.username;
    });
  }

  Future<void> deletePost() async {
    // Delete post document from userPosts collection
    await FirebaseFirestore.instance
        .collection("posts")
        .doc(currentUserId)
        .collection("userPosts")
        .doc(postId)
        .delete();
  }

  Future<void> deleteComment() async {
    // Delete comments document
    try {
       // Get a reference to the comments collection
    final collectionReference = FirebaseFirestore.instance.collection('comments');
    // Delete the subcollection associated with the document
    final subcollectionReference = collectionReference.doc(postId).collection('commentss');
    final subcollectionSnapshot = await subcollectionReference.get();
    
    // Delete each document in the subcollection
    for (final docSnapshot in subcollectionSnapshot.docs) {
      await docSnapshot.reference.delete();
    }

      print('Document deleted successfully');
      print(postId);
    } catch (e) {
      print('Error deleting document: $e');
      
    }
  }

  Future<void> deleteFeed() async {
// Delete feedItems associated with the post
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("feed")
          .doc(currentUserId)
          .collection("feedItems")
          .where('postId', isEqualTo: postId)
          .get();

      for (final doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      print('Documents deleted successfully!');
    } catch (e) {
      print('Error deleting documents: $e');
    }
  }

  Future<void> deleteImageFromFirebase(String imageUrl) async {
    // Get the reference to the Firebase Storage instance
    final storage = FirebaseStorage.instance;

    // Get the reference to the image file using the imageURL
    final imageRef = storage.refFromURL(imageUrl);

    try {
      // Delete the image file from Firebase Storage
      await imageRef.delete();
      print('Image deleted successfully');
    } catch (e) {
      print('Failed to delete image: $e');
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
                  desc: 'Are u sure to delete the post',
                  btnCancelOnPress: () {},
                  btnOkOnPress: () {
                    deletePost();
                    deleteFeed();
                    deleteComment();
                    deleteImageFromFirebase(mediaUrl);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('post deleted successfully.'),
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
        future: usersRef.doc(ownerId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          User user =
              User.fromDocument(snapshot.data as DocumentSnapshot<Object?>);
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              backgroundColor: Colors.grey,
            ),
            title: GestureDetector(
              onTap: () {
                if (user.uid != currentUserId) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ProfileScreen(profileId: user.uid)));
                }
              },
              child: Text(
                user.username,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            subtitle: Text("$location \n$formattedDate"),
            trailing: IconButton(
              key: _buttonKey,
              onPressed: () {
                if (ownerId == currentUserId) {
                  showPopupMenu(context);
                }
              },
              icon: Icon(Icons.more_vert),
            ),
          );
        });
  }

  builPostImage() {
    return GestureDetector(
      onDoubleTap: () => handelLikePost(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          cachedNetworkImage(mediaUrl),
          showHeart
              ? Icon(
                  Icons.favorite,
                  size: 150,
                  color: Colors.red.withOpacity(0.5),
                )
              : Text("")
        ],
      ),
    );
  }

  handelLikePost() {
    bool _isLiked = likes[currentUserId] == true;
    if (_isLiked) {
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .update({'likes.$currentUserId': false});
      removeLikeFromActivityFeed();
      setState(() {
        likeCount -= 1;
        isLiked = false;
        likes[currentUserId] = false;
      });
    } else if (!_isLiked) {
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .update({'likes.$currentUserId': true});
      addLikeToActivityFeed();
      setState(() {
        likeCount += 1;
        isLiked = true;
        likes[currentUserId] = true;
        showHeart = true;
      });
      Timer(Duration(milliseconds: 500), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  removeLikeFromActivityFeed() {
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedRef
          .doc(ownerId)
          .collection("feedItems")
          .doc("${postId}_${currentU!.uid}")
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    }
  }

  addLikeToActivityFeed() {
    //add a notification to the postOwner's activity feed only if comment made bvy other user (to avoid getting nptifaction for our own like)
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedRef
          .doc(ownerId)
          .collection("feedItems")
          .doc("${postId}_${currentU!.uid}")
          .set({
        "type": "like",
        "username": currentU!.username,
        "userId": currentU!.uid,
        "userProfileImg": currentU!.photoUrl,
        "postId": postId,
        "mediaUrl": mediaUrl,
        "timestamp": timestamp,
        "commentData": ""
      });
    }
  }

  buildPostFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(padding: EdgeInsets.only(top: 40.0, left: 20.0)),
            GestureDetector(
              onTap: () => handelLikePost(),
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                size: 28.0,
                color: Colors.pink,
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 40.0, left: 20.0)),
            GestureDetector(
              onTap: () => showComments(context,
                  postId: postId, ownerId: ownerId, mediaUrl: mediaUrl),
              child: Icon(
                Icons.chat,
                size: 28.0,
                color: Colors.blue.shade800,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                "$likeCount likes",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                "$SecondName",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(child: Text(description))
          ],
        ),
        SizedBox(
          height: 30,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildPostHeader(),
        builPostImage(),
        buildPostFooter(),
      ],
    );
  }
}

showComments(BuildContext context,
    {required String postId,
    required String ownerId,
    required String mediaUrl}) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return Comments(
      postId: postId,
      postOwnerId: ownerId,
      postMediaUrl: mediaUrl,
    );
  }));
}
