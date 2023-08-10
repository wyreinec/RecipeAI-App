import 'dart:convert';
import 'package:RecipeAi/loadingscreen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

class ImagePreviewScreen extends StatefulWidget {
  final String imagePath;

  const ImagePreviewScreen({super.key, required this.imagePath});

  @override
  _ImagePreviewScreenState createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  List<Map<String, dynamic>> detectedObjects =
      []; // List to store the detected objects
  List<String> selectedIngredients = [];
  int maxIngredientsToShow = 20;

  @override
  void initState() {
    super.initState();
    // Call the object detection API when the screen is initialized
    _detectObjects();
  }

  void _detectObjects() async {
    File imageFile = File(widget.imagePath);
    final bytes = imageFile.readAsBytesSync();
    // const predictionKey1 = '8d5b544a6a214d5eb009fd3a3121fbfd';
    // const endpoint1 =
    //     'https://southcentralus.api.cognitive.microsoft.com/customvision/v3.0/Prediction/f01c253f-5c8b-4e55-9da6-f04194f40103/detect/iterations/Recipe-AI-Ingredients-Set-A/image';
    //
    // const predictionKey2 = '8d5b544a6a214d5eb009fd3a3121fbfd';
    // const endpoint2 =
    //     'https://southcentralus.api.cognitive.microsoft.com/customvision/v3.0/Prediction/8074687b-d5b7-4a94-95a0-a72293cb3d35/detect/iterations/Recipe-AI-Ingredients-Set-B/image';
    //
    // const predictionKey3 = 'b60cf8817b284872a3037e5bf20d9e72';
    // const endpoint3 =
    //     'https://recipeaiingredients-prediction.cognitiveservices.azure.com/customvision/v3.0/Prediction/7d012f6e-deed-4ed7-8c41-6ac9078d8ab5/detect/iterations/Recipe-AI-Ingredients-Set-C/image';

    const predictionKey4 = 'b60cf8817b284872a3037e5bf20d9e72';
    const endpoint4 =
        'https://recipeaiingredients-prediction.cognitiveservices.azure.com/customvision/v3.0/Prediction/33c132a7-4328-49b8-b99a-cd31da84ae56/detect/iterations/Iteration2/image';


    List<Map<String, dynamic>> allPredictions = [];

    // Call the first endpoint
    // List<Map<String, dynamic>> predictions1 =
    //     await _callDetectionAPI(endpoint1, predictionKey1, bytes);
    // allPredictions.addAll(predictions1);
    //
    // // Call the second endpoint
    // List<Map<String, dynamic>> predictions2 =
    //     await _callDetectionAPI(endpoint2, predictionKey2, bytes);
    // allPredictions.addAll(predictions2);
    //
    // // Call the third endpoint
    // List<Map<String, dynamic>> predictions3 =
    //     await _callDetectionAPI(endpoint3, predictionKey3, bytes);
    // allPredictions.addAll(predictions3);

    List<Map<String, dynamic>> predictions4 =
    await _callDetectionAPI(endpoint4, predictionKey4, bytes);
    allPredictions.addAll(predictions4);

    Set<String> uniqueTagNames = {};
    List<Map<String, dynamic>> uniquePredictions = [];
    for (var prediction in allPredictions) {
      String tagName = prediction['tagName'];
      if (!uniqueTagNames.contains(tagName)) {
        uniqueTagNames.add(tagName);
        uniquePredictions.add(prediction);
      }
    }

    uniquePredictions.sort(
        (a, b) => (a['tagName'] as String).compareTo(b['tagName'] as String));
    setState(() {
      detectedObjects = uniquePredictions;
    });
  }

