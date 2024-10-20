import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:todolist/location.dart';

import '../imagepicker.dart';

class Addtask extends StatefulWidget {
  const Addtask({super.key});

  @override
  State<Addtask> createState() => _AddtaskState();
}

class _AddtaskState extends State<Addtask> {
  final _firestore = FirebaseFirestore.instance;
  File? selectedImage;
  String? title;
  String? description;
  String? downloadurl;
  bool showvalue = false;
  final titletextcontroller = TextEditingController();
  final desctextcontroller = TextEditingController();
  // This method will be passed as a callback to handle the selected image

  void _handleImageSelected(File? image) {
    if (image != null) {
      print('Image selected and uploaded!');

      setState(() {
        selectedImage = image;
        //downloadurl = downloadURL;
      });
    }
  }

  Future<String?> uploadImage(File image) async {
    try {
      String fileName = 'images/${DateTime.now().millisecondsSinceEpoch}.png';

      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      await storageRef.putFile(image);

      return await storageRef.getDownloadURL();
      //print('ulr = $downloadURL');
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  bool showmap = false;
  final locationobj = Location();
  bool showspiner = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF0A0E21),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xffB0C4DE),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: ModalProgressHUD(
          inAsyncCall: showspiner,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15, top: 5),
                  child: TextField(
                    controller: titletextcontroller,
                    maxLines: null,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Color(0xffB0C4DE),
                      hintText: 'title of  the task...',
                      hintStyle: TextStyle(color: Colors.black38),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xff101229), width: 1.0),
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xff101229), width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                    ),
                    onChanged: (value) {
                      title = value;
                    },
                  ),
                ),

                // Description field
                Padding(
                  padding: EdgeInsets.only(left: 15, right: 15, top: 20),
                  child: TextFormField(
                    controller: desctextcontroller,
                    maxLines: null,
                    style: TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Color(0xffB0C4DE),
                      hintText: 'Description...',
                      hintStyle: TextStyle(color: Colors.black38),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 50.0, horizontal: 20.0),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xff101229), width: 1.0),
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xff101229), width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                    ),
                    onChanged: (value) {
                      description = value;
                    },
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                //button rows
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () async {
                          await locationobj.getCurrentLocation();
                          setState(() {
                            showvalue = true;
                          });

                          print(locationobj.latitude);
                        },
                        child: const Icon(
                          Icons.near_me,
                          size: 50,
                          color: Color(0xffB0C4DE),
                        )),
                    const SizedBox(
                      width: 50,
                    ),
                    TextButton(
                      onPressed: () {
                        showPickerDialog(context, _handleImageSelected);
                      },
                      child: const Icon(
                        Icons.add_a_photo_outlined,
                        size: 50,
                        color: Color(0xffB0C4DE),
                      ),
                    ),
                  ],
                ),

                SizedBox(
                  height: 20,
                ),

                // display container
                Container(
                  height: 350,
                  width: 350,
                  color: Color(0xffB0C4DE),
                  child: Column(
                    children: [
                      showvalue
                          ? Text(
                              'latitude: ${locationobj.latitude}\nlongitude: ${locationobj.longitude}',
                              style: const TextStyle(
                                  fontSize: 20,
                                  //fontWeight: FontWeight.bold,
                                  color: Colors.black54),
                            )
                          : SizedBox.shrink(),
                      const SizedBox(
                        height: 50,
                      ),
                      selectedImage == null
                          ? const Text('Add location & Upload the image*',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ))
                          : Image.file(
                              selectedImage!,
                              height: 230,
                            ),
                    ],
                  ),
                ),

                TextButton.icon(
                  onPressed: () async {
                    titletextcontroller.clear();
                    desctextcontroller.clear();

                    setState(() {
                      showspiner = true;
                    });

                    if (selectedImage != null) {
                      downloadurl = await uploadImage(selectedImage!);
                      _firestore.collection('tasks').add({
                        'title': title,
                        'description': description,
                        'location': GeoPoint(locationobj.latitude ?? 0.0,
                            locationobj.longitude ?? 0.0),
                        'image': downloadurl
                      });
                      Navigator.pop(context);

                      setState(() {
                        showvalue = false;
                        selectedImage = null;
                        showspiner = false;
                      });
                    } else {
                      setState(() {
                        showspiner = false;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(' upload an image before saving.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  label: const Text(
                    'Save',
                    style: TextStyle(
                      color: Color(0xffB0C4DE),
                      fontWeight: FontWeight.bold,
                      fontSize: 30.0,
                    ),
                  ),
                  icon: const Icon(
                    size: 40,
                    Icons.save,
                    color: Color(0xffB0C4DE),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
