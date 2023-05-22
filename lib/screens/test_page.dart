import 'package:flutter/material.dart';
import 'package:learn/models/test.dart';
import 'package:learn/screens/home.dart';
import '../reusable_widgets/Progress.dart';
import '../ultils/colors.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
  }


  Widget buildTimetable() {
    return StreamBuilder(
      stream: eventRef.doc("test").collection("allFiles").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.data?.docs.length == 0) {
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
                child: Text("No Test",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      fontSize: 22.0,
                    )))
          ],
        ),
      );
        }
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<Test> Tests = [];
        snapshot.data?.docs.forEach((doc) {
          Tests.add(Test.fromDocument(doc));
          print(Tests);
        });
        return Column(
          children: Tests,
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade200,
        appBar: AppBar(
          iconTheme: IconThemeData(
            size: 30.0,
            color: primaryColor,
          ),
          titleTextStyle: TextStyle(
              color: primaryColor, fontWeight: FontWeight.bold, fontSize: 18),
          centerTitle: true,
          title: Text("Test"),
          backgroundColor: mobileBackgroundColor,
        ),
        body: Container(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Divider(
                  height: 0.0,
                ),
                buildTimetable(),
              ],
            ),
          ),
        ));
  }
}
