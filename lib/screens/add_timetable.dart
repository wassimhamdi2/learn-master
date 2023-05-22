import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'home.dart';

class AddTimeTable extends StatefulWidget {
  const AddTimeTable({super.key});

  @override
  State<AddTimeTable> createState() => _AddTimeTableState();
}

class _AddTimeTableState extends State<AddTimeTable> {
  // define a list of options for the dropdown
  final List<String> _class = ["LSI1", "LSI2", "LS3", "M1", "M2"];
  final List<String> _Section = ["IM", "GL", "-"];
  final List<String> _TD = ["TD1", "TD2", "TD3", "TD4"];
  final List<String> _TP = ["TP1", "TP2", "TP3", "TP4"];

  // the selected value
  String? _selectedClass;
  String? _selectedTD;
  String? _selectedTP;
  String? _selectedSection;

  File? file;
  String file_name = "";
  String postId = "";

  Future<String> uploadFile(File file, String Postid) async {
    firebase_storage.UploadTask uploadTask;
    // Create a Reference to the file
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('Event')
        .child('/imageOf${Postid}');
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //     content: Text("Uploading..!"),
    //     backgroundColor: Colors.blue.withOpacity(.8),
    //     behavior: SnackBarBehavior.floating));
    // print("Uploading..!");
    uploadTask = ref.putFile(file);
    TaskSnapshot storageSnap = await uploadTask.whenComplete(() => null);
    String url = await storageSnap.ref.getDownloadURL();
    //afficher done when upload finish
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //     content: Text("done"),
    //     backgroundColor: Colors.blue.withOpacity(.8),
    //     behavior: SnackBarBehavior.floating));
    return url;
  }

