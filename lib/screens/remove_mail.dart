
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RemoveMail extends StatefulWidget {
  const RemoveMail({super.key});

  @override
  State<RemoveMail> createState() => _RemoveMailState();
}

class _RemoveMailState extends State<RemoveMail> {
  TextEditingController maill = TextEditingController();
  void deleteDoc() async {
    // Get a reference to the Firebase collection
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('email validation');

    // Query for the document where 'mail' is 'example@mail.com'
    QuerySnapshot snapshot =
        await collectionRef.where('email', isEqualTo: maill.text.toLowerCase()).get();

    // If the query returned any documents, delete the first one
    if (snapshot.docs.isNotEmpty) {
      DocumentReference docRef = snapshot.docs.first.reference;
      await docRef.delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("email deleted with success "),
          backgroundColor: Colors.blue.withOpacity(.8),
          behavior: SnackBarBehavior.floating));
      // print('Document deleted with ID: ${docRef.id}');
    } else if(maill.text == ""){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("write the email first !  "),
          backgroundColor: Colors.blue.withOpacity(.8),
          behavior: SnackBarBehavior.floating));
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("this email not found  "),
          backgroundColor: Colors.blue.withOpacity(.8),
          behavior: SnackBarBehavior.floating));
      // print('No documents found with email: example@mail.com');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            TextFormField(
              controller: maill,
              cursorColor: Colors.grey,
              // initialValue: '',
              maxLength: 20,
              decoration: InputDecoration(
                icon: Icon(Icons.mail),
                labelText: 'Mail',
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
            ElevatedButton(
              onPressed: () async {
                deleteDoc();
                maill.clear();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.delete,
                    color: Colors.purple,
                    size: 24.0,
                  ),
                  SizedBox(
                    width: 15.0,
                  ),
                  Text(
                    " Delete Mail ",
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
    );
  }
}
