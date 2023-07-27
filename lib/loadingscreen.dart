import 'dart:io';
import 'package:flutter/material.dart';
import 'package:recipeai_app/camerascreen.dart';
import 'package:video_player/video_player.dart';
import 'package:camera/camera.dart';


class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  // video controller
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset(
      'assets/Asset.mp4',
    )
      ..initialize().then((_) {
        setState(() {});
      })
      ..setVolume(0.0);

    _playVideo();
  }

  bool _isVideoFinished = false;
  void _playVideo() async {
    // playing video
    _controller.play();
    setState(() {
      _isVideoFinished = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  File? imageFile;

  // _openCamera(BuildContext context) async {
  //   List<CameraDescription> cameras = await availableCameras();
  //   CameraDescription camera = cameras.first;
  //
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => CameraScreen(camera: camera),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(
            _controller,
          ),
        )
            : Container(),
      ),
    );
  }
}