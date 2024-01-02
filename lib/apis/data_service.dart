import 'dart:convert';
import 'package:http/http.dart' as http;
import '../response/weather_response.dart';

class DataService {
  Future<WeatherResponse> getWeather(double lat, double lon) async {
    final queryParameters = {
      'lat': lat.toString(),
      'lon': lon.toString(),
      'appid': 'API_ID',
      // Replace with your OpenWeatherMap API key
      'units': 'metric'
    };

    final uri = Uri.https(
        'api.openweathermap.org', '/data/2.5/weather', queryParameters);

    final response = await http.get(uri);

    print(response.body);
    final json = jsonDecode(response.body);
    return WeatherResponse.fromJson(json);
  }

  Future<Map<String, double>> fetchCoordinates(String cityName) async {
    print('Inside fetchCoordinates'); // Add this print statement
    String apiKey = 'OPEMCAGEDATA_API_KEY'; // Replace with your OpenCage API key
    String apiUrl = 'https://api.opencagedata.com/geocode/v1/json?q=$cityName&key=$apiKey';

    http.Response response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      Map<String, dynamic> geoData = jsonDecode(response.body);
      double latitude = geoData['results'][0]['geometry']['lat'];
      double longitude = geoData['results'][0]['geometry']['lng'];
      return {'latitude': latitude, 'longitude': longitude};
    } else {
      print('Error: Status code ${response.statusCode}');
      print('Error: Response body ${response.body}');
      throw Exception('Failed to fetch coordinates');
    }
  }
}
