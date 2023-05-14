import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddMail extends StatefulWidget {
  const AddMail({super.key});

  @override
  State<AddMail> createState() => _AddMailState();
}

class _AddMailState extends State<AddMail> {
  List<String> roleChoose = ["admin", "enseignant", "etudiant"];
  TextEditingController maill = TextEditingController();
  TextEditingController rolee = TextEditingController();
  void createCollection(String role, String mail) async {
    // Get a reference to the Firebase collection
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('email validation');

    // Create a new document with a random ID
    DocumentReference docRef = collectionRef.doc();

    // Set the data for the new document
    await docRef.set({
      'email': mail,
      'role': role,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Container(
        
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: maill,
                cursorColor: Colors.grey,
                // initialValue: '',
                maxLength: 20,
                decoration: InputDecoration(
                  icon: Icon(Icons.mail),
                  labelText: 'New Mail',
                  labelStyle: TextStyle(
                    color: Color(0xFF6200EE),
                  ),
                  helperText: 'Lettre N°',
                  // suffixIcon: Icon(
                  //   Icons.check_circle,
                  // ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6200EE)),
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              TextFormField(
                controller: rolee,
                cursorColor: Colors.grey,
                // initialValue: '',
                maxLength: 20,
                decoration: InputDecoration(
                  icon: Icon(Icons.work),
                  labelText: 'Role',
                  labelStyle: TextStyle(
                    color: Color(0xFF6200EE),
                  ),
                  helperText: 'Lettre N°',
                  // suffixIcon: Icon(
                  //   Icons.check_circle,
                  // ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6200EE)),
                  ),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              ElevatedButton(
                onPressed: () async {
                  if (maill.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("write the email first !  "),
                        backgroundColor: Colors.blue.withOpacity(.8),
                        behavior: SnackBarBehavior.floating));
                  } else if (roleChoose.contains(rolee.text.toLowerCase())) {
                    createCollection(
                        rolee.text.toLowerCase(), maill.text.toLowerCase());
                    rolee.clear();
                    maill.clear();
        
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("email added"),
                        backgroundColor: Colors.blue.withOpacity(.8),
                        behavior: SnackBarBehavior.floating));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Role isn't correct ! Check it please "),
                        backgroundColor: Colors.blue.withOpacity(.8),
                        behavior: SnackBarBehavior.floating));
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      color: Colors.purple,
                      size: 24.0,
                    ),
                    SizedBox(
                      width: 15.0,
                    ),
                    Text(
                      " Add Mail ",
                      style: const TextStyle(
                          color: Colors.purple,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ],
                ),
                style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all<Size>(
                        Size(200, 50)), // set the minimum size
                    maximumSize: MaterialStateProperty.all<Size>(
                        Size(200, 50)), // set the minimum size
        
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
              
            ],
          ),
        ),
      ),
    );
  }
}
