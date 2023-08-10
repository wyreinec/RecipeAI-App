import 'package:flutter/material.dart';

class TampilResep extends StatelessWidget {
  final String Nama_Resep;
  final List<String> Bahan_Bahan;
  final List<String> Cara_Membuat;
  final String Jenis_Resep;

  TampilResep({
    required this.Nama_Resep,
    required this.Bahan_Bahan,
    required this.Cara_Membuat,
    required this.Jenis_Resep,
  });

  List<String> formatBahanBahan(String bahanBahan) {
    List<String> ingredients = bahanBahan.split('--');
    return ingredients.map((ingredient) => ingredient.trim()).where((
        ingredient) => ingredient.isNotEmpty).toList();
  }

  Icon getJenisResepIcon(String jenisResep) {
    switch (jenisResep.toLowerCase()) {
      case 'telur':
        return Icon(
          Icons.egg,
          color: Colors.brown,
          size: 18,
        );
      case 'tempe':
        return Icon(
          Icons.square_rounded,
          color: Colors.white,
          size: 18,
        );
      case 'tahu':
        return Icon(
          Icons.square_rounded,
          color: Colors.yellow,
          size: 18,
        );
      case 'udang':
        return Icon(
          Icons.fastfood,
          color: Colors.orange,
          size: 18,
        );
      case 'sayur':
        return Icon(
          Icons.local_florist,
          color: Colors.green,
          size: 18,
        );
    // Add more cases for other Jenis_Resep values and their corresponding Icons
      default:
        return Icon(
          Icons.info,
          color: Colors.grey,
          size: 18,
        );
    }
  }

  void navigateToRecipeDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: EdgeInsets.all(16),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Nama_Resep,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('Jenis Resep: $Jenis_Resep'),
                    SizedBox(height: 10),
                    Text('Bahan-Bahan: $Bahan_Bahan'),
                    SizedBox(height: 10),
                    Text('Cara Membuat: $Cara_Membuat'),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 22, vertical: 10),
      width: MediaQuery
          .of(context)
          .size
          .width,
      height: 180,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/background_card.jpg"),
          fit: BoxFit.cover,
        ),
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
                  fontWeight: FontWeight.bold,
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
                      getJenisResepIcon(Jenis_Resep),
                      SizedBox(width: 7),
                      Text(Jenis_Resep),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(5),
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color(0xFF0C8B19),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: GestureDetector(
                    onTap: () => navigateToRecipeDetails(context),
                    child: Row(
                      children: [
                        SizedBox(width: 7),
                        Text(
                          'Lihat Resep',
                          style: TextStyle(color: Colors.white),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
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
  bool _showRecipeDetails = false;
  Map<String, dynamic>? _selectedRecipe;

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
                final recipe = widget.recommendedRecipes[index];
                final bahanBahan = recipe['Bahan-Bahan'];
                final caraMembuat = recipe['Cara Membuat'];

                // Handle type casting
                List<String>? bahanBahanList;
                if (bahanBahan is List<dynamic>) {
                  bahanBahanList = bahanBahan.cast<String>();
                }

                List<String>? caraMembuatList;
                if (caraMembuat is List<dynamic>) {
                  caraMembuatList = caraMembuat.cast<String>();
                }

                return TampilResep(
                  Nama_Resep: recipe['Nama Resep'] ?? 'Unknown Recipe',
                  Bahan_Bahan: bahanBahanList ?? [],
                  Cara_Membuat: caraMembuatList ?? [],
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
