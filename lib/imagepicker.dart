import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

File? selectedimage;

Future pickImageFromGallery() async {
  final returedimage =
      await ImagePicker().pickImage(source: ImageSource.gallery);
  if (returedimage == null) return;

  return File(returedimage.path);
}

Future pickImageFromcamera() async {
  final returedimage =
      await ImagePicker().pickImage(source: ImageSource.camera);
  if (returedimage == null) return;
  return File(returedimage.path);
}

Future<void> showPickerDialog(
    BuildContext context, Function(File?) onImageSelected) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Choose Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () async {
                Navigator.of(context).pop();
                File? image = await pickImageFromGallery();
                onImageSelected(image);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.of(context).pop();
                File? image = await pickImageFromcamera();
                onImageSelected(image);
              },
            ),
          ],
        ),
      );
    },
  );
}
