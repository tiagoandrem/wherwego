import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/flight.dart';

Future<String> getAccessToken() async {
  final String clientId = 'AMADEUS_CLIENT_ID';
  final String clientSecret = 'AMADEUS_API_SECRET';
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
    throw Exception('Failed to get access token');
  }
}