  Future<void> _showRecommendations() async {
    if (selectedIngredients.length >= 1 && selectedIngredients.length <= 5) {
      // After the delay, navigate to the loading screen
      // Future.delayed(Duration(seconds: 2), () {
      //   Navigator.pop(context); // Close the loading dialog
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(builder: (context) => LoadingScreen(selectedIngredients: selectedIngredients)),
      //   );
      // });

      final data = {
        'bahan': selectedIngredients,
      };
      final apiUrl =
          'https://a92e-2001-448a-3045-5576-88b6-a43e-fcb3-5186.ngrok-free.app/rekomendasi/string';
      try {
        // Send the HTTP POST request
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(data),
        );
        if (response.statusCode == 200) {
          // If the request is successful, handle the response here
          print('API Response: ${response.body}');
          // You can parse the response JSON and use the data as needed
          // For example, you can show the recommended recipes in the UI
        } else {
          // Handle error if the API request is not successful
          print('API Error: ${response.statusCode}');
        }
      } catch (e) {
        // Handle any exceptions that occur during the API request
        print('API Error: $e');
      }
      Future.delayed(Duration(seconds: 2), () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoadingScreen(selectedIngredients: selectedIngredients),
          ),
        );
      });
    } else {
      // Show a snackbar or alert to inform the user to select at least 5 ingredients
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Jumlah bahan yang dipilih tidak sesuai'),
        ),
      );
    }
  }

  Future<List<Map<String, dynamic>>> _callDetectionAPI(
      String endpoint, String predictionKey, Uint8List imageBytes) async {
    final uri = Uri.parse(endpoint);
    var request = http.Request("POST", uri);

    request.headers['Prediction-Key'] = predictionKey;
    request.headers['Content-Type'] = "application/octet-stream";
    request.bodyBytes = imageBytes;

    var response = await request.send();

    if (response.statusCode == 200) {
      // Parse the JSON response
      final data = jsonDecode(await response.stream.bytesToString());
      List<Map<String, dynamic>> predictions = [];
      if (data.containsKey('predictions')) {
        predictions = List<Map<String, dynamic>>.from(data['predictions'])
            .where((prediction) => (prediction['probability'] as double) > 0.1)
            .toList();
      }
      // Sort the predictions by confidence in descending order
      predictions.sort((a, b) =>
          (b['probability'] as double).compareTo(a['probability'] as double));

      // Limit the number of ingredients shown to a maximum of 10
      if (predictions.length > 10) {
        predictions = predictions.sublist(0, 10);
      }

      return predictions;
    } else {
      if (kDebugMode) {
        print('Error in object detection API: ${response.statusCode}');
      }
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text('Bahan Terdeteksi'),
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.file(
                File(widget.imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverStickyHeader(
            header: Container(
              color: Color(0xFFFFC700),
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                detectedObjects.isEmpty
                    ? "Memuat..."
                    : "Pilih maksimal 5 bahan yang relevan",
                style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Nunito'),
              ),
            ),
            sliver: detectedObjects.isNotEmpty
                ? SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8.0,
                      crossAxisSpacing: 8.0,
                      childAspectRatio: 3.0,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= maxIngredientsToShow) return null;

                        final tagName = detectedObjects[index]['tagName'];
                        final isSelected =
                            selectedIngredients.contains(tagName);

                        return ListTile(
                          title: Text(
                            tagName ?? "Unknown",
                            style: TextStyle(fontFamily: 'Nunito'),
                          ),
                          leading: GreenCheckbox(
                            value: isSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  selectedIngredients.add(tagName);
                                } else {
                                  selectedIngredients.remove(tagName);
                                }
                              });
                            },
                          ),
                        );
                      },
                      childCount: detectedObjects.length > maxIngredientsToShow
                          ? maxIngredientsToShow
                          : detectedObjects.length,
                    ),
                  )
                : SliverToBoxAdapter(
                    child: Center(
                      child: Text(""),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 30), // Add spacing on the left
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Maaf bahanmu belum terdeteksi di sistem kami"),
                      ),
                    );
                  },
                  child: Text(
                    'Tidak Ada Bahan',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                  ),
                ),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: ElevatedButton(
                onPressed: _showRecommendations,
                child: Text(
                  'Rekomendasi!',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0C8B19),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GreenCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  GreenCheckbox({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: value,
      onChanged: onChanged,
      activeColor: Color(0xFF0C8B19), // Set the activeColor to green
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
