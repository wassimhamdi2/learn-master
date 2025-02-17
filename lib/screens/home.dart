import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as UUser;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learn/screens/activity_feed.dart';
import 'package:learn/screens/profile_screen.dart';
import 'package:learn/screens/search_screen.dart';
import 'package:learn/models/user.dart';
import '../ultils/colors.dart';
import 'add_post_screen.dart';
import 'feed_screen.dart';

final usersRef = FirebaseFirestore.instance.collection("users");
final user = UUser.FirebaseAuth.instance.currentUser;
final Reference storageRef = FirebaseStorage.instance.ref();
final commentsRef = FirebaseFirestore.instance.collection('comments');
final postQuestionn = FirebaseFirestore.instance.collection('postQuestion');
final eventRef = FirebaseFirestore.instance.collection('Event');
final postsRef = FirebaseFirestore.instance.collection("posts");
final activityFeedRef = FirebaseFirestore.instance.collection('feed');
final coursesRef = FirebaseFirestore.instance.collection('Courses');
final followersRef = FirebaseFirestore.instance.collection('followers');
final chatRef = FirebaseFirestore.instance.collection("chats");
final followingRef = FirebaseFirestore.instance.collection('following');
final DateTime timestamp = DateTime.now();
 User? currentUser ;
 

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _page = 0;
  late PageController pageController; // for tabs animation

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    getUser();
  }

  Future<void> getUser() async {
    final doc = await usersRef.doc(user!.uid).get();
    currentUser = User.fromDocument(doc);
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  void navigationTapped(int page) {
    //Animating Page
    pageController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        children: [
          FeedScreen(),
          SearchScreen(),
          AddPostScreen(currentUser: currentUser),
          ActivityFeed(),
          ProfileScreen(profileId: currentUser?.uid ?? ''),
        ],
      ),
      bottomNavigationBar: CupertinoTabBar(
        backgroundColor: mobileBackgroundColor,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: (_page == 0) ? primaryColor : secondaryColor,
            ),
            label: '',
            backgroundColor: primaryColor,
          ),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.search,
                color: (_page == 1) ? primaryColor : secondaryColor,
              ),
              label: '',
              backgroundColor: primaryColor),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.add_circle,
                color: (_page == 2) ? primaryColor : secondaryColor,
              ),
              label: '',
              backgroundColor: primaryColor),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.favorite,
              color: (_page == 3) ? primaryColor : secondaryColor,
            ),
            label: '',
            backgroundColor: primaryColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              color: (_page == 4) ? primaryColor : secondaryColor,
            ),
            label: '',
            backgroundColor: primaryColor,
          ),
        ],
        onTap: navigationTapped,
        currentIndex: _page,
      ),
    );
  }
}
