import 'package:flutter/material.dart';
import 'package:learn/screens/home.dart';
import '../reusable_widgets/reusable_widget.dart';
import '../ultils/colors_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LogupPage extends StatefulWidget {
  const LogupPage({super.key});

  @override
  State<LogupPage> createState() => _LogupPageState();
}

class _LogupPageState extends State<LogupPage> {
  List mail = [];
  List listMail = [];
  CollectionReference Emails =
      FirebaseFirestore.instance.collection("email validation");
  EmailVerife() async {
    QuerySnapshot querySnapshot = await Emails.get();
    List<QueryDocumentSnapshot> listdocs = querySnapshot.docs;
    listdocs.forEach((element) {
      // print("==================================");
      // print(element.data());
      setState(() {
        mail.add(element.data());
      });
    });
    // print(mail);
    mail.forEach((map) {
      // print(map['email']);
      setState(() {
        listMail.add(map['email']);
      });
    });
    // print(listMail);
  }

  sginUUp() async {
    var formdata = formKey.currentState;
    if (formdata!.validate()) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => homePage()));
    }
  }

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController _userNameTextContoller = TextEditingController();
  TextEditingController _passwordTextContoller = TextEditingController();
  TextEditingController _emailTextContoller = TextEditingController();

  @override
  void initState() {
    super.initState();
    EmailVerife();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Sign Up",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
          hexStringToColor("CB2B93"),
          hexStringToColor("9546C4"),
          hexStringToColor("5E61F4"),
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child:
            ListView(padding: EdgeInsets.fromLTRB(20, 120, 20, 0), children: [
          Form(
            key: formKey,
            child: Column(
              children: [
                Container(
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty ||
                          !RegExp(r'^[a-z A-z]+$').hasMatch(value)) {
                        return "Enter correct name";
                      } else {
                        return null;
                      }
                    },
                    controller: _userNameTextContoller,
                    obscureText: false,
                    enableSuggestions: true,
                    cursorColor: Colors.white,
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                    decoration: InputDecoration(
                      errorStyle: TextStyle( color: Colors.white54,),
                      // ignore: prefer_const_constructors
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: Colors.white70,
                      ),
                      labelText: "Enter User name",
                      labelStyle:
                          TextStyle(color: Colors.white.withOpacity(0.9)),
                      filled: true,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      fillColor: Colors.white.withOpacity(0.3),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(
                              width: 0, style: BorderStyle.none)),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                // ignore: prefer_const_constructors
                SizedBox(
                  height: 20,
                ),
                Container(
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty ||
                          !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                        return "Enter correct mail";
                      } else {
                        return null;
                      }
                    },
                    controller: _emailTextContoller,
                    obscureText: false,
                    enableSuggestions: true,
                    cursorColor: Colors.white,
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                    decoration: InputDecoration(
                      errorStyle: TextStyle( color: Colors.white54,),
                      // ignore: prefer_const_constructors
                      prefixIcon: Icon(
                        Icons.mail,
                        color: Colors.white70,
                      ),
                      labelText: "Enter Email",
                      labelStyle:
                          TextStyle(color: Colors.white.withOpacity(0.9)),
                      filled: true,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      fillColor: Colors.white.withOpacity(0.3),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(
                              width: 0, style: BorderStyle.none)),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty ||
                          !RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$%\^&\*])(?=.{8,})')
                              .hasMatch(value)) {
                        return "Enter hard Password";
                      } else {
                        return null;
                      }
                    },        
                    controller: _passwordTextContoller,
                    obscureText: true,
                    enableSuggestions: !true,
                    cursorColor: Colors.white,
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                    decoration: InputDecoration(
                      errorStyle: TextStyle( color: Colors.white54,),
                      // ignore: prefer_const_constructors
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: Colors.white70,
                      ),
                      labelText: "Enter Email",
                      labelStyle:
                          TextStyle(color: Colors.white.withOpacity(0.9)),
                      filled: true,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      fillColor: Colors.white.withOpacity(0.3),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(
                              width: 0, style: BorderStyle.none)),
                    ),
                    keyboardType: TextInputType.visiblePassword,
                  ),
                ),
                // ),
                SizedBox(
                  height: 20,
                ),
                signInSignUpButton(context, false, () {
                  sginUUp();
                  // Navigator.push(context,
                  //     MaterialPageRoute(builder: (context) => homePage()));
                }),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
