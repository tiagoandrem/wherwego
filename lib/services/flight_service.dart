import '../apis/amadeus_api.dart';
import '../models/flight.dart';
import 'flight_search.dart';

List<Flight> flightList = [];
bool flightSearchCompleted = false;

Future<String> handleFlightsUserQuery(String query) async {
  try {
    if (query.toLowerCase().contains('flights')) {
      // Extract origin, destination, and departure date from user's message
      RegExp originPattern = RegExp(r'origin:\s*(\w+)', caseSensitive: false);
      RegExp destinationPattern = RegExp(
          r'destination:\s*(\w+)', caseSensitive: false);
      RegExp datePattern = RegExp(
          r'departureDate:\s*(\d{4}-\d{2}-\d{2})', caseSensitive: false);

      String origin = originPattern.firstMatch(query)?.group(1) ?? 'NYC';
      String destination = destinationPattern.firstMatch(query)?.group(1) ??
          'LAX';
      DateTime departureDate = DateTime.tryParse(
          datePattern.firstMatch(query)?.group(1) ?? '2023-06-20') ??
          DateTime(2023, 06, 20);

      // Get access token
      String accessToken = await getAccessToken();

      // Search for flights using the Amadeus API
      FlightSearch flightSearch = FlightSearch();
      final flights = await flightSearch.searchFlights(
        origin: origin,
        destination: destination,
        departureDate: departureDate,
        accessToken: accessToken,
      );

      if (flights.isEmpty) {
        return "Sorry, there are no flights available for your search.";
      } else {
        // Generate a response listing the available flights
        flightList = flights; // Store the flights in the flightList variable
        flightSearchCompleted = true; // Set the flight search flag to true
        String response = "Here are the available flights:\n";
        for (int i = 0; i < flights.length; i++) {
          final flight = flights[i];
          response += "${i + 1}. ${flight.airline} ${flight.flightNumber} from ${flight.origin} to ${flight.destination} departing at ${flight.departureTime} and arriving at ${flight.arrivalTime} for \$${flight.price}\n";
        }
        return response;
      }
    } else if (query.toLowerCase().startsWith('can you book flight number') || query.toLowerCase().startsWith('book number')) {
      // Check if the flight search has been completed
      if (!flightSearchCompleted) {
        return "Sorry, I cannot provide you with an answer unless you provide more context. Please search for flights first.";
      } else {
        // Handle flight booking requests
        RegExp numberPattern = RegExp(r'number\s*(\d+)', caseSensitive: false);
        int flightNumber = int.tryParse(numberPattern.firstMatch(query)?.group(1) ?? '-1') ?? -1;

        if (flightNumber >= 1 && flightNumber <= flightList.length) {
          Flight flight = flightList[flightNumber - 1];
          return "Booking flight number ${flightNumber} (${flight.airline} ${flight.flightNumber}) with your saved personal information is confirmed.You can find the confirmation on your documents folder.";
        } else {
          return "Invalid flight number. Please provide a valid flight number from the list.";
        }
      }
    } else {
      return "Sorry, I don't understand your query.";
    }
  } catch (error) {
    print('Error in handleUserQuery: $error');
    return "An error occurred while fetching flight data.";
  }
}
