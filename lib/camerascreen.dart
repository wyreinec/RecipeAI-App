import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  CameraScreen({Key? key, required this.camera}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();

    // Create a CameraController and set the resolution to the highest available
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );

    // Initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the screen is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the camera preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: SizedBox(
        height: 80, // Set the desired height of the button
        width: 80,  // Set the desired width of the button
        child: FloatingActionButton(
          onPressed: _captureImage,
          mini: false, // Set mini to false to make the button bigger
          backgroundColor: Color(0xFF0C8B19),
          child: Icon(
            Icons.camera_alt,
            size: 40,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }



  void _captureImage() async {
    try {
      await _initializeControllerFuture;

      // Attempt to take a picture and get the file path
      final image = await _controller.takePicture();

      // Do something with the captured image (e.g., save it, display preview, etc.)
      // Here, you can navigate to another screen to show the captured image preview.
      // For simplicity, let's just display a SnackBar with the image path.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image saved at: ${image.path}'),
        ),
      );
    } catch (e) {
      print('Error capturing image: $e');
    }
  }
}
