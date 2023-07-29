import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TampilResep extends StatelessWidget {
  final String Nama_Resep;
  final String Bahan_Bahan;
  final String Cara_Membuat;
  final String Jenis_Resep;

  TampilResep({
    required this.Nama_Resep,
    required this.Bahan_Bahan,
    required this.Cara_Membuat,
    required this.Jenis_Resep,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 22, vertical: 10),
      width: MediaQuery.of(context).size.width,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            offset: Offset(
              0.0,
              10.0,
            ),
            blurRadius: 10.0,
            spreadRadius: -6.0,
          ),
        ],
      ),
      child: Stack(
        children: [
          Align(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.0),
              child: Text(
                Nama_Resep,
                style: TextStyle(
                  fontSize: 19,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
            ),
            alignment: Alignment.center,
          ),
          Align(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(5),
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFC700),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.egg,
                        color: Colors.brown,
                        size: 18,
                      ),
                      SizedBox(width: 7),
                      Text(Jenis_Resep),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                  },
                  child: Text('Lihat'),
                ),
              ],
            ),
            alignment: Alignment.bottomLeft,
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final List<String> selectedIngredients;
  final List<Map<String, dynamic>>
      recommendedRecipes; // Add this line to accept the recommended recipes

  HomePage({
    required this.selectedIngredients,
    required this.recommendedRecipes, // Add this line to accept the recommended recipes
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // List<Map<String, dynamic>> recommendedRecipes = [];
  //
  // @override
  // void initState() {
  //   super.initState();
  //   // Call the API to get recommended recipes when the screen is initialized
  //   _fetchRecommendedRecipes();
  // }
  //
  // void _fetchRecommendedRecipes() async {
  //   final apiUrl = 'https://cbd7-2001-448a-3041-1fdc-a9cf-9c65-ab64-81f1.ngrok-free.app/rekomendasi/string'; // Replace with your actual API endpoint URL
  //
  //   try {
  //     final data = {
  //       'bahan': widget.selectedIngredients,
  //     };
  //
  //     final response = await http.post(
  //       Uri.parse(apiUrl),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode(data),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       // If the request is successful, parse the response JSON
  //       List<dynamic> jsonResponse = jsonDecode(response.body);
  //       setState(() {
  //         // Update the state with the recommended recipes
  //         recommendedRecipes = jsonResponse.cast<Map<String, dynamic>>();
  //       });
  //     } else {
  //       // Handle error if the API request is not successful
  //       print('API Error: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     // Handle any exceptions that occur during the API request
  //     print('API Error: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0C8B19),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: 10),
            Text('Rekomendasi Resep'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.recommendedRecipes.length,
              // Use the recommendedRecipes from the widget parameter
              itemBuilder: (context, index) {
                final recipe = widget.recommendedRecipes[
                    index]; // Use the recommendedRecipes from the widget parameter
                return TampilResep(
                  Nama_Resep: recipe['Nama Resep'] ?? 'Unknown Recipe',
                  Bahan_Bahan: recipe['Bahan-Bahan'] ?? '',
                  Cara_Membuat: recipe['Cara Membuat'] ?? '',
                  Jenis_Resep: recipe['Jenis Resep'] ?? '',
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
