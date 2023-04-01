// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learn/screens/add_post_screen.dart';
import 'package:learn/screens/feed_screen.dart';
import 'package:learn/screens/profile_screen.dart';
import 'package:learn/screens/search_screen.dart';

List<Widget> homeScreenItems = [
  const FeedScreen(),
  const SearchScreen(),
  const AddPostScreen(),
  const Text('notifications'),
  const ProfileScreen(uid: '',
    // uid: FirebaseAuth.instance.currentUser!.uid,
  ),
];