  postTimetable() async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Uploading..!"),
        backgroundColor: Colors.blue.withOpacity(.8),
        behavior: SnackBarBehavior.floating));
    String mediaUrl = "";
    postId = randomAlphaNumeric(16);

    mediaUrl = await uploadFile(file!, postId);
    eventRef.doc("timetable").collection("allFiles").doc(postId).set({
      "postId": postId,
      "mediaUrl": mediaUrl,
      "section": _selectedSection,
      "classs": _selectedClass,
      "td": _selectedTD,
      "tp": _selectedTP,
    });

    setState(() {
      file_name = '';
      file = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Column(children: [
        SizedBox(
          height: 100,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              width: 300,
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(30)),
              child: DropdownButton<String>(
                value: _selectedClass,
                onChanged: (value) {
                  setState(() {
                    _selectedClass = value;
                  });
                },
                hint: const Center(
                    child: Text(
                  'Select the Class',
                  style: TextStyle(color: Colors.white),
                )),
                // Hide the default underline
                underline: Container(),
                // set the color of the dropdown menu
                dropdownColor: Colors.amber,
                icon: const Icon(
                  Icons.arrow_downward,
                  color: Colors.yellow,
                ),
                isExpanded: true,

                // The list of options
                items: _class
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              e,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ))
                    .toList(),

                // Customize the selected item
                selectedItemBuilder: (BuildContext context) => _class
                    .map((e) => Center(
                          child: Text(
                            e,
                            style: const TextStyle(
                                fontSize: 18,
                                color: Colors.amber,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              width: 300,
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(30)),
              child: DropdownButton<String>(
                value: _selectedTD,
                onChanged: (value) {
                  setState(() {
                    _selectedTD = value;
                  });
                },
                hint: const Center(
                    child: Text(
                  'Select the TD',
                  style: TextStyle(color: Colors.white),
                )),
                // Hide the default underline
                underline: Container(),
                // set the color of the dropdown menu
                dropdownColor: Colors.amber,
                icon: const Icon(
                  Icons.arrow_downward,
                  color: Colors.yellow,
                ),
                isExpanded: true,

                // The list of options
                items: _TD
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              e,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ))
                    .toList(),

                // Customize the selected item
                selectedItemBuilder: (BuildContext context) => _TD
                    .map((e) => Center(
                          child: Text(
                            e,
                            style: const TextStyle(
                                fontSize: 18,
                                color: Colors.amber,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              width: 300,
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(30)),
              child: DropdownButton<String>(
                value: _selectedTP,
                onChanged: (value) {
                  setState(() {
                    _selectedTP = value;
                  });
                },
                hint: const Center(
                    child: Text(
                  'Select the TP',
                  style: TextStyle(color: Colors.white),
                )),
                // Hide the default underline
                underline: Container(),
                // set the color of the dropdown menu
                dropdownColor: Colors.amber,
                icon: const Icon(
                  Icons.arrow_downward,
                  color: Colors.yellow,
                ),
                isExpanded: true,

                // The list of options
                items: _TP
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              e,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ))
                    .toList(),

                // Customize the selected item
                selectedItemBuilder: (BuildContext context) => _TP
                    .map((e) => Center(
                          child: Text(
                            e,
                            style: const TextStyle(
                                fontSize: 18,
                                color: Colors.amber,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              width: 300,
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(30)),
              child: DropdownButton<String>(
                value: _selectedSection,
                onChanged: (value) {
                  setState(() {
                    _selectedSection = value;
                  });
                },
                hint: const Center(
                    child: Text(
                  'Select the Section',
                  style: TextStyle(color: Colors.white),
                )),
                // Hide the default underline
                underline: Container(),
                // set the color of the dropdown menu
                dropdownColor: Colors.amber,
                icon: const Icon(
                  Icons.arrow_downward,
                  color: Colors.yellow,
                ),
                isExpanded: true,

                // The list of options
                items: _Section.map((e) => DropdownMenuItem(
                      value: e,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          e,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    )).toList(),

                // Customize the selected item
                selectedItemBuilder: (BuildContext context) =>
                    _Section.map((e) => Center(
                          child: Text(
                            e,
                            style: const TextStyle(
                                fontSize: 18,
                                color: Colors.amber,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold),
                          ),
                        )).toList(),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        ElevatedButton(
          onPressed: () async {
            final pickedFile = await ImagePicker().pickImage(
              source: ImageSource.gallery,
            );
            setState(() {
              file = pickedFile != null ? File(pickedFile.path) : null;
              if (pickedFile != null) {
                file_name = path.basename(pickedFile.path);
              }
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.done,
                color: Colors.white,
                size: 24.0,
              ),
              SizedBox(
                width: 15.0,
              ),
              Text(
                "select file",
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                    fontSize: 20),
              ),
            ],
          ),
          style: ButtonStyle(
              minimumSize: MaterialStateProperty.all<Size>(
                  Size(300, 50)), // set the minimum size
              maximumSize: MaterialStateProperty.all<Size>(
                  Size(300, 50)), // set the minimum size

              backgroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.pressed)) {
                  return Colors.black26;
                }
                return Colors.purple;
              }),
              shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)))),
        ),
        SizedBox(
          height: 20,
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Text(
                "the File selected is : ${file_name}",
                style: const TextStyle(
                  fontSize: 20,
                  overflow: TextOverflow.ellipsis,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                if (file == null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("No File !! select file please "),
                      backgroundColor: Colors.blue.withOpacity(0.8),
                      behavior: SnackBarBehavior.floating));
                  // debugPrint("not file bro");
                }
                 else if (_selectedSection == null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Select Section please "),
                      backgroundColor: Colors.blue.withOpacity(0.8),
                      behavior: SnackBarBehavior.floating));}
                 else if (_selectedClass == null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Select class please"),
                      backgroundColor: Colors.blue.withOpacity(0.8),
                      behavior: SnackBarBehavior.floating));
                } 
                 else if (_selectedTD == null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Select TD please"),
                      backgroundColor: Colors.blue.withOpacity(0.8),
                      behavior: SnackBarBehavior.floating));
                } 
                 else if (_selectedTP == null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Select TP please"),
                      backgroundColor: Colors.blue.withOpacity(0.8),
                      behavior: SnackBarBehavior.floating));
                } 
                else {
                  postTimetable();
                  //afficher done when upload finish
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("done"),
                      backgroundColor: Colors.blue.withOpacity(0.8),
                      behavior: SnackBarBehavior.floating));
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 24.0,
                  ),
                  SizedBox(
                    width: 15.0,
                  ),
                  Text(
                    "Add Timetable",
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                        fontSize: 20),
                  ),
                ],
              ),
              style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all<Size>(
                      Size(300, 50)), // set the minimum size
                  maximumSize: MaterialStateProperty.all<Size>(
                      Size(300, 50)), // set the minimum size

                  backgroundColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.pressed)) {
                      return Colors.black26;
                    }
                    return Colors.purple;
                  }),
                  shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)))),
            ),
          ],
        )
      ]),
    );
  }
}
