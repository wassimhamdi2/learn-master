import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learn/reusable_widgets/Progress.dart';
import 'package:learn/screens/home.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../ultils/colors.dart';
import 'EditProfile.dart';

class ProfileScreen extends StatefulWidget {
  final String profileId;
  const ProfileScreen({required this.profileId, Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? currentUsser;
  final String? currentUserId = currentUser?.uid;
  bool isLoading = false;
  bool isFollowing = false;
  int? postCount = 0;
  int followerCount = 0;
  int followingCount = 0;
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    // getProfilePosts();
    getUser();
    checkIfFollowing();
    getFollowers();
    getFollowing();
  }

  Future<void> getUser() async {
    final doc = await usersRef.doc(user!.uid).get();
    currentUsser = User.fromDocument(doc);
  }

  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .doc(widget.profileId)
        .collection("userFollowers")
        .doc(user?.uid)
        .get();

    setState(() {
      isFollowing = doc.exists;
    });
  }

  getFollowers() async {
    QuerySnapshot snapshot = await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .get();
    setState(() {
      followerCount = snapshot.docs.length;
    });
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .doc(widget.profileId)
        .collection('userFollowing')
        .get();
    setState(() {
      followingCount = snapshot.docs.length;
    });
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await postsRef
        .doc(widget.profileId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .get();
    setState(() {
      isLoading = false;
      postCount = snapshot.docs.length;
      posts = snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  Widget buildPost() {
    return StreamBuilder(
      stream: postsRef
          .doc(widget.profileId)
          .collection('userPosts')
          .orderBy("timestamp", descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        postCount = snapshot.data?.docs.length;

        if (snapshot.data?.docs.length == 0) {
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
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return circularProgress();
        }
        List<Post> posts = [];
        snapshot.data?.docs.forEach((doc) {
          posts.add(Post.fromDocument(doc));
          print(posts);
        });
        return Column(
          children: posts,
        );
      },
    );
  }

  editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditProfile(currentUserId: widget.profileId)),
    );
  }

  buildButton(String e) {
    bool isprofileOwner = user!.uid == widget.profileId;
    return Container(
      padding: EdgeInsets.only(top: 2.0),
      child: TextButton(
        onPressed: () {
          if (isprofileOwner) {
            editProfile();
          } else if (isFollowing) {
            handleUnfollowUser();
          } else if (!isFollowing) {
            handleFollowUser();
          }
        },
        child: Container(
          height: 27.0,
          width: 150.0, // set a specific width
          child: Text(
            e,
            style: TextStyle(
                color: isFollowing ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: isFollowing ? Colors.white : Colors.blue,
              borderRadius: BorderRadius.circular(5.0),
              border:
                  Border.all(color: isFollowing ? Colors.grey : Colors.blue)),
        ),
      ),
    );
  }

  Widget buildProfileButton() {
    bool isprofileOwner = user!.uid == widget.profileId;
    if (isprofileOwner) {
      return buildButton("Edit Profile");
    } else if (isFollowing) {
      return buildButton("Unfollow");
    } else if (!isFollowing) {
      return buildButton("follow");
    } else {
      return Text("");
    }
  }

  handleUnfollowUser() {
    setState(() {
      isFollowing = false;
    });
    // remove follower
    followersRef
        .doc(widget.profileId)
        .collection("userFollowers")
        .doc(currentUsser?.uid.toString())
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // remove following
    followingRef
        .doc(currentUsser?.uid.toString())
        .collection("userFollowing")
        .doc(widget.profileId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    //delete activity feed item
    activityFeedRef
        .doc(widget.profileId)
        .collection("feedItems")
        .doc(currentUsser?.uid.toString())
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  handleFollowUser() {
    setState(() {
      isFollowing = true;
    });
    // Make auth user follower of Another user (update their followers collection)
    followersRef
        .doc(widget.profileId)
        .collection("userFollowers")
        .doc(currentUsser?.uid.toString())
        .set({});
    // put  that user on your following collection (update your following collection )
    followingRef
        .doc(currentUsser?.uid.toString())
        .collection("userFollowing")
        .doc(widget.profileId)
        .set({});
    //add activity feed for that user to notify about new followers (us)
    activityFeedRef
        .doc(widget.profileId)
        .collection("feedItems")
        .doc(currentUsser?.uid.toString())
        .set({
      "mediaUrl": "",
      "commentData": "",
      "postId": "",
      "type": "follow",
      "ownerId": widget.profileId,
      "username": currentUsser?.username.toString(),
      "userId": currentUsser?.uid.toString(),
      "userProfileImg": currentUsser!.photoUrl,
      "timestamp": timestamp,
    });
  }

  Column buildCountColumn(String label, int count) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count.toString(),
          style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 4.0),
          child: Text(
            label,
            style: TextStyle(
                color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w400),
          ),
        )
      ],
    );
  }

  FutureBuilder buildProfileHeader() {
    return FutureBuilder(
        future: usersRef.doc(widget.profileId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          User user = User.fromDocument(snapshot.data);
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40.0,
                    backgroundColor: Colors.blueGrey,
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            buildCountColumn("post", postCount!),
                            buildCountColumn("followers", followerCount),
                            buildCountColumn("following", followingCount),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            buildProfileButton()
                            // Container(
                            //   padding: EdgeInsets.only(top: 10.0),
                            //   child: TextButton(
                            //     onPressed: () => editProfile(),
                            //     child: Container(
                            //       height: 27.0,
                            //       width: 250.0, // set a specific width
                            //       child: Text(
                            //         "Edit Profile",
                            //         style: TextStyle(
                            //             color: Colors.white,
                            //             fontWeight: FontWeight.bold),
                            //       ),
                            //       alignment: Alignment.center,
                            //       decoration: BoxDecoration(
                            //           color: Colors.blue,
                            //           borderRadius: BorderRadius.circular(5.0),
                            //           border: Border.all(color: Colors.blue)),
                            //     ),
                            //   ),
                            // ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 12.0),
                child: Text(
                  user.username,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                ),
              ),
              // Container(
              //   alignment: Alignment.centerLeft,
              //   padding: EdgeInsets.only(top: 4.0),
              //   child: Text(
              //     user.username,
              //     style: TextStyle(fontWeight: FontWeight.bold),
              //   ),
              // ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 12.0),
                child: Text(
                  user.bio,
                ),
              )
            ]),
          );
        });
  }

  // builProfilePosts() {
  //   if (isLoading) {
  //     return circularProgress();
  //   } else if (posts.isEmpty) {
  //     return Container(
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Image.asset(
  //             'assets/img/noPosts.png',
  //             height: 260.0,
  //           ),
  //           Padding(
  //               padding: EdgeInsets.only(top: 20.0),
  //               child: Text("No Posts",
  //                   style: TextStyle(
  //                     fontWeight: FontWeight.bold,
  //                     color: Colors.red,
  //                     fontSize: 22.0,
  //                   )))
  //         ],
  //       ),
  //     );
  //   } else {
  //     return Column(children: posts);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          size: 30.0,
          color: primaryColor,
        ),
        titleTextStyle: TextStyle(
            color: primaryColor, fontWeight: FontWeight.bold, fontSize: 18),
        centerTitle: true,
        title: Text("Profile"),
        backgroundColor: mobileBackgroundColor,
      ),
      body: ListView(
        children: [
          buildProfileHeader(),
          Divider(
            height: 0.0,
          ),
          buildPost(),
        ],
      ),
    );
  }
}
