import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learn/models/download.dart';

import '../reusable_widgets/Progress.dart';
import '../ultils/colors.dart';
import 'home.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  String dropdownvalue = 'Java';
  var items = [
    'Java',
    'Python',
    'Machine Learning',
    'Network',
    'Web Develepment',
  ];
  bool isLoading = false;
  List<Download> downloadPosts = [];
    @override
  void initState() {
    super.initState();
    getDownloadPosts();
  }
  getDownloadPosts() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await coursesRef
        .doc('Python')
        .collection('Files')
        .orderBy('timestamp', descending: true)
        .get();
    setState(() {
      isLoading = false;
      downloadPosts = snapshot.docs.map((doc) => Download.fromDocument(doc)).toList();
    });
  }

  builDownloadPosts() {
    // if (isLoading) {
    //   return circularProgress();
    // } else
    if (downloadPosts.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/img/noPosts.png',
              height: 260.0,
            ),
            Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Text("No Posts",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      fontSize: 22.0,
                    )))
          ],
        ),
      );
    } else {
      if (isLoading) {
        return circularProgress();
      }

      return Column(children: downloadPosts);
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
        title: const Text("Download Files"),
        backgroundColor: mobileBackgroundColor,
      ),
      body: Container(
        color: Colors.grey.withOpacity(0.2),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 90,
              child: Card(
                child: Row(
                  children: [
                    Text(
                      "course of :",
                      style: TextStyle(
                          color: Colors.purple,
                          fontSize: 17,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 10,
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
                    SizedBox(
                      width: 15.0,
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child:  Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search,
                            color: Colors.purple,
                            size: 24.0,
                          ),
                          SizedBox(
                            width: 15.0,
                          ),
                          Text(
                            "Search",
                            style: TextStyle(
                                color: Colors.purple,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                        ],
                      ),
                      style: ButtonStyle(
                          // minimumSize:
                          //     MaterialStateProperty.all<Size>(Size(100, 60)),
                          // maximumSize:
                          //     MaterialStateProperty.all<Size>(Size(100, 60)),
                          backgroundColor:
                              MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.pressed)) {
                              return Colors.black26;
                            }
                            return Colors.white;
                          }),
                          shape:
                              MaterialStatePropertyAll<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(30)))),
                    ),
                  ],
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Divider(
                    height: 0.0,
                  ),
                  builDownloadPosts(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
