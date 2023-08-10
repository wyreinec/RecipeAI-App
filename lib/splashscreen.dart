import 'dart:io';
import 'package:RecipeAi/camerascreen.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:camera/camera.dart';
import 'package:package_info/package_info.dart';



class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // video controller
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    // _getAppVersion();
    _controller = VideoPlayerController.asset(
      'assets/SplashScreen.mp4',
    )
      ..initialize().then((_) {
        setState(() {});
      })
      ..setVolume(0.0);

    _playVideo();
  }

  // Future<void> _getAppVersion() async {
  //   PackageInfo packageInfo = await PackageInfo.fromPlatform();
  //   setState(() {
  //     _appVersion = packageInfo.version;
  //   });
  // }

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

  _openCamera(BuildContext context) async {
    List<CameraDescription> cameras = await availableCameras();
    CameraDescription camera = cameras.first;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(camera: camera),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              color: Colors.white,
              child: _controller.value.isInitialized
                  ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
                  : Container(),
            ),
            Container(
              height: 20,
              color: Colors.white,
            ),
            AnimatedOpacity(
              opacity: _isVideoFinished ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: Column(
                children: [
                  TextButton(
                    onPressed: () {
                      _openCamera(context);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF0C8B19),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        'Scan',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 100),
                  // SizedBox(height: 16),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      'v2.0.0', // Replace with your dynamic version fetching logic
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}