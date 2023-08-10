import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:RecipeAi/tampilresep.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import './previewimage.dart';


class LoadingScreen extends StatefulWidget {
  final List<String> selectedIngredients;
  const LoadingScreen({Key? key, required this.selectedIngredients})
      : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  // video controller
  late VideoPlayerController _controller;
  String imagePath = '';
  List<Map<String, dynamic>> recommendedRecipes = [];

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
    _controller.addListener(() {
      if (_controller.value.position >= _controller.value.duration) {
        // Video has finished playing
        _fetchRecommendedRecipes(); // Fetch recommended recipes from the API
      }
    });
    setState(() {
      _isVideoFinished = true;
    });
  }

  void _fetchRecommendedRecipes() async {
    final apiUrl =
        'https://a92e-2001-448a-3045-5576-88b6-a43e-fcb3-5186.ngrok-free.app/rekomendasi/string';
    try {
      final data = {
        'bahan': widget.selectedIngredients,
      };
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          recommendedRecipes = List<Map<String, dynamic>>.from(jsonResponse);
        });
      } else {
        print('API Error: ${response.statusCode}');
      }
    } catch (e) {
      print('API Error: $e');
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(
          selectedIngredients: widget.selectedIngredients,
          recommendedRecipes: recommendedRecipes,
        ),
      ),
    );
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