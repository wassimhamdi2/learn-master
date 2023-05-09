import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:learn/models/user.dart';
import 'package:intl/intl.dart';
import '../reusable_widgets/Progress.dart';
import '../screens/Home.dart';
import '../screens/profile_screen.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class Download extends StatefulWidget {
  final String file;
  final String fileUrl;
  final String photoUrl;
  final Timestamp timestamp;
  final String uid;
  final String username;
  Download(
      {required this.file,
      required this.fileUrl,
      required this.username,
      required this.photoUrl,
      required this.uid,
      required this.timestamp});
  factory Download.fromDocument(DocumentSnapshot doc) {
    return Download(
      file: doc['file'],
      fileUrl: doc['fileUrl'],
      username: doc['username'],
      photoUrl: doc['photoUrl'],
      uid: doc['uid'],
      timestamp: doc['timestamp'],
    );
  }

  @override
  State<Download> createState() => _DownloadState(
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
  final String username;
  final String photoUrl;
  _DownloadState(
      {required this.file,
      required this.fileUrl,
      required this.username,
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
              onPressed: () => print('deleting post'),
              icon: Icon(Icons.more_vert),
            ),
          );
        });
  }

  downloadFileFromFirebase(BuildContext context, String downloadUrl) async {
    // Show a Snackbar to indicate that the download has started.
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //         content: Text("Downloading file...")));

    try {
      // Get the filename from the download URL.
      final Uri uri = Uri.parse(downloadUrl);
      final String filename = uri.pathSegments.last;

      // Get the local app directory to store the downloaded file.
      final Directory appDirectory = await getApplicationDocumentsDirectory();
      final String filePath = '${appDirectory.path}/$filename';

      // Download the file.
      final http.Response response = await http.get(Uri.parse(downloadUrl));
      await File(filePath).writeAsBytes(response.bodyBytes);

      // Show a Snackbar to indicate that the download has finished.
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   content: Text('File downloaded.'),
      //   duration: Duration(seconds: 2),
      // ));
    } on PlatformException catch (e) {
      debugPrint("${e}}");
      // Show an error Snackbar if there was an error downloading the file.
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   content: Text('Error downloading file: ${e.message}'),
      //   duration: Duration(seconds: 2),
      // ));
    }
  }

  builDownloadPost() {
    return Container(
      child: Row(
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
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final snackBar = SnackBar(content: Text('Downloading file...'));
                scaffoldMessenger.showSnackBar(snackBar);

                // Get the app's temporary directory to store the downloaded file
                final tempDir = await getExternalStorageDirectory();
                final filePath = '${tempDir!.path}/$file';
                

                try {
                  // Use Dio to download the file and save it to the app's temporary directory
                  final dio = Dio();
                  await dio.download(fileUrl, filePath);
                  debugPrint("$filePath");
                  // Show a SnackBar to indicate that the download has finished
                  final snackBar = SnackBar(content: Text('File downloaded!'));
                  scaffoldMessenger.showSnackBar(snackBar);
                } on DioError catch (e) {
                  // Show a SnackBar with the error message if the download fails
                  final snackBar =
                      SnackBar(content: Text('Error: ${e.message}'));
                  scaffoldMessenger.showSnackBar(snackBar);
                } catch (e) {
                  // Show a SnackBar with a generic error message if the download fails for another reason
                  final snackBar =
                      SnackBar(content: Text('Error downloading file.'));
                  scaffoldMessenger.showSnackBar(snackBar);
                }
              },
              // Show a SnackBar to indicate that the download has started
//   final scaffoldMessenger = ScaffoldMessenger.of(context);
//   final snackBar = SnackBar(content: Text('Downloading file...'));
//   scaffoldMessenger.showSnackBar(snackBar);
//   final String fileName = fileUrl.split('/').last.split('?').first;
//   final Reference storageRef = FirebaseStorage.instance.refFromURL(fileUrl);

//   final Directory appDocDir = await getApplicationDocumentsDirectory();
//   final String filePath = '${appDocDir.path}/$fileName';
//   final File localFile = File(filePath);

//   if (await localFile.exists()) {
//     // if file already exists locally, return it
// final snackBar = SnackBar(content: Text('file exist already'));
//   scaffoldMessenger.showSnackBar(snackBar);
//   } else {
//     // if file doesn't exist locally, download it
//      await storageRef.writeToFile(localFile);
// final snackBar = SnackBar(content: Text('file downloding'));
//   scaffoldMessenger.showSnackBar(snackBar);
//   }

              icon: Icon(Icons.download))
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
