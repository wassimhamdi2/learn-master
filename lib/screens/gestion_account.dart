import 'package:flutter/material.dart';
import 'package:learn/screens/add_mail.dart';
import 'package:learn/screens/remove_mail.dart';

import '../ultils/colors.dart';
import 'Home.dart';

class PageViewDemo extends StatefulWidget {
  const PageViewDemo({Key? key}) : super(key: key);

  @override
  State<PageViewDemo> createState() => _PageViewDemoState();
}

class _PageViewDemoState extends State<PageViewDemo> {
  final _controller = PageController(initialPage: 0);
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handlePageViewPageChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_handlePageViewPageChanged);
    _controller.dispose();
    super.dispose();
  }

  void _handlePageViewPageChanged() {
    setState(() {
      _currentPageIndex = _controller.page!.round();
    });
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
        title: _currentPageIndex == 0
            ? Text('add mail to DB')
            : Text('Delete mail from DB'),
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
        actions: [
          IconButton(
            icon: Icon(Icons.keyboard_arrow_left),
            onPressed: () {
              _controller.previousPage(
                  duration: Duration(seconds: 1), curve: Curves.easeInOut);
            },
          ),
          IconButton(
            icon: Icon(Icons.keyboard_arrow_right),
            onPressed: () {
              _controller.nextPage(
                  duration: Duration(seconds: 1), curve: Curves.easeInOut);
            },
          ),
        ],
      ),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _controller,
        children: [
          AddMail(),
          RemoveMail(),
        ],
      ),
    );
  }
}
