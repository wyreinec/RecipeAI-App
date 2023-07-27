import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';

class ImagePreviewScreen extends StatefulWidget {
  final String imagePath;

  ImagePreviewScreen({required this.imagePath});

  @override
  _ImagePreviewScreenState createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  List<Map<String, dynamic>> detectedObjects =
      []; // List to store the detected objects

  @override
  void initState() {
    super.initState();
    // Call the object detection API when the screen is initialized
    _detectObjects();
  }

  void _detectObjects() async {
    File imageFile = File(widget.imagePath);
    final bytes = imageFile.readAsBytesSync();
    final predictionKey1 = '8d5b544a6a214d5eb009fd3a3121fbfd';
    final endpoint1 =
        'https://southcentralus.api.cognitive.microsoft.com/customvision/v3.0/Prediction/f01c253f-5c8b-4e55-9da6-f04194f40103/detect/iterations/Recipe-AI-Ingredients-Set-A/image';

    final predictionKey2 = '8d5b544a6a214d5eb009fd3a3121fbfd';
    final endpoint2 =
        'https://southcentralus.api.cognitive.microsoft.com/customvision/v3.0/Prediction/8074687b-d5b7-4a94-95a0-a72293cb3d35/detect/iterations/Recipe-AI-Ingredients-Set-B/image';

    final predictionKey3 = 'b60cf8817b284872a3037e5bf20d9e72';
    final endpoint3 =
        'https://recipeaiingredients-prediction.cognitiveservices.azure.com/customvision/v3.0/Prediction/7d012f6e-deed-4ed7-8c41-6ac9078d8ab5/detect/iterations/Recipe-AI-Ingredients-Set-C/image';

    List<Map<String, dynamic>> allPredictions = [];

    // Call the first endpoint
    List<Map<String, dynamic>> predictions1 =
        await _callDetectionAPI(endpoint1, predictionKey1, bytes);
    allPredictions.addAll(predictions1);

    // Call the second endpoint
    List<Map<String, dynamic>> predictions2 =
        await _callDetectionAPI(endpoint2, predictionKey2, bytes);
    allPredictions.addAll(predictions2);

    // Call the third endpoint
    List<Map<String, dynamic>> predictions3 =
        await _callDetectionAPI(endpoint3, predictionKey3, bytes);
    allPredictions.addAll(predictions3);

    Set<String> uniqueTagNames = Set();
    List<Map<String, dynamic>> uniquePredictions = [];
    for (var prediction in allPredictions) {
      String tagName = prediction['tagName'];
      if (!uniqueTagNames.contains(tagName)) {
        uniqueTagNames.add(tagName);
        uniquePredictions.add(prediction);
      }
    }

    setState(() {
      detectedObjects = uniquePredictions;
    });
  }

  void _showRecommendations() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Recommendations'),
          content: Text('Your recommendations will be shown here.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _callDetectionAPI(
      String endpoint, String predictionKey, Uint8List imageBytes) async {
    final uri = Uri.parse(endpoint);
    var request = new http.Request("POST", uri);

    request.headers['Prediction-Key'] = predictionKey;
    request.headers['Content-Type'] = "application/octet-stream";
    request.bodyBytes = imageBytes;

    var response = await request.send();

    if (response.statusCode == 200) {
      // Parse the JSON response
      final data = jsonDecode(await response.stream.bytesToString());
      List<Map<String, dynamic>> predictions = [];
      if (data.containsKey('predictions')) {
        predictions = List<Map<String, dynamic>>.from(data['predictions']);
      }
      return predictions;
    } else {
      print('Error in object detection API: ${response.statusCode}');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Image Preview'),
      //   backgroundColor: Color(0xFF0C8B19),
      // ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: CustomPaint(
                painter: BoundingBoxPainter(
                  predictions: detectedObjects,
                  imageSize: Size(
                    MediaQuery.of(context).size.width,
                    MediaQuery.of(context).size.height,
                  ),
                ),
                child: Image.file(
                  File(widget.imagePath),
                  fit: BoxFit.contain,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
          ),
          // Display the detected objects below the image
          Expanded(
            child: ListView.builder(
              itemCount: detectedObjects.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(detectedObjects[index]['tagName']),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: ElevatedButton(
          onPressed: () {
            // Handle the recommendation button press
            _showRecommendations();
          },
          child: Text(
            'Berikan Rekomendasi!',
            style: TextStyle(
              fontFamily: 'Nunito',
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          style: ElevatedButton.styleFrom(
            primary: Color(0xFF0C8B19),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class BoundingBoxPainter extends CustomPainter {
  final List<Map<String, dynamic>> predictions;
  final Size imageSize;

  BoundingBoxPainter({required this.predictions, required this.imageSize});

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / imageSize.width;
    final double scaleY = size.height / imageSize.height;

    final Paint paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (var prediction in predictions) {
      if (prediction.containsKey('boundingBox')) {
        Map<String, dynamic> boundingBox = prediction['boundingBox'];
        double left = boundingBox['left'] * scaleX;
        double top = boundingBox['top'] * scaleY;
        double width = boundingBox['width'] * scaleX;
        double height = boundingBox['height'] * scaleY;
        Rect rect = Rect.fromLTWH(left, top, width, height);
        canvas.drawRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
