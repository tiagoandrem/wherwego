import 'dart:math';
import 'package:chatgpt_app/apis/google_api.dart';

import '../apis/data_service.dart';

class RestaurantService {
  final GooglePlacesApi googlePlacesApi;
  final DataService dataService;

  RestaurantService({required this.googlePlacesApi, required this.dataService});

  bool isWaitingForRestaurantChoice = false;


  Future<String> handleRestaurantsUserQuery(String msg) async {
    print('Handling restaurants user query: $msg'); // Add this print statement
    if (msg.toLowerCase().contains("restaurants")) {
      String cityName = extractCityName(msg);
      print('User message: $msg');
      return await getNearbyRestaurantsByCity(cityName);

    } else if (isWaitingForRestaurantChoice) {
      // Handle user's choice here
      return "User's choice was: $msg";
    } else {
      return "Sorry, I didn't understand your message. Please try again.";
    }
  }

  String extractCityName(String msg) {
    // This assumes that the message starts with "restaurants in "
    return msg.substring(15).trim();
  }

  Future<String> getNearbyRestaurantsByCity(String cityName) async {
    print('Getting nearby restaurants for city: $cityName'); // Add this print statement

    try {
      Map<String, double> coordinates = await dataService.fetchCoordinates(cityName);
      double latitude = coordinates['latitude']!;
      double longitude = coordinates['longitude']!;
      List<Map<String, dynamic>> restaurants =
      await googlePlacesApi.getNearbyRestaurants(latitude, longitude);
      String response = googlePlacesApi.formatRestaurantsResponse(restaurants);
      isWaitingForRestaurantChoice = true;
      return response;
    } catch (error) {
      print('Error in getNearbyRestaurantsByCity: $error');
      return "An error occurred while fetching restaurant data.";
    }
  }
}
