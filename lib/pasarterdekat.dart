import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class NearGroceryRecommendationPage extends StatefulWidget {
  @override
  _NearGroceryRecommendationPageState createState() =>
      _NearGroceryRecommendationPageState();
}

class _NearGroceryRecommendationPageState
    extends State<NearGroceryRecommendationPage> {
  Position? _userLocation;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          return; // Handle the case when location permission is not granted
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _userLocation = position;
      });
    } catch (e) {
      // Handle any errors that occur while getting the user's location
      print('Error getting user location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearby Grocery Recommendations'),
      ),
      body: Center(
        child: _userLocation == null
            ? CircularProgressIndicator()
            : Text('Latitude: ${_userLocation!.latitude}\n'
            'Longitude: ${_userLocation!.longitude}'),
      ),
    );
  }
}
