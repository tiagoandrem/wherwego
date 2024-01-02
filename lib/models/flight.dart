class Flight {
  final String airline;
  final String flightNumber;
  final String origin;
  final String destination;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final String price;

  Flight({
    required this.airline,
    required this.flightNumber,
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
  });

  factory Flight.fromJson(Map<String, dynamic> json) {
    String airline = json['itineraries'][0]['segments'][0]['carrierCode'];
    String flightNumber = json['itineraries'][0]['segments'][0]['number'];
    String origin = json['itineraries'][0]['segments'][0]['departure']['iataCode'];
    String destination = json['itineraries'][0]['segments'][0]['arrival']['iataCode'];
    DateTime departureTime = DateTime.parse(
        json['itineraries'][0]['segments'][0]['departure']['at']);
    DateTime arrivalTime = DateTime.parse(
        json['itineraries'][0]['segments'][0]['arrival']['at']);
    String price = json['price']['total'];

    return Flight(
      airline: airline,
      flightNumber: flightNumber,
      origin: origin,
      destination: destination,
      departureTime: departureTime,
      arrivalTime: arrivalTime,
      price: price,
    );
  }
}