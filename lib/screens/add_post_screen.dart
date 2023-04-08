import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:learn/reusable_widgets/Progress.dart';
import 'package:learn/screens/home.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';
import '../models/user.dart';

class AddPostScreen extends StatefulWidget {
  final User? currentUser;
  const AddPostScreen({required this.currentUser});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  TextEditingController locationControler = TextEditingController();
  TextEditingController captionControler = TextEditingController();
  File? file;
  bool isUploading = false;
  String postId = Uuid().v4();

  handleChooseFromGallery() async {
    Navigator.pop(context);
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    setState(() {
      file = pickedFile != null ? File(pickedFile.path) : null;
    });
  }

  handleTakePhoto() async {
    Navigator.pop(context);
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      file = pickedFile != null ? File(pickedFile.path) : null;
    });
  }

  selectImage(parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text("Create post"),
            children: [
              SimpleDialogOption(
                child: Text("Photo with Camera"),
                onPressed: handleTakePhoto,
              ),
              SimpleDialogOption(
                child: Text("Image from Gallery"),
                onPressed: handleChooseFromGallery,
              ),
              SimpleDialogOption(
                child: Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }

  Container buildSplashScreen() {
    return Container(
      color: Colors.blue.withOpacity(0.7),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/img/upload.png',
            height: 260.0,
          ),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.deepOrange),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              child: Text("Upload Image",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.0,
                  )),
              onPressed: () => selectImage(context),
            ),
          )
        ],
      ),
    );
  }

  clearImage() {
    setState(() {
      file = null;
    });
  }

  compressImage() async {
    final tempDit = await getTemporaryDirectory();
    final path = tempDit.path;
    Im.Image? imageFile = Im.decodeImage(file!.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile!, quality: 85));
    setState(() {
      file = compressedImageFile;
    });
  }

  Future<String> uploadImage(File imageFile) async {
    UploadTask uploadTask =
        storageRef.child("post_$postId.jpg").putFile(imageFile);
    TaskSnapshot storageSnap = await uploadTask.whenComplete(() => null);
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  createPostInFirebase(String mediaUrl, String location, String description) {
    postsRef
        .doc(widget.currentUser?.uid)
        .collection("userPosts")
        .doc(postId)
        .set({
      "postId": postId,
      "ownerId": widget.currentUser!.uid,
      "username": widget.currentUser!.username,
      "mediaUrl": mediaUrl,
      "description": description,
      "location": location,
      "timestamp": timestamp,
      "likes": {},
    });
  }

  handelSubmit() async {
    setState(() {
      isUploading = true;
    });
    await compressImage();
    String mediaUrl = await uploadImage(file!);
    createPostInFirebase(
        mediaUrl, locationControler.text, captionControler.text);
    captionControler.clear();
    locationControler.clear();
    setState(() {
      file = null;
      isUploading = false;
      postId = Uuid().v4();
    });
  }

  Scaffold buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white70,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: clearImage,
        ),
        title: Text("Caption post", style: TextStyle(color: Colors.black)),
        actions: [
          TextButton(
            onPressed: isUploading ? null : () => handelSubmit(),
            child: Text(
              "post",
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          )
        ],
      ),
      body: ListView(
        children: [
          isUploading ? linearProgress() : Text(""),
          Container(
            height: 220.0,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    fit: BoxFit.contain,
                    image: FileImage(file!),
                  )),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider(widget.currentUser!.photoUrl),
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: captionControler,
                decoration: InputDecoration(
                  hintText: "write a caption ... ",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.pin_drop, color: Colors.orange, size: 35.0),
            title: Container(
              width: 250,
              child: TextField(
                  controller: locationControler,
                  decoration: InputDecoration(
                    hintText: "where was this photo taken?",
                    border: InputBorder.none,
                  )),
            ),
          ),
          Container(
            width: 200.0,
            height: 100.0,
            alignment: Alignment.center,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.withOpacity(0.8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              icon: Icon(Icons.my_location),
              label: Text("Use Current Location"),
              onPressed: getUserLocation,
            ),
          ),
        ],
      ),
    );
  }

  getUserLocation() async{
    // await Geolocator.checkPermission();
    await Geolocator.requestPermission();
   Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high );
   List<Placemark> placemarks = await placemarkFromCoordinates(
    position.latitude,
    position.longitude,
  );
  Placemark placemark = placemarks.first;
 String formattedAddress = "${placemark.locality} , ${placemark.country}";
 locationControler.text=formattedAddress;
  }

  @override
  Widget build(BuildContext context) {
    return file == null ? buildSplashScreen() : buildUploadForm();
  }
}
