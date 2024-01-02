import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/Hotel.dart';

class HotelApi {
  final String clientId = 'AMADEUS_API_CLIENTID';
  final String clientSecret = 'AMADEUS_SECRET_KEY';

  Future<String> _getAccessToken() async {
    print("Inside _getAccessToken"); // Add this line
    final String url = 'https://test.api.amadeus.com/v1/security/oauth2/token';
    final response = await http.post(Uri.parse(url), body: {
      'grant_type': 'client_credentials',
      'client_id': clientId,
      'client_secret': clientSecret,
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final accessToken = data['access_token'];
      return accessToken;
    } else {
      throw Exception('Failed to get access token. Status Code: ${response
          .statusCode}, Response: ${response.body}');
    }
  }

  Future<String> fetchCityCode(String cityName) async {
    print("Inside fetchCityCode"); // Add this line
    final String accessToken = await _getAccessToken();

    final Uri locationSearchUrl = Uri.parse(
        'https://test.api.amadeus.com/v1/reference-data/locations');
    final Map<String, String> searchParams = {
      'subType': 'CITY',
      'keyword': cityName,
    };

    final Map<String, String> searchHeaders = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };

    final searchResponse = await http.get(
      locationSearchUrl.replace(queryParameters: searchParams),
      headers: searchHeaders,
    );

    if (searchResponse.statusCode == 200) {
      final locationsJson = json.decode(searchResponse.body)['data'];
      if (locationsJson.isNotEmpty) {
        final cityCode = locationsJson[0]['address']['cityCode'];
        return cityCode;
      } else {
        throw Exception('No city code found for provided city name');
      }
    } else {
      throw Exception('Failed to fetch city code. Status Code: ${searchResponse
          .statusCode}, Response: ${searchResponse.body}');
    }
  }

  bool isValidDateFormat(String date) {
    RegExp dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    return dateRegex.hasMatch(date);
  }

  Future<List<Hotel>> searchHotels({
    required String cityName,
  }) async {
    print("Inside searchHotels");
    final String cityCode = await fetchCityCode(cityName);
    print("Fetched city code: $cityCode");
    final String accessToken = await _getAccessToken();
    print("Fetched access token: $accessToken");
    print("Making hotel search API call");

    final Uri hotelSearchUrl = Uri.parse(
        'https://test.api.amadeus.com/v1/reference-data/locations/hotels/by-city')
        .replace(queryParameters: {
      'cityCode': cityCode,
      'radius': '5',
      'radiusUnit': 'KM',
      'hotelSource': 'ALL',
    });
    final Map<String, String> searchHeaders = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };

    final searchResponse = await http.get(
      hotelSearchUrl,
      headers: searchHeaders,
    );

    print("Hotel search API call completed");
    print("Search response status code: ${searchResponse
        .statusCode}, Response: ${searchResponse.body}"); // Add this line

    if (searchResponse.statusCode == 200) {
      final hotelsJson = json.decode(searchResponse.body)['data'];
      final List<Hotel> hotels = hotelsJson.map<Hotel>((hotelJson) =>
          Hotel.fromJson(hotelJson)).toList();

      return hotels;
    } else {
      // Add this block to handle the error
      if (searchResponse.statusCode == 400) {
        final errorJson = json.decode(searchResponse.body);
        if (errorJson.containsKey('errors')) {
          final errorDetails = errorJson['errors'][0];
          if (errorDetails.containsKey('title')) {
            throw Exception("API Error: ${errorDetails['title']}");
          }
        }
      }
      // End of the added block
      throw Exception('Failed to search hotels. Status Code: ${searchResponse
          .statusCode}, Response: ${searchResponse.body}');
    }
  }
}