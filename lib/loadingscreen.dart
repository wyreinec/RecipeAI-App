import 'dart:io';
import 'package:flutter/material.dart';
import 'package:recipeai_app/camerascreen.dart';
import 'package:video_player/video_player.dart';
import 'package:camera/camera.dart';
import './previewimage.dart';


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
    await _controller.play();
    setState(() {
      _isVideoFinished = true;
    });

    if (_isVideoFinished) {
      var image;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImagePreviewScreen(imagePath: image.path),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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