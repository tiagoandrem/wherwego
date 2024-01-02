class Restaurant {
  final String name;
  final double latitude;
  final double longitude;

  Restaurant({required this.name, required this.latitude, required this.longitude});

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      name: json['name'],
      latitude: json['geometry']['location']['lat'],
      longitude: json['geometry']['location']['lng'],
    );
  }
}