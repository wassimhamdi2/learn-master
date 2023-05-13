import 'package:flutter/material.dart';
import 'package:learn/screens/gestion_account.dart';

import '../ultils/colors.dart';
import 'Home.dart';

class checkIfAdmin extends StatefulWidget {
  const checkIfAdmin({super.key});

  @override
  State<checkIfAdmin> createState() => _checkIfAdminState();
}

class _checkIfAdminState extends State<checkIfAdmin> {
  Widget buildUploadButton() {
    bool isprofileOwner = currentUser!.role.toString() == "admin";
    if (isprofileOwner) {
      return Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => PageViewDemo()));
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.next_plan,
                color: Colors.purple,
                size: 24.0,
              ),
              // SizedBox(
              //   width: 15.0,
              // ),
              // Text(
              //   "Upload Courses",
              //   style: const TextStyle(
              //       color: Colors.purple,
              //       fontWeight: FontWeight.bold,
              //       fontSize: 20),
              // ),
            ],
          ),
          style: ButtonStyle(
              minimumSize: MaterialStateProperty.all<Size>(Size(90, 60)),
              maximumSize: MaterialStateProperty.all<Size>(Size(100, 60)),
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
      return Center(
          child: Text(
        "Sorry you are not Admin ",
        style: TextStyle(
            fontSize: 20, color: Colors.purple, fontWeight: FontWeight.bold),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            size: 30.0,
            color: primaryColor,
          ),
          titleTextStyle: TextStyle(
              color: primaryColor, fontWeight: FontWeight.bold, fontSize: 18),
          centerTitle: true,
          title: Text('Accounts Managment'),
          backgroundColor: mobileBackgroundColor,
          leading: IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
          ),
        ),
        body: Container(
          color: Colors.grey.withOpacity(0.2),
          child: buildUploadButton(),
        ));
  }
}
