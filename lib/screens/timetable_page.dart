import 'package:flutter/material.dart';
import 'package:learn/models/timetable.dart';
import 'package:learn/screens/home.dart';
import '../reusable_widgets/Progress.dart';
import '../ultils/colors.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
  }


  Widget buildTimetable() {
    return StreamBuilder(
      stream: eventRef.doc("timetable").collection("allFiles").snapshots(),
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
                child: Text("No TimeTables",
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
        List<TimeTable> TimeTables = [];
        snapshot.data?.docs.forEach((doc) {
          TimeTables.add(TimeTable.fromDocument(doc));
          print(TimeTables);
        });
        return Column(
          children: TimeTables,
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
          title: Text("TimeTable"),
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
