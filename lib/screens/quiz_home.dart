import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learn/screens/quiz_play.dart';

import '../services/database.dart';
import '../ultils/colors.dart';
import 'Home.dart';
import 'create_quiz.dart';

class HomeQuiz extends StatefulWidget {
  @override
  _HomeQuizState createState() => _HomeQuizState();
}

class _HomeQuizState extends State<HomeQuiz> {
  Stream<QuerySnapshot<Map<String, dynamic>>>? quizStream;
  DatabaseService databaseService = DatabaseService();

  Widget quizList() {
    return Container(
      child: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: quizStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  return QuizTile(
                    noOfQuestions: snapshot.data!.docs.length,
                    imageUrl: snapshot.data!.docs[index].get('quizImgUrl'),
                    title: snapshot.data!.docs[index].get('quizTitle'),
                    description: snapshot.data!.docs[index].get('quizDesc'),
                    id: snapshot.data!.docs[index].id,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    debugPrint("${currentUser!.role}");
    databaseService.getQuizData().then((value) {
      quizStream = value;
      setState(() {});
    });
    super.initState();
  }

  Widget floatb() {
    bool isAdmin = currentUser!.role.toString() == "enseignant" ||
        currentUser!.role.toString() == "admin";
    if (isAdmin) {
      return  FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => CreateQuiz()));
        },
      );
    } else {
      return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
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
        iconTheme: const IconThemeData(
          size: 30.0,
          color: primaryColor,
        ),
        titleTextStyle: const TextStyle(
            color: primaryColor, fontWeight: FontWeight.bold, fontSize: 18),
        centerTitle: true,
        title: const Text(
          "Quiz Home",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: mobileBackgroundColor,
      ),
      body: quizList(),
      floatingActionButton:floatb()
      // floatingActionButton: FloatingActionButton(
      //   child: Icon(Icons.add),
      //   onPressed: () {
      //     Navigator.push(
      //         context, MaterialPageRoute(builder: (context) => CreateQuiz()));
      //   },
      // ),
    );
  }
}

class QuizTile extends StatelessWidget {
  final String imageUrl, title, id, description;
  final int noOfQuestions;

  QuizTile(
      {required this.title,
      required this.imageUrl,
      required this.description,
      required this.id,
      required this.noOfQuestions});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        bool isAdmin = currentUser!.role.toString() == "enseignant"||currentUser!.role.toString()=="admin";
        if (isAdmin){
        showDialog(
            context: context,
            builder: (context) {
              return SimpleDialog(
                title: Text("did you want delete quiz"),
                children: [
                  SimpleDialogOption(
                    child: Text("delete quiz"),
                    onPressed: () {
                      final docRef =
                          FirebaseFirestore.instance.collection('Quiz').doc(id);

// Check if the document exists
                      docRef.get().then((doc) {
                        if (doc.exists) {
                          // Delete the document
                          docRef.delete().then((value) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("Quiz deleted successfully"),
                                backgroundColor: Colors.blue.withOpacity(.8),
                                behavior: SnackBarBehavior.floating));
                            // print('Document deleted successfully');
                          }).catchError((error) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("Failed to delete Quiz: $error"),
                                backgroundColor: Colors.blue.withOpacity(.8),
                                behavior: SnackBarBehavior.floating));
                            // print('Failed to delete Quiz: $error');
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Quiz does not exist"),
                              backgroundColor: Colors.blue.withOpacity(.8),
                              behavior: SnackBarBehavior.floating));
                          // print('Quiz does not exist');
                        }
                      });
                    },
                  ),
                  SimpleDialogOption(
                    child: Text("Cancel"),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              );
            });
      }
      },
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => QuizPlay(id)));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24),
        height: 150,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width,
              ),
              Container(
                color: Colors.black45,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        description,
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w500),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
