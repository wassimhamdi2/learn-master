import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:learn/models/user.dart';
import 'package:intl/intl.dart';
import 'package:learn/screens/courseUpdate.dart';
import 'package:learn/screens/course_home.dart';
import '../reusable_widgets/Progress.dart';
import '../screens/Home.dart';
import '../screens/profile_screen.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class Download extends StatefulWidget {
  final String dropdownvalue;
  final String file;
  final String fileUrl;
  final String photoUrl;
  final Timestamp timestamp;
  final String uid;
  final String username;
  Download(
      {required this.file,
      required this.dropdownvalue,
      required this.fileUrl,
      required this.username,
      required this.photoUrl,
      required this.uid,
      required this.timestamp});
  factory Download.fromDocument(DocumentSnapshot doc) {
    return Download(
      file: doc['file'],
      dropdownvalue: doc['dropdownvalue'],
      fileUrl: doc['fileUrl'],
      username: doc['username'],
      photoUrl: doc['photoUrl'],
      uid: doc['uid'],
      timestamp: doc['timestamp'],
    );
  }

  @override
  State<Download> createState() => _DownloadState(
        dropdownvalue: this.dropdownvalue,
        file: this.file,
        photoUrl: this.photoUrl,
        fileUrl: this.fileUrl,
        username: this.username,
        uid: this.uid,
        timestamp: this.timestamp,
      );
}

class _DownloadState extends State<Download> {
  User? currentU;
  final String? currentUserId = user?.uid;
  final String file;
  final String fileUrl;
  final Timestamp timestamp;
  final String uid;
  final String dropdownvalue;
  final String username;
  final String photoUrl;
  _DownloadState(
      {required this.file,
      required this.fileUrl,
      required this.username,
      required this.dropdownvalue,
      required this.photoUrl,
      required this.uid,
      required this.timestamp});
  Future<void> getUser() async {
    final doc = await usersRef.doc(user!.uid).get();
    currentU = User.fromDocument(doc);
  }

  @override
  void initState() {
    getUser();
    super.initState();
  }

  // courseeUpdate(String file) {
  //   Navigator.pushReplacement(
  //               context, MaterialPageRoute(builder: (context) => courseUpdate(file :file)));
  // }

  // courseDelete(String docId) async {
  //   try {
  //     await FirebaseFirestore.instance
  //         .collection("Courses")
  //         .doc("allFiles")
  //         .collection("Files")
  //         .doc(docId)
  //         .delete();
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Document deleted successfully.'),
  //         duration: Duration(seconds: 3),
  //       ),
  //     );

  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Error deleting document: $e'),
  //         duration: Duration(seconds: 3),
  //       ),
  //     );
  //     // print('Error deleting document: $e');
  //   }
  // }

  postMangment(parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text("Post Management"),
            children: [
              SimpleDialogOption(
                child: Text("Update Course "),
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => courseUpdate(file: file)));
                },
              ),
              SimpleDialogOption(
                child: Text("Delete Course"),
                onPressed: () async {
                  firebase_storage.Reference ref = firebase_storage
                      .FirebaseStorage.instance
                      .ref()
                      .child('playground')
                      .child('/${file}');
                  try {
                    await FirebaseFirestore.instance
                        .collection("Courses")
                        .doc("allFiles")
                        .collection("Files")
                        .doc(file)
                        .delete();
                    try {
                      await ref.delete();
                      debugPrint('File deleted successfully.');
                    } catch (e) {
                      debugPrint('Error deleting file: $e');
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Document deleted successfully.'),
                        duration: Duration(seconds: 3),
                      ),     
                    );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CourseHome()));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error deleting document: $e'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                    // print('Error deleting document: $e');
                  }
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

  buildDownloadHeader() {
    var date = timestamp.toDate();
    var formattedDate = DateFormat.yMMMMd().add_jm().format(date);
    return FutureBuilder(
        future: usersRef.doc(uid).get(),
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
            subtitle: Text("$formattedDate"),
            trailing: IconButton(
              onPressed: () => postMangment(context),
              icon: Icon(Icons.more_vert),
            ),
          );
        });
  }

  builDownloadPost() {
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$file",
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple),
              ),
              IconButton(
                  onPressed: () async {
                    try {
                      // Show a message to indicate that the download has started
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Downloading file from $file...'),
                          duration: Duration(seconds: 1),
                        ),
                      );

                      // Use Dio to download the file and save it to the app's external storage directory
                      final dio = Dio();
                      final response = await dio.get(
                        fileUrl,
                        options: Options(responseType: ResponseType.bytes),
                      );
                      final dir = await getExternalStorageDirectory();
                      final filee = File('${dir!.path}/$file');
                      await filee.writeAsBytes(response.data, flush: true);

                      // Show a message to indicate that the download has finished
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('File downloaded to ${filee.path}.'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    } on DioError catch (e) {
                      // Show a SnackBar with the error message if the download fails
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${e.message}'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    } catch (e) {
                      // Show a SnackBar with a generic error message if the download fails for another reason
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error downloading file.'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    }
                  },
                  icon: Icon(Icons.download))
            ],
          ),
          Text(
            "course of $dropdownvalue ",
            style: TextStyle(
                color: Colors.purple,
                fontSize: 15,
                fontWeight: FontWeight.normal),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildDownloadHeader(),
            builDownloadPost(),
          ],
        ),
      ),
    );
  }
}
