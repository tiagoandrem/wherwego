import 'dart:convert';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:http/http.dart' as http;


Future<Map<String, dynamic>> fetchWeatherData(String locationKey) async {
  String apiKey = 'xxxxxxxxxxx';
  String apiUrl = 'http://dataservice.accuweather.com/forecasts/v1/daily/1day/$locationKey?apikey=$apiKey';

  http.Response response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200) {
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    if (jsonResponse.isEmpty) {
      throw Exception('No daily forecasts available');
    }

    String dateTime = jsonResponse['DateTime'];
    int weatherIcon = jsonResponse['WeatherIcon'];
    String iconPhrase = jsonResponse['IconPhrase'];
    bool hasPrecipitation = jsonResponse['HasPrecipitation'];
    bool isDaylight = jsonResponse['IsDaylight'];
    double temperature = jsonResponse['Temperature']['Value'].toDouble();
    int precipitationProbability = jsonResponse['PrecipitationProbability'];

    return {
      'dateTime': dateTime,
      'weatherIcon': weatherIcon,
      'iconPhrase': iconPhrase,
      'hasPrecipitation': hasPrecipitation,
      'isDaylight': isDaylight,
      'temperature': temperature,
      'precipitationProbability': precipitationProbability,
    };
  } else {
    throw Exception('Failed to fetch weather data');
  }
}


Future<String> fetchLocationKey(String placeName) async {
  String apiKey = 'f0988a25940e430c82ec05c2ae938482';
  String apiUrl = 'http://dataservice.accuweather.com/locations/v1/cities/search?apikey=$apiKey&q=$placeName';

  http.Response response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200) {
    List<dynamic> results = jsonDecode(response.body);
    if (results.isEmpty) {
      throw Exception('No results found');
    }
    String locationKey = results[0]['Key'];
    return locationKey;
  } else {
    throw Exception('Failed to fetch location key');
  }
}
