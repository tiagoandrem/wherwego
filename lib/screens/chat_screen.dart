import 'package:chatgpt_app/apis/hotel_api.dart';
import 'package:chatgpt_app/constants/constants.dart';
import 'package:chatgpt_app/screens/keyGenerate_screen.dart';
import 'package:chatgpt_app/services/api_services.dart';
import 'package:chatgpt_app/services/assets_manager.dart';
import 'package:chatgpt_app/widgets/chat_widget.dart';
import 'package:chatgpt_app/widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:chatgpt_app/services/assets_manager.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:developer';
import 'package:chatgpt_app/services/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/Hotel.dart';
import '../models/chat_models.dart';
import '../providers/chat_provider.dart';
import '../providers/models_provider.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:chatgpt_app/apis/weather_api.dart';
import '../models/flight.dart';
import '../services/flight_service.dart';
import '../services/flight_search.dart';
import '../response/weather_response.dart';
import '../apis/data_service.dart';
import 'dart:core';

import '../services/hotel_service.dart';
import '../apis/google_api.dart';
import '../services/restaurant_service.dart';



class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final dataService = DataService();
  final HotelApi hotelApi = HotelApi();
  bool isTyping = false;
  late TextEditingController textEditingController;
  late ScrollController _listScrollController;
  late FocusNode focusNode;
  HotelService hotelService = HotelService();
  final googlePlacesApi = GooglePlacesApi(apiKey: 'AIzaSyAMj4pkTlJSyV3eiCp5LKhqnoV2AEJEkf8');
  List<String> _bookingOptions = []; // Define the field here
  bool isWaitingForBookingConfirmation = false;
  bool stopTyping = false;
  String bookingType = ''; // Define the bookingType variable
  List<String> bookingOptions = []; // Define the bookingOptions variable


  RestaurantService? restaurantService;

  @override
  void initState() {
    _listScrollController = ScrollController();
    textEditingController = TextEditingController();
    focusNode = FocusNode();
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _showWelcomePopup(context);
    });
  }

  void _showWelcomePopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PopupDialog();
      },
    );
  }

  final flightSearch = FlightSearch();

  @override
  void dispose() {
    _listScrollController.dispose();
    textEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }



  //List<ChatModel> chatList = [];
  @override
  Widget build(BuildContext context) {
    final modelsProvider = Provider.of<ModelsProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    return Scaffold(
      appBar: AppBar(
        //backgroundColor: Colors.white,
        elevation: 2,
        // leading: Padding(
        //   padding: const EdgeInsets.all(8.0),
        //   child: Image.asset('images/openai_logo.jpg'),
        // ),
        title: const Text("wherwego"),
        titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 18.0
        ),
        iconTheme: IconThemeData(color: Colors.black87),
        centerTitle: true,
        // actions: [
        //   IconButton(
        //     onPressed: () async {
        //       await Services.showModalSheet(context: context);
        //     },
        //     icon: const Icon(Icons.more_vert_rounded, color: Colors.black),
        //   ),
        // ],
      ),
      drawer: NavigationDrawerNew(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            children: [
              Flexible(
                child: ListView.builder(
                    controller: _listScrollController,
                    itemCount: chatProvider.getChatList.length,
                    //chatList.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: ChatWidget(
                          msg: chatProvider
                              .getChatList[index].msg, // chatList[index].msg,
                          chatIndex: chatProvider.getChatList[index]
                              .chatIndex, //chatList[index].chatIndex,
                        ),
                      );
                    }),
              ),
              if (isTyping) ...[
                const SpinKitThreeBounce(
                  color: Colors.black,
                  size: 18,
                ),
              ],
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Material(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: Colors.green,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  color: cardcolor,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            focusNode: focusNode,
                            style: const TextStyle(color: Colors.black),
                            controller: textEditingController,
                            onSubmitted: (value) async {
                              await sendMessageFCT(
                                  modelsProvider: modelsProvider,
                                  chatProvider: chatProvider);
                            },
                            decoration: const InputDecoration.collapsed(
                                hintText: "Ask me anything!",
                                hintStyle: TextStyle(color: Colors.grey)
                            ),
                          ),
                        ),
                        IconButton(
                            onPressed: () async {
                              await sendMessageFCT(
                                  modelsProvider: modelsProvider,
                                  chatProvider: chatProvider);
                            },
                            icon: Transform.rotate(
                              angle: 320,
                              child: Icon(
                                Icons.send,
                                color: Colors.black87,
                              ),
                            ))
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'wherwego licence 2023',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void scrollListToEND() {
    _listScrollController.animateTo(
        _listScrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 2),
        curve: Curves.easeOut);
  }

  bool isBookingRestaurant = false;
  List<String> hotelBookingOptions = [];
  int selectedBookingIndex = -1;

  Future<void> sendMessageFCT({
    required ModelsProvider modelsProvider,
    required ChatProvider chatProvider,
  }) async {





    if (isTyping) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: TextWidget(
            label: "You can't send multiple messages at a time",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;


    } else {
      if (textEditingController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: TextWidget(
              label: "Please type a message",
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      setState(() {
        isTyping = true;
      });
    }
    void handleRestaurantBooking(String message) {
      RegExp dateTimeRegex = RegExp(
          r'^\s*(\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2})\s+(\d+)\s*$',
          caseSensitive: false);
      Match? dateTimeMatch = dateTimeRegex.firstMatch(textEditingController.text);

      if (dateTimeMatch != null) {
        String dateTime = dateTimeMatch.group(1)!;
        int people = int.parse(dateTimeMatch.group(2)!);

        DateTime inputDate = DateTime.parse(dateTime);
        DateTime currentDate = DateTime.now();
        DateTime truncatedCurrentDate = DateTime(currentDate.year, currentDate.month, currentDate.day);

        if (inputDate.isBefore(truncatedCurrentDate)) {
          setState(() {
            isTyping = true;
            chatProvider.addUserMessage(msg: textEditingController.text);
            chatProvider.addBotMessage(
                msg: "Invalid input. Please provide a date that is equal to or greater than the current date in the format 'yyyy-mm-dd hh:mm:ss', followed by the number of people.");
            textEditingController.clear();
            focusNode.unfocus();
          });
        } else {
          setState(() {
            isTyping = true;
            chatProvider.addUserMessage(msg: textEditingController.text);
            chatProvider.addBotMessage(
                msg: "Your reservation for $people people at $dateTime has been made. You'll find the confirmation details in your Links folder.");
            textEditingController.clear();
            focusNode.unfocus();
            isBookingRestaurant = false;
          });
        }
      } else {
        setState(() {
          isBookingRestaurant = false; // Reset the booking flag
        });
      }

      // Reset isTyping flag after handling the restaurant booking
      setState(() {
        isTyping = false;
      });

      return;
    }

    if (isBookingRestaurant) {
      handleRestaurantBooking(textEditingController.text);
      return;
    }

    if (isWaitingForBookingConfirmation) {
      RegExp yesRegex = RegExp(r'^\s*(can\s+you\s+)?book\s+restaurant\s+number\s+(\d+)(\s+please)?\??\s*$', caseSensitive: false);
      Match? yesMatch = yesRegex.firstMatch(textEditingController.text);
      try {
        if (yesMatch != null) {
          print('Match found: ${yesMatch.group(0)}');
          int index = int.parse(yesMatch.group(2)!);
          if (index > 0 && index <= bookingOptions.length) {
            setState(() {
              isTyping = true;
              chatProvider.addUserMessage(msg: textEditingController.text);
              selectedBookingIndex = index - 1;

              // Set bookingType to 'restaurants'
              bookingType = 'restaurants';
              print('Booking type: $bookingType');
              if (bookingType == 'restaurants') {
                print('Inside restaurants condition');
                print('HERE');
                chatProvider.addBotMessage(
                    msg: "Please provide the date and time for the reservation at ${bookingOptions[selectedBookingIndex].substring(3)} in the format 'yyyy-mm-dd hh:mm:ss', followed by the number of people.");
                isBookingRestaurant = true;
              } else{
                print('Inside else condition');
                chatProvider.addBotMessage(
                    msg: "Your reservation is done! Link for documentation on your Links folder.");
              }

              textEditingController.clear();
              focusNode.unfocus();
              isWaitingForBookingConfirmation = false;
              bookingOptions.clear();
            });
          }
        } else {
          setState(() {
            isTyping = true;
            chatProvider.addUserMessage(msg: textEditingController.text);
            chatProvider.addBotMessage(
                msg: "I couldn't understand your response. Please reply with the correct format, for example: 'Can you book restaurant number 1'");
            textEditingController.clear();
            focusNode.unfocus();
            isTyping = false;
          });
        }
        return;
      } catch (error) {
        print('Error: $error');
      } finally {
        setState(() {
          isTyping = false;
        });
      }
      return;
    }

      try {
        String msg = textEditingController.text;
        // Handle flight search requests
        if (msg.toLowerCase().contains("flights") || msg.toLowerCase().startsWith("can you book flight number")) {
          try {
            String response = await handleFlightsUserQuery(msg);

            setState(() {
              isTyping = true;
              chatProvider.addUserMessage(msg: msg);
              chatProvider.addBotMessage(msg: response);
              textEditingController.clear();
              focusNode.unfocus();
            });
          } catch (error) {
            print('Error in handleUserQuery: $error');
            String errorMsg = "An error occurred while fetching flight data.";

            setState(() {
              isTyping = true;
              chatProvider.addUserMessage(msg: msg);
              chatProvider.addBotMessage(msg: errorMsg);
              textEditingController.clear();
              focusNode.unfocus();
            });
          }
          //Handle hotels requests
        } else if (msg.toLowerCase().contains("hotels") || msg.toLowerCase().contains("can you book hotel number") || hotelService.isWaitingForHotelBookingDetails) {
          String? response; // Initialize the response variable here
          try {
            if (hotelService.isWaitingForHotelBookingConfirmation) {
              response = hotelService.handleHotelBookingConfirmation(msg);
            } else if (hotelService.isWaitingForHotelBookingDetails) {
              print(
                  "Entering handleBookingDetails"); // Add this print statement
              response = hotelService.handleHotelBookingDetails(msg);
            } else if (msg.toLowerCase().contains("hotels") ||
                msg.toLowerCase().contains("book ")) {
              response = await hotelService.handleHotelsUserQuery(msg);
            }

            setState(() {
              isTyping = true;
              chatProvider.addUserMessage(msg: msg);
              chatProvider.addBotMessage(msg: response ??
                  "Sorry, I didn't understand your message. Please try again.");
              textEditingController.clear();
              focusNode.unfocus();
            });
          } catch (error) {
            print('Error in handleHotelsUserQuery: $error');
            String errorMsg = "An error occurred while fetching hotel data.";

            setState(() {
              isTyping = true;
              chatProvider.addUserMessage(msg: msg);
              chatProvider.addBotMessage(msg: errorMsg);
              textEditingController.clear();
              focusNode.unfocus();
            });
          }

          // Handle restaurants requests
          // Handle restaurants requests
        } else if (msg.toLowerCase().contains("restaurants") || msg.toLowerCase().contains("can you book restaurant number")) {
          try {
            String? extractPlaceName(String message) {
              RegExp exp = RegExp(r'restaurants\s+(.+)$', caseSensitive: false);
              Match? match = exp.firstMatch(message);

              if (match != null && match.groupCount > 0) {
                return match.group(1);
              }

              return null;
            }
            String? placeName = extractPlaceName(msg);

            if (placeName != null) {
              print('Handling restaurant request for place: $placeName');

              Map<String, double> coordinates = await dataService.fetchCoordinates(placeName);
              double latitude = coordinates['latitude']!;
              double longitude = coordinates['longitude']!;

              List<Map<String, dynamic>> nearbyRestaurants = await googlePlacesApi.getNearbyRestaurants(latitude, longitude);
              print('These are some of $placeName restaurants: $nearbyRestaurants');

              String response = googlePlacesApi.formatRestaurantsResponse(nearbyRestaurants);
              print('Response: $response');
              if (!stopTyping) {
                setState(() {
                  isTyping = true;
                  chatProvider.addUserMessage(msg: msg);
                  chatProvider.addBotMessage(msg: response);
                  textEditingController.clear();
                  focusNode.unfocus();
                });

                // Add a delay before setting isWaitingForBookingConfirmation
                await Future.delayed(Duration(seconds: 2));

                setState(() {
                  isWaitingForBookingConfirmation = true;
                  bookingOptions = response.split('\n').skip(1).toList();
                  isTyping = false;
                });
              }
            } else {
              // Handle the case when no place name is found in the user's message
            }
          } catch (error) {
            print('Error in getNearbyRestaurants: $error');
            String errorMsg = "An error occurred while fetching nearby restaurants.";

            setState(() {
              isTyping = true;
              chatProvider.addUserMessage(msg: msg);
              chatProvider.addBotMessage(msg: errorMsg);
              textEditingController.clear();
              focusNode.unfocus();
            });
        }

        }

        //Handle weather requests
        else if (msg.toLowerCase().contains("weather")) {
          String cityName = msg.substring(
              msg.indexOf("weather") + "weather".length).trim();

          try {
            Map<String, double> coordinates = await dataService
                .fetchCoordinates(cityName);
            WeatherResponse weatherData = await dataService.getWeather(
                coordinates['latitude']!, coordinates['longitude']!);
            double currentTemperature = weatherData.tempInfo.temperature;
            String weatherDescription = weatherData.weatherInfo.description;
            String weatherMsg = "Temperature in $cityName: ${currentTemperature}°C and weather is $weatherDescription";
            setState(() {
              isTyping = true;
              chatProvider.addUserMessage(msg: msg);
              chatProvider.addBotMessage(msg: weatherMsg);
              textEditingController.clear();
              focusNode.unfocus();
            });
          } catch (error) {
            String errorMsg = "An error occurred while fetching the weather data. Please make sure you entered a valid city name.";
            setState(() {
              isTyping = true;
              chatProvider.addUserMessage(msg: msg);
              chatProvider.addBotMessage(msg: errorMsg);
              textEditingController.clear();
              focusNode.unfocus();
            });
          }

      } else {
          setState(() {
            isTyping = true;
            chatProvider.addUserMessage(msg: msg);
            textEditingController.clear();
            focusNode.unfocus();
          });
          await chatProvider.sendMessageAndGetAnswers(
              msg: msg, chosenModelId: modelsProvider.getCurrentModel);
        }
        setState(() {});
      } catch (error) {
        log("error $error");
        print(error);
        String errorMsg = "An error occurred while fetching the weather data.";
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: TextWidget(
            label: errorMsg,
          ),
          backgroundColor: Colors.red,
        ));
      } finally {
        setState(() {
          scrollListToEND();
          isTyping = false;
        });
      }
    }
  }

