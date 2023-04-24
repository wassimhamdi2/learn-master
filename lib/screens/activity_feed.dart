import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learn/reusable_widgets/Progress.dart';
import 'package:learn/screens/home.dart';
import 'package:learn/screens/post_screen.dart';
import 'package:learn/screens/profile_screen.dart';
import '../models/user.dart';
import '../ultils/colors.dart';
import 'package:timeago/timeago.dart' as timeago;

class ActivityFeed extends StatefulWidget {
  const ActivityFeed({super.key});

  @override
  State<ActivityFeed> createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  User? currentUserr = null;
  @override
  initState() {
    super.initState();
    giveUser();
  }

  giveUser() async {
    final doc = await usersRef.doc(user!.uid).get();
    currentUserr = User.fromDocument(doc);
  }

  getActivityFeed() async {
    QuerySnapshot snapshot = await activityFeedRef
        .doc(user?.uid)
        .collection('feedItems')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .get();
    List<ActivityFeedItem> feedItems = [];
    snapshot.docs.forEach((doc) {
      feedItems.add(ActivityFeedItem.fromDocument(doc));

    });
    return feedItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.purple),
        titleTextStyle: TextStyle(
            color: primaryColor, fontWeight: FontWeight.bold, fontSize: 18),
        centerTitle: true,
        title: Text("Activity Feed"),
        backgroundColor: mobileBackgroundColor,
      ),
      body: Container(
        color: Colors.blue.withOpacity(0.8),
        child: FutureBuilder(
          future: getActivityFeed(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return circularProgress();
            }
            return ListView(children: snapshot.data as List<Widget>);
          },
        ),
      ),
    );
  }
}

Widget mediaPreview = GestureDetector();
String activityItemText = "";

class ActivityFeedItem extends StatelessWidget {
  final String username;
  final String userId;
  final String type;
  final String mediaUrl;
  final String postId;
  final String userProfileImg;
  final String commentData;
  final Timestamp timestamp;

  ActivityFeedItem({
    required this.username,
    required this.userId,
    required this.type,
    required this.mediaUrl,
    required this.postId,
    required this.userProfileImg,
    required this.commentData,
    required this.timestamp,
  });

  factory ActivityFeedItem.fromDocument(DocumentSnapshot doc) {
    return ActivityFeedItem(
      username: doc["username"],
      userId: doc["userId"],
      type: doc["type"],
      mediaUrl: doc["mediaUrl"],
      postId: doc["postId"],
      userProfileImg: doc["userProfileImg"],
      commentData: doc["commentData"],
      timestamp: doc["timestamp"],
    );
  }

  showPost(context) {
    Navigator.push(context,MaterialPageRoute(builder: (Context) =>
    PostScreen(postId: postId ,userId: user!.uid)
    
    ));
  }

  configureMediaPreview(context) {
    if (type == "like" || type == 'comment') {
      mediaPreview = GestureDetector(
        onTap: () => showPost(context),
        child: Container(
            height: 50.0,
            width: 50.0,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(mediaUrl),
                )),
              ),
            )),
      );
    } else {
      mediaPreview = Text(" ");
    }

    if (type == "like") {
      activityItemText = "  liked your post";
    } else if (type == "follow") {
      activityItemText = " is followin you ";
    } else if (type == "comment") {
      activityItemText = "  replied :$commentData ";
    } else {
      activityItemText = "Error :Unknown type '$type' ";
    }
  }

  @override
  Widget build(BuildContext context) {
    configureMediaPreview(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 2.0),
      child: Container(
        color: Colors.white54,
        child: ListTile(
          title: GestureDetector(
              onTap: () => showProfile(context, profileId: user!.uid),
              child: RichText(
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                      style: TextStyle(fontSize: 14.0, color: Colors.black),
                      children: [
                        TextSpan(
                          text: username,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: '$activityItemText')
                      ]))),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(userProfileImg),
          ),
          subtitle: Text(
            timeago.format(timestamp.toDate()),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: mediaPreview,
        ),
      ),
    );
  }
}

showProfile(BuildContext context , {required String profileId}) {
  Navigator.push(context, MaterialPageRoute(builder: (context)=>
  ProfileScreen(profileId : profileId)));
}