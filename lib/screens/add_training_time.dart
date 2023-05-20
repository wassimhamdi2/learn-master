import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddTrainingTime extends StatefulWidget {
  const AddTrainingTime({super.key});

  @override
  State<AddTrainingTime> createState() => _AddTrainingTimeState();
}

class _AddTrainingTimeState extends State<AddTrainingTime> {
  TextEditingController dateInput = TextEditingController();
  TextEditingController priceInput = TextEditingController();
  String file_name = "";
  @override
  void initState() {
    dateInput.text = ""; //set the initial value of text field
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.red.shade400,
        body: Column(children: [
          SizedBox(
            height: 100,
          ),
          Container(
              padding: EdgeInsets.all(15),
              child: TextField(
                controller: dateInput,
                //editing controller of this TextField
                decoration: InputDecoration(
                    fillColor: Colors.purple,
                    iconColor: Colors.purple,
                    hoverColor: Colors.purple,
                    focusColor: Colors.purple,
                    icon: Icon(Icons.calendar_today), //icon of text field
                    labelText: "Enter Date" //label text of field
                    ),
                readOnly: true,
                //set it true, so that user will not able to edit text
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2023),
                      //DateTime.now() - not to allow to choose before today.
                      lastDate: DateTime(2100));

                  if (pickedDate != null) {
                    print(
                        pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                    String formattedDate =
                        DateFormat('yyyy-MM-dd').format(pickedDate);
                    print(
                        formattedDate); //formatted date output using intl package =>  2021-03-16
                    setState(() {
                      dateInput.text =
                          formattedDate; //set output date to TextField value.
                    });
                  } else {}
                },
              )),
          SizedBox(
            height: 10,
          ),
          Container(
            padding: EdgeInsets.all(15),
            child: TextField(
              keyboardType: TextInputType.number,
              controller: priceInput,
              cursorColor: Colors.black,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                  fillColor: Colors.purple,
                  iconColor: Colors.purple,
                  hoverColor: Colors.purple,
                  focusColor: Colors.purple,
                  icon: Icon(Icons.attach_money), //icon of text field
                  labelText: "Enter Price" //label text of field

                  ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Text(
                  "the File selected is : ${file_name}",
                  style: const TextStyle(
                    fontSize: 20,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      color: Colors.white.withOpacity(0.5),
                      size: 24.0,
                    ),
                    SizedBox(
                      width: 15.0,
                    ),
                    Text(
                      "Add Test Times",
                      style: const TextStyle(
                          color: Colors.white60,
                          fontWeight: FontWeight.normal,
                          fontSize: 20),
                    ),
                  ],
                ),
                style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all<Size>(
                        Size(300, 50)), // set the minimum size
                    maximumSize: MaterialStateProperty.all<Size>(
                        Size(300, 50)), // set the minimum size

                    backgroundColor:
                        MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.pressed)) {
                        return Colors.black26;
                      }
                      return Colors.purple;
                    }),
                    shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)))),
              ),
            ],
          ),
        ]));
  }
}