class PopupDialog extends StatefulWidget {
  @override
  _PopupDialogState createState() => _PopupDialogState();
}

class _PopupDialogState extends State<PopupDialog> with AutomaticKeepAliveClientMixin {
  PageController _controller = PageController(initialPage: 0);
  Timer? _timer;
  ValueNotifier<int> _currentPage = ValueNotifier<int>(0);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      int nextPage = _controller.page?.toInt() == 5 ? 0 : (_controller.page?.toInt() ?? 0) + 1;
      _controller.animateToPage(
        nextPage,
        duration: Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
      _currentPage.value = nextPage;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  List<String> pageStrings = [
    "Welcome to Paradise Beach!",
    "Book everything you need!",
    "Enjoy any cuisine.",
    "Your flight is our priority.",
    "Check out our guests' reviews.",
    "Discover the city's best spots.",
    "Embark on a mountain adventure.",

  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Container(
        height: 250,
        width: double.infinity,
        child: Stack(
          children: [
            PageView(
              controller: _controller,
              children: [
                Image.asset('images/paradise_beach.jpg', fit: BoxFit.cover),
                Image.asset('images/booking.jpg', fit: BoxFit.cover),
                Image.asset('images/restaurant.jpg', fit: BoxFit.cover),
                Image.asset('images/airport_panel.jpg', fit: BoxFit.cover),
                Image.asset('images/review.jpg', fit: BoxFit.cover),
                Image.asset('images/city.jpg', fit: BoxFit.cover),
                Image.asset('images/mountain.jpg', fit: BoxFit.cover),
                // Removed the extra 'images/booking.jpg'
              ],
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  height: 100,
                  width: 175,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    color: Colors.white.withOpacity(0.85),
                  ),
                  child: ValueListenableBuilder<int>(
                    valueListenable: _currentPage,
                    builder: (context, index, child) {
                      return Center(
                        child: Text(
                          pageStrings[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
void onUserMessage(String userMessage) async {
  String botResponse = await handleFlightsUserQuery(userMessage);
  // Display botResponse to the user, for example by updating the chat UI
}


class NavigationDrawerNew extends StatelessWidget {
  const NavigationDrawerNew({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Drawer(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            buildHeader(context),
            buildMenuItems(context),
          ],
        ),
      ),
    );
  }
  Widget buildHeader(BuildContext context) => Container(
    padding: EdgeInsets.all(24.0),
    child: Wrap(
      runSpacing: 20.0,
    ),
  );
  Widget buildMenuItems(BuildContext context) => Container(
    padding: EdgeInsets.only(top: 25.0),
    child: Wrap(
      runSpacing: 10.0,
      children: [
        ListTile(
          leading: Icon(Icons.chat_outlined),
          title: Text('Chat with me'),
          onTap: () {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => ChatScreen()));
          },
        ),
        ListTile(
          leading: Icon(Icons.key_outlined),
          title: Text('Generate a Key'),
          onTap: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => GenerateKey())
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.discord_outlined),
          title: Text('OpenAI Discord'),
          onTap: () async {
            if(await launch('https://discord.com/invite/openai',
            )){
            debugPrint('succesfully');
            }
          },
        ),
        Divider(color: Colors.black54),
        ListTile(
          leading: Icon(Icons.logout_outlined),
          title: Text('Log out'),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(Icons.settings_outlined),
          title: Text('Settings'),
          onTap: () {},
        ),
      ],
    ),
  );




}



