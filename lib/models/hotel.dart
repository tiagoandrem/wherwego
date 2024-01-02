class Hotel {
  final String id;
  final String name;
  final String chainCode;
  final double latitude;
  final double longitude;
  final String countryCode;
  final double distanceValue;
  final String distanceUnit;

  Hotel({
    required this.id,
    required this.name,
    required this.chainCode,
    required this.latitude,
    required this.longitude,
    required this.countryCode,
    required this.distanceValue,
    required this.distanceUnit,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    String id = json['hotelId'] ?? "";
    String name = json['name'] ?? "";
    String chainCode = json['chainCode'] ?? "";
    double latitude = json['geoCode']?['latitude']?.toDouble() ?? 0.0;
    double longitude = json['geoCode']?['longitude']?.toDouble() ?? 0.0;
    String countryCode = json['address']?['countryCode'] ?? "";
    double distanceValue = json['distance']?['value']?.toDouble() ?? 0.0;
    String distanceUnit = json['distance']?['unit'] ?? "";

    return Hotel(
      id: id,
      name: name,
      chainCode: chainCode,
      latitude: latitude,
      longitude: longitude,
      countryCode: countryCode,
      distanceValue: distanceValue,
      distanceUnit: distanceUnit,
    );
  }
}
