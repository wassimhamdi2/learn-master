import 'package:flutter/material.dart';
import 'package:learn/screens/add_question.dart';
import 'package:random_string/random_string.dart';
import '../services/database.dart';
import '../ultils/colors.dart';
import 'Home.dart';


class CreateQuiz extends StatefulWidget {


  @override
  _CreateQuizState createState() => _CreateQuizState();
}

class _CreateQuizState extends State<CreateQuiz> {

  DatabaseService databaseService =  DatabaseService();
  final _formKey = GlobalKey<FormState>();

  String quizImgUrl="", quizTitle="", quizDesc="";

  bool isLoading = false;
  String quizId="";


  createQuiz(){

    quizId = randomAlphaNumeric(16);
    if(_formKey.currentState!.validate()){

      setState(() {
        isLoading = true;
      });

      Map<String, String> quizData = {
        "quizImgUrl" : quizImgUrl,
        "quizTitle" : quizTitle,
        "quizDesc" : quizDesc
      };

      databaseService.addQuizData(quizData, quizId).then((value){
        setState(() {
          isLoading = false;
        });
        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) =>  AddQuestion(quizId)
        ));
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          "Create Quiz",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: mobileBackgroundColor,
      ),
      body: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
            TextFormField(
              validator: (val) => val!.isEmpty ? "Enter Quiz Image Url" : null,
              decoration: InputDecoration(
                hintText: "Quiz Image Url (Optional)"
              ),
              onChanged: (val){
                quizImgUrl = val;
              },
            ),
            SizedBox(height: 5,),
            TextFormField(
              validator: (val) => val!.isEmpty ? "Enter Quiz Title" : null,
              decoration: InputDecoration(
                hintText: "Quiz Title"
              ),
              onChanged: (val){
                quizTitle = val;
              },
            ),
            SizedBox(height: 5,),
            TextFormField(
              validator: (val) => val!.isEmpty ? "Enter Quiz Description" : null,
              decoration: InputDecoration(
                  hintText: "Quiz Description"
              ),
              onChanged: (val){
               quizDesc = val;
              },
            ),
              Spacer(),
              GestureDetector(
                onTap: () {
                  createQuiz();
                },
                child: Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(
                      horizontal: 24, vertical: 20),
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(30)),
                  child: Text(
                    "Create Quiz",
                    style: TextStyle(
                        fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(
                height: 60,
              ),
          ],)
          ,),
      ),
    );
  }
}
