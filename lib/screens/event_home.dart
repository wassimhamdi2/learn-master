import 'package:flutter/material.dart';

import '../ultils/colors.dart';
import 'home.dart';

class EventHome extends StatefulWidget {
  const EventHome({super.key});

  @override
  State<EventHome> createState() => _EventHomeState();
}

class _EventHomeState extends State<EventHome> {
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
          title: Text("Event"),
          backgroundColor: mobileBackgroundColor,
        ),
    );
  }
}