import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:learn/models/user.dart';
import 'package:learn/reusable_widgets/custom_image.dart';
import 'package:learn/screens/home.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:random_string/random_string.dart';

class Training extends StatefulWidget {
  final String date;
  final String price;
  final String postId;
  final String mediaUrl;

  Training({
    required this.postId,
    required this.date,
    required this.price,
    required this.mediaUrl,
  });
  factory Training.fromDocument(DocumentSnapshot doc) {
    return Training(
      date: doc['date'],
      price: doc['price'],
      mediaUrl: doc['mediaUrl'],
      postId: doc['postId'],
    );
  }

  @override
  State<Training> createState() => _TrainingState(
        postId: this.postId,
        date: this.date,
        price: this.price,
        mediaUrl: this.mediaUrl,
      );
}

class _TrainingState extends State<Training> {
  User? currentU;
  final String? currentUserId = user?.uid;
  final String postId;
  final String date;
  final String price;
  final String mediaUrl;
  _TrainingState({
    required this.postId,
    required this.date,
    required this.price,
    required this.mediaUrl,
  });

  Future<void> getUser() async {
    final doc = await usersRef.doc(user!.uid).get();
    currentU = User.fromDocument(doc);
  }

  String SecondRole = "";
  User? currentUer;
  @override
  void initState() {
    getUser();
    super.initState();
    getUserr();
  }

  getUserr() async {
    DocumentSnapshot doc = await usersRef.doc(currentUserId).get();
    currentUer = User.fromDocument(doc);
    setState(() {
      SecondRole = currentUer!.role;
    });
  }

  Future<void> downloadAndSaveImage(String imageUrl) async {
    String name = randomAlphaNumeric(6);
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = '${tempDir.path}/$name.jpg';
      File tempFile = File(tempPath);
      await tempFile.writeAsBytes(response.bodyBytes);

      // Save the image to the device's gallery
      await GallerySaver.saveImage(tempFile.path, albumName: 'LearnMe');

      // Optional: Delete the temporary file after saving it to the gallery
      tempFile.delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("training downloadrd with success "),
          backgroundColor: Colors.blue.withOpacity(0.8),
          behavior: SnackBarBehavior.floating));
    } else {
      throw Exception('Failed to download image');
    }
  }

  postOption(parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text("taining choises"),
            children: [
              SimpleDialogOption(
                child: Text("Delete training"),
                onPressed: () {
                  Navigator.pop(context);
                  if (SecondRole != 'admin') {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("sorry you are not admin "),
                        backgroundColor: Colors.blue.withOpacity(0.8),
                        behavior: SnackBarBehavior.floating));
                  } else {
                    deletePost();
                    deleteImageFromFirebase(mediaUrl);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("training deleted with success "),
                        backgroundColor: Colors.blue.withOpacity(0.8),
                        behavior: SnackBarBehavior.floating));
                  }
                },
              ),
              SimpleDialogOption(
                child: Text("save the training"),
                onPressed: () {
                  Navigator.pop(context);
                  downloadAndSaveImage(mediaUrl);
                },
              ),
              SimpleDialogOption(
                child: Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }

  Future<void> deletePost() async {
    // Delete post document from userPosts collection
    await FirebaseFirestore.instance
        .collection("Event")
        .doc("training")
        .collection("allFiles")
        .doc(postId)
        .delete();
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

  buildPostHeader() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "     date :${date}",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black, fontSize: 15),
          ),
          Text(
            "     price: ${price}",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black, fontSize: 15),
          ),
        ],
      ),
    );
  }

  builPostImage() {
    return cachedNetworkImage(mediaUrl);
    // cachedNetworkImage(mediaUrl);
    // return Container(
    //   child: PhotoView(
    //     imageProvider: NetworkImage(mediaUrl) ,
    //     // minScale: PhotoViewComputedScale.contained * 0.8,
    //     // maxScale: PhotoViewComputedScale.covered * 2.0,
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        postOption(context);
      },
      child: Container(
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: Colors.purple.shade200,
              width: 2.0,
            )),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            builPostImage(),
            buildPostHeader(),
          ],
        ),
      ),
    );
  }
}
