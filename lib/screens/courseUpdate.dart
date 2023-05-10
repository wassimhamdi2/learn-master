import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:learn/screens/course_home.dart';
import 'package:path/path.dart' as bath;
import '../ultils/colors.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;


class courseUpdate extends StatefulWidget {
  final String file;
  const courseUpdate({required this.file, Key? key}) : super(key: key);

  @override
  State<courseUpdate> createState() => _courseUpdateState();
}

class _courseUpdateState extends State<courseUpdate> {
  String file_name = "";
  File? file = null;
  String downloadUrl = "";
    String extension = "";
      List<String> documentExtensions = [
    'pdf',
    'doc',
    'docx',
    'ppt',
    'pptx',
    'xls',
    'xlsx'
  ];
    Future<firebase_storage.UploadTask?> uploadFile(File? file) async {
    if (file == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Unable to upload ! No file select"),
          backgroundColor: Colors.blue.withOpacity(.8),
          behavior: SnackBarBehavior.floating));
      return null;
    }

    firebase_storage.UploadTask uploadTask;

    // Create a Reference to the file
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('playground')
        .child('/${widget.file}');

    // final metadata = firebase_storage.SettableMetadata(
    //     contentType: 'application/pdf',
    //     customMetadata: {'picked-file-path': file.path});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Uploading..!"),
        backgroundColor: Colors.blue.withOpacity(.8),
        behavior: SnackBarBehavior.floating));
    // print("Uploading..!");
    if (documentExtensions.contains(extension)) {
      uploadTask = ref.putData(await file.readAsBytes());
      TaskSnapshot storageSnap = await uploadTask.whenComplete(() => null);
      String url = await storageSnap.ref.getDownloadURL();

      setState(() {
        downloadUrl = url;
      });
      debugPrint(downloadUrl);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("done"),
          backgroundColor: Colors.blue.withOpacity(.8),
          behavior: SnackBarBehavior.floating));

      return Future.value(uploadTask);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Unable to upload because file is not type document"),
          backgroundColor: Colors.blue.withOpacity(.8),
          behavior: SnackBarBehavior.floating));
      return null;
    }
  }
   String getFileExtension(String path) {
    if (path != "") {
      final file = File(path);
      if (file.existsSync()) {
        return file.path.split('.').last;
      }
    }
    return "nothing";
  }
  @override
Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CourseHome()),
              );
            },
          ),
        iconTheme: const IconThemeData(
          size: 30.0,
          color: primaryColor,
        ),
        titleTextStyle: const TextStyle(
            color: primaryColor, fontWeight: FontWeight.bold, fontSize: 18),
        centerTitle: true,
        title: const Text("Update File"),
        backgroundColor: mobileBackgroundColor,
      ),
      body: Container(
        width: double.infinity,
        color: Colors.blueAccent.withOpacity(0.2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                final path = await FlutterDocumentPicker.openDocument();
                setState(() {
                  if (path != null) {
                    extension = getFileExtension(path);
                    file_name = bath.basename(path);
                    file = File(path);
                  }
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.done,
                    color: Colors.purple,
                    size: 24.0,
                  ),
                  SizedBox(
                    width: 15.0,
                  ),
                  Text(
                    "select file",
                    style: const TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ],
              ),
              style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all<Size>(
                      Size(200, 50)), // set the minimum size
                  maximumSize: MaterialStateProperty.all<Size>(
                      Size(200, 50)), // set the minimum size

                  backgroundColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.pressed)) {
                      return Colors.black26;
                    }
                    return Colors.white;
                  }),
                  shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)))),
            ),
            const SizedBox(height: 15),
            // fileName(file),
           Text("file name is : $file_name",
           style: TextStyle(
            color: Colors.purple,
            fontWeight: FontWeight.bold,
            fontSize: 17

           ),
           ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () async {
                final FirebaseFirestore _firestore = FirebaseFirestore.instance;
                firebase_storage.UploadTask? task=await uploadFile(file);
                if (file != null && task!=null) {
                  await _firestore
                      .collection("Courses")
                      .doc("allFiles")
                      .collection("Files")
                      .doc(widget.file)
                      .update({
                    "fileUrl": downloadUrl,
                  });
                }

                setState(() {
                  file = null;
                  file_name = "";
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.upload_file,
                    color: Colors.purple,
                    size: 24.0,
                  ),
                  SizedBox(
                    width: 15.0,
                  ),
                  Text(
                    "update file",
                    style: const TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ],
              ),
              style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all<Size>(
                      Size(200, 50)), // set the minimum size
                  maximumSize: MaterialStateProperty.all<Size>(
                      Size(200, 50)), // set the minimum size

                  backgroundColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.pressed)) {
                      return Colors.black26;
                    }
                    return Colors.white;
                  }),
                  shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)))),
            ),
          ],
        ),
      ),
    );
  }
}