import 'package:flutter/material.dart';
import 'package:learn/screens/Home.dart';
import 'package:learn/screens/download_page.dart';
import 'package:learn/screens/upload_page.dart';
import '../ultils/colors.dart';
import '../ultils/colors_utils.dart';

class CourseHome extends StatefulWidget {
  const CourseHome({super.key});

  @override
  State<CourseHome> createState() => _CourseHomeState();
}

class _CourseHomeState extends State<CourseHome> {
  @override
  void initState() {
    super.initState();
  }

  Widget buildUploadButton() {
    bool isprofileOwner = currentUser!.role.toString() == "etudiant";
    if (isprofileOwner) {
      return Padding(
        padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => UploadPage()));
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
                "Upload Courses",
                style: const TextStyle(
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ],
          ),
          style: ButtonStyle(
              minimumSize: MaterialStateProperty.all<Size>(Size(300, 60)),
              maximumSize: MaterialStateProperty.all<Size>(Size(300, 60)),
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
      );
    } else {
      return Text("");
    }
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
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
          ),
          iconTheme: IconThemeData(
            size: 30.0,
            color: primaryColor,
          ),
          titleTextStyle: TextStyle(
              color: primaryColor, fontWeight: FontWeight.bold, fontSize: 18),
          centerTitle: true,
          title: Text("courses"),
          backgroundColor: mobileBackgroundColor,
        ),
        body: Container(
            width: double.infinity,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              hexStringToColor("CB2B93"),
              hexStringToColor("9546C4"),
              hexStringToColor("5E61F4"),
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildUploadButton(),

                Padding(
                  padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DownloadPage()));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.download,
                          color: Colors.purple,
                          size: 24.0,
                        ),
                        SizedBox(
                          width: 15.0,
                        ),
                        Text(
                          "Download Courses",
                          style: const TextStyle(
                              color: Colors.purple,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ],
                    ),
                    style: ButtonStyle(
                        minimumSize:
                            MaterialStateProperty.all<Size>(Size(300, 60)),
                        maximumSize:
                            MaterialStateProperty.all<Size>(Size(300, 60)),
                        backgroundColor:
                            MaterialStateProperty.resolveWith((states) {
                          if (states.contains(MaterialState.pressed)) {
                            return Colors.black26;
                          }
                          return Colors.white;
                        }),
                        shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)))),
                  ),
                )
                // Padding(
                //   padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
                //   child: ElevatedButton(
                //     onPressed: () {
                //       Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //               builder: (context) =>DownloadPage()));
                //     },
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       children: [
                //         Icon(
                //           Icons.file_download,
                //           color: Colors.purple,
                //           size: 24.0,
                //         ),
                //         SizedBox(
                //           width: 15.0,
                //         ),
                //         Text(
                //           "Download Courses",
                //           style: const TextStyle(
                //               color: Colors.purple,
                //               fontWeight: FontWeight.bold,
                //               fontSize: 20),
                //         ),
                //       ],
                //     ),
                //     style: ButtonStyle(
                //         minimumSize: MaterialStateProperty.all<Size>(
                //             Size(300, 60)), // set the minimum size
                //         maximumSize: MaterialStateProperty.all<Size>(
                //             Size(300, 60)), // set the minimum size

                //         backgroundColor:
                //             MaterialStateProperty.resolveWith((states) {
                //           if (states.contains(MaterialState.pressed)) {
                //             return Colors.black26;
                //           }
                //           return Colors.white;
                //         }),
                //         shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
                //             RoundedRectangleBorder(
                //                 borderRadius: BorderRadius.circular(30)))),
                //   ),
                // ),
              ],
            )));
  }
}
