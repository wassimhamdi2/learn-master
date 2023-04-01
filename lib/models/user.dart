import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String email;
  final String uid;
  final String photoUrl;
  final String username;
  final String bio;


  const User({
    required this.username,
    required this.uid,
    required this.photoUrl,
    required this.email,
    required this.bio,
  });

  static User fromDocument(DocumentSnapshot doc) {
    return User(
      uid: doc['uid'],
      bio: doc['bio'],
      email: doc['email'],
      photoUrl: doc['photoUrl'],
      username: doc['username'],
    );
  }
}
