
import 'dart:math';
import '../models/Hotel.dart';
import '../apis/hotel_api.dart';

class HotelService {
  bool isWaitingForHotelBookingConfirmation = false;
  bool isWaitingForHotelBookingDetails = false;
  List<String> bookingOptions = [];
  String? selectedHotel;

  Future<String?> handleHotelsUserQuery(String msg) async {
    if (msg.toLowerCase().contains("hotels")) {
      print("Hotel search detected.");
      RegExp hotelRegex = RegExp(r'^\s*hotels\s+([\w\s]+)$', caseSensitive: false);
      Match? match = hotelRegex.firstMatch(msg);

      if (match != null) {
        print("Valid hotel search query.");
        String? destination = match.group(1);

        if (destination != null) {
          try {
            print("Before API call");
            HotelApi hotelApi = HotelApi(); // Instantiate HotelApi class
            List<Hotel> hotels = await hotelApi.searchHotels(
              cityName: destination.trim(),
            );
            Random random = Random();
            print("After API call");
            String hotelMsg = "Here are some hotels options:\n";

            // Extract the first 10 hotels
            List<Hotel> first10Hotels = hotels.take(10).toList();

            // Add the names of the first 10 hotels to the response
            for (int i = 0; i < first10Hotels.length; i++) {
              num randomPrice = 50 + random.nextInt(51); // Generate random price between 50 and 100€
              hotelMsg += "${i + 1}. ${first10Hotels[i].name} - ${randomPrice}€ per night\n";
            }

            isWaitingForHotelBookingConfirmation = true;
            bookingOptions = hotelMsg.split('\n').toList();

            return hotelMsg;
          } catch (error) {
            return error.toString();
          }
        } else {
          return "Please provide a valid destination for your hotel search.";
        }
      }
    }
    return null;
  }

  String? handleHotelBookingConfirmation(String msg) {
    if (!msg.toLowerCase().startsWith('can you book hotel number') && !msg.toLowerCase().startsWith('book number')) {
      return null;
    }
    RegExp numberPattern = RegExp(r'number\s*(\d+)', caseSensitive: false);
    int hotelNumber = int.tryParse(numberPattern.firstMatch(msg)?.group(1) ?? '-1') ?? -1;

    if (hotelNumber >= 1 && hotelNumber <= bookingOptions.length) {
      selectedHotel = bookingOptions[hotelNumber - 1];
      isWaitingForHotelBookingConfirmation = false;
      isWaitingForHotelBookingDetails = true;

      return "Sure! To complete the booking, please provide the check-in and check-out dates (YYYY-MM-DD) and the number of persons.";
    } else {
      return "Invalid hotel number. Please provide a valid hotel number.";
    }
  }
  String handleHotelBookingDetails(String msg) {
    RegExp dateRegex = RegExp(r'^\s*(\d{4}-\d{2}-\d{2})\s+(\d{4}-\d{2}-\d{2})\s+(\d+)\s*$', caseSensitive: false);
    Match? match = dateRegex.firstMatch(msg);

    if (match != null) {
      String checkInDate = match.group(1)!;
      String checkOutDate = match.group(2)!;
      int? numberOfPersons = int.tryParse(match.group(3)!);

      print("Check-in Date: $checkInDate");
      print("Check-out Date: $checkOutDate");
      print("Number of Persons: $numberOfPersons");

      isWaitingForHotelBookingDetails = false;
      String hotelConfirmationMsg = "Your booking for $selectedHotel has been completed! Check-in: $checkInDate, Check-out: $checkOutDate, Number of persons: $numberOfPersons. All documents are saved in the app folder.";

      return hotelConfirmationMsg;
    } else {
      return "Invalid input format. Please provide the check-in and check-out dates (YYYY-MM-DD) and the number of persons.";
    }
  }
}