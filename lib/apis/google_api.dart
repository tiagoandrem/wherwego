import 'dart:convert';
import 'package:http/http.dart' as http;


class GooglePlacesApi {
  final String apiKey;

  GooglePlacesApi({required this.apiKey});

  Future<List<Map<String, dynamic>>> getNearbyRestaurants(
      double latitude, double longitude) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$latitude,$longitude&type=restaurant&rankby=distance&key=$apiKey';
    final response = await http.get(Uri.parse(url));

    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body)['results'];
      return jsonData.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load nearby restaurants');
    }
  }

  String formatRestaurantsResponse(List<Map<String, dynamic>> restaurants) {
    StringBuffer sb = StringBuffer();
    sb.writeln("Here are some restaurants:");

    for (int i = 0; i < restaurants.length && i < 5; i++) {
      Map<String, dynamic> restaurant = restaurants[i];
      sb.writeln("${i + 1}. ${restaurant['name']}");
    }

    return sb.toString();
  }
/*
  Future<List<double>> getLatLongFromLocation(String location) async {
    final String url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(location)}&key=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = json.decode(response.body);
      List<double> latLong = [
        jsonData['results'][0]['geometry']['location']['lat'],
        jsonData['results'][0]['geometry']['location']['lng']
      ];
      return latLong;
    } else {
      throw Exception('Failed to get latitude and longitude from location');
    }
  } */
}