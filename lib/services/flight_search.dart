import 'dart:convert';
import 'package:http/http.dart' as http;

import '../apis/amadeus_api.dart';
import '../models/flight.dart';


import 'dart:convert';
import 'package:http/http.dart' as http;

import '../apis/amadeus_api.dart';
import '../models/flight.dart';


class FlightSearch {
  Future<List<Flight>> searchFlights({
    required String origin,
    required String destination,
    required DateTime departureDate,
    required String accessToken,
  }) async {
    String formattedDate = departureDate.toIso8601String().split('T')[0];

    // Build the API URL
    String apiUrl =
        'https://test.api.amadeus.com/v2/shopping/flight-offers?originLocationCode=$origin&destinationLocationCode=$destination&departureDate=$formattedDate&adults=1&currencyCode=USD&max=10';

    // Send a GET request to the Amadeus API
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    // Check if the request was successful
    if (response.statusCode == 200) {
      // Parse the JSON response
      var jsonResponse = jsonDecode(response.body);

      // Convert the JSON data to a list of Flight objects
      List<Flight> flights = jsonResponse['data']
          .map<Flight>((flightJson) => Flight.fromJson(flightJson))
          .toList();

      return flights;
    } else {
      print('API URL: $apiUrl');
      print('HTTP status code: ${response.statusCode}');
      print('HTTP response body: ${response.body}');
      throw Exception('Failed to fetch flight data');
    }
  }
}