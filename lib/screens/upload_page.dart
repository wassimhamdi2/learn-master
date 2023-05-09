import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:learn/screens/Home.dart';
import 'package:path/path.dart' as bath;
import '../ultils/colors.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  List<String> documentExtensions = [
    'pdf',
    'doc',
    'docx',
    'ppt',
    'pptx',
    'xls',
    'xlsx'
  ];
  var items = [
    'Java',
    'Python',
    'Machine Learning',
    'Network',
    'Web Develepment',
  ];
  File? file = null;
  String file_name = "";
  String extension = "";
  String dropdownvalue = 'Java';
  TextEditingController fileNameController = TextEditingController();
  String downloadUrl = "";
  final DateTime timestamp = DateTime.now();
  // void initState() {
  //   super.initState();
  //   fileNameController.text=file_name;

  // }

  // Widget fileName(File? file) {
  //   if (file != null) {
  //     return Container(
  //         height: 60,
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: BorderRadius.all(Radius.circular(5)),
  //         ),
  //         padding: EdgeInsets.symmetric(vertical: 16, horizontal: 5),
  //         child: Text(
  //           "File Name: ${file_name}",
  //           overflow: TextOverflow.fade,
  //           style: const TextStyle(
  //               color: Colors.purple,
  //               fontWeight: FontWeight.bold,
  //               fontSize: 17),
  //         ));
  //   } else {
  //     return const SizedBox(
  //       height: 0,
  //       width: 0,
  //     );
  //   }
  // }

  String getFileExtension(String path) {
    if (path != "") {
      final file = File(path);
      if (file.existsSync()) {
        return file.path.split('.').last;
      }
    }
    return "nothing";
  }

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
        .child('/${fileNameController.text}');

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          size: 30.0,
          color: primaryColor,
        ),
        titleTextStyle: const TextStyle(
            color: primaryColor, fontWeight: FontWeight.bold, fontSize: 18),
        centerTitle: true,
        title: const Text("Upload Files"),
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
                    fileNameController.text = bath.basename(path);
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
            Padding(
              padding: EdgeInsets.all(15),
              child: TextField(
                controller: fileNameController,
                obscureText: false,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "File Name",
                  hintText: "Enter new File Name",
                ),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "course of : ",
                  style: TextStyle(
                      color: Colors.purple,
                      fontSize: 17,
                      fontWeight: FontWeight.bold),
                ),
                DropdownButton(
                  // Initial Value
                  value: dropdownvalue,

                  // Down Arrow Icon
                  icon: const Icon(Icons.keyboard_arrow_down),

                  // Array list of items
                  items: items.map((String items) {
                    return DropdownMenuItem(
                      value: items,
                      child: Text(items),
                    );
                  }).toList(),
                  // After selecting the desired option,it will
                  // change button value to selected value
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdownvalue = newValue!;
                    });
                  },
                  style: TextStyle(color: Colors.purple),
                  dropdownColor: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () async {
                final FirebaseFirestore _firestore = FirebaseFirestore.instance;
                firebase_storage.UploadTask? task=await uploadFile(file);
                if (file != null && task!=null) {
                  await _firestore
                      .collection("Courses")
                      .doc(dropdownvalue)
                      .collection("Files")
                      .doc(fileNameController.text)
                      .set({
                    "photoUrl":currentUser!.photoUrl,
                    "username": currentUser!.username,
                    "file":fileNameController.text,
                    "uid": user!.uid,
                    "fileUrl": downloadUrl,
                    "timestamp": FieldValue.serverTimestamp(),
                  });
                }

                setState(() {
                  file_name = "";
                  file = null;
                  fileNameController.text = "";
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
                    "upload file",
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
