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
  final String? currentUserId= currentUser?.uid;
bool isLoading = false;
int postCount = 0;
List<Post>posts = [];

  @override
  void initState() {
    super.initState();
    getProfilePosts();
  }

getProfilePosts() async {
  setState(() {
    isLoading = true;
  });
  QuerySnapshot snapshot = await postsRef.doc(widget.profileId).collection('userPosts').orderBy('timestamp',descending: true)
  .get();
  setState(() {
    isLoading = false;
    postCount = snapshot.docs.length;
    posts = snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
  });
}

  editProfile() {
    Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => EditProfile(currentUserId : widget.profileId)),
);
  }

  // buildButton() {
  //   return Container(
  //     padding: EdgeInsets.only(top: 2.0),
  //     child: TextButton(
  //       onPressed:()=>editProfle(),
  //       child: Container(
  //         height: 27.0,
  //         width: 150.0, // set a specific width
  //         child: Text(
  //           "Edit Profile",
  //           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
  //         ),
  //         alignment: Alignment.center,
  //         decoration: BoxDecoration(
  //             color: Colors.blue,
  //             borderRadius: BorderRadius.circular(5.0),
  //             border: Border.all(color: Colors.blue)),
  //       ),
  //     ),
  //   );
  // }

  // Widget buildProfileButton() {
    // bool isprofileOwner = currentUserId == widget.profileId;
  //   if (!isprofileOwner) {
  //     return buildButton("Edit Profile", editProfile);
  //   }
  //   return Container();
  // }

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
                            buildCountColumn("post", postCount),
                            buildCountColumn("followers", 0),
                            buildCountColumn("following", 0),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              padding: EdgeInsets.only(top: 10.0),
                                child: TextButton(
                              onPressed: () => editProfile(),
                              child: Container(
                                height: 27.0,
                                width: 250.0, // set a specific width
                                child: Text(
                                  "Edit Profile",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(5.0),
                                    border: Border.all(color: Colors.blue)),
                              ),
                            ),
                            ),
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
  builProfilePosts(){
    if(isLoading){
      circularProgress();
    }
    return Column(children: posts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
            builProfilePosts(),
        ],
      ),
    );
  }
}
