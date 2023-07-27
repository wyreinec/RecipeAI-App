import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';

import 'package:recipeai_app/loadingscreen.dart';

class ImagePreviewScreen extends StatelessWidget {
  final String imagePath;

  ImagePreviewScreen({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Image Preview'),
      //   backgroundColor: Color(0xFF0C8B19),
      // ),
      body: Center(
        child: Image.file(
          File(imagePath),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          fit: BoxFit.contain,
          alignment: Alignment.topCenter,
        ),
      ),
    );
  }
}

