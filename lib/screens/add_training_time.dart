import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'home.dart';

class AddTrainingTime extends StatefulWidget {
  const AddTrainingTime({super.key});

  @override
  State<AddTrainingTime> createState() => _AddTrainingTimeState();
}

class _AddTrainingTimeState extends State<AddTrainingTime> {
  TextEditingController dateInput = TextEditingController();
  TextEditingController priceInput = TextEditingController();
  String file_name = "";
  String postId = "";
  File? file;

  @override
  void initState() {
    dateInput.text = ""; //set the initial value of text field
    super.initState();
  }

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
    eventRef.doc("training").collection("allFiles").doc(postId).set({
      "postId": postId,
      "mediaUrl": mediaUrl,
      "date": dateInput.text,
      "price": priceInput.text,
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Done"),
        backgroundColor: Colors.blue.withOpacity(.8),
        behavior: SnackBarBehavior.floating));

    setState(() {
      file_name = '';
      file = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.red.shade400,
        body: SingleChildScrollView(
          child: Column(children: [
            SizedBox(
              height: 100,
            ),
            Container(
                padding: EdgeInsets.all(15),
                child: TextField(
                  controller: dateInput,
                  //editing controller of this TextField
                  decoration: InputDecoration(
                      fillColor: Colors.purple,
                      iconColor: Colors.purple,
                      hoverColor: Colors.purple,
                      focusColor: Colors.purple,
                      icon: Icon(Icons.calendar_today), //icon of text field
                      labelText: "Enter Date" //label text of field
                      ),
                  readOnly: true,
                  //set it true, so that user will not able to edit text
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2023),
                        //DateTime.now() - not to allow to choose before today.
                        lastDate: DateTime(2100));
        
                    if (pickedDate != null) {
                      print(
                          pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                      String formattedDate =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                      print(
                          formattedDate); //formatted date output using intl package =>  2021-03-16
                      setState(() {
                        dateInput.text =
                            formattedDate; //set output date to TextField value.
                      });
                    } else {}
                  },
                )),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.all(15),
              child: TextField(
                keyboardType: TextInputType.number,
                controller: priceInput,
                cursorColor: Colors.black,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    fillColor: Colors.purple,
                    iconColor: Colors.purple,
                    hoverColor: Colors.purple,
                    focusColor: Colors.purple,
                    icon: Icon(Icons.attach_money), //icon of text field
                    labelText: "Enter Price" //label text of field
        
                    ),
              ),
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
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 30,
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
                    } else if (priceInput == "") {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Select Section please "),
                          backgroundColor: Colors.blue.withOpacity(0.8),
                          behavior: SnackBarBehavior.floating));
                    } else if (dateInput == "") {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Select class please"),
                          backgroundColor: Colors.blue.withOpacity(0.8),
                          behavior: SnackBarBehavior.floating));
                    } else {
                      postTimetable();
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        color: Colors.white.withOpacity(0.5),
                        size: 24.0,
                      ),
                      SizedBox(
                        width: 15.0,
                      ),
                      Text(
                        "Add training ",
                        style: const TextStyle(
                            color: Colors.white60,
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
        
                      backgroundColor:
                          MaterialStateProperty.resolveWith((states) {
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
            ),
          ]),
        ));
  }
}
