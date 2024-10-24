import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class HistoryRequestCard {
  final int id;
  final String name;
  final String emergencyType;
  final String date;
  final locationLink;
  final phoneNumber;
  final message;
  final residentProfile;
  final List<String> image;
  final locationName;
  final reportId;

  HistoryRequestCard({
    required this.id,
    required this.reportId,
    required this.name,
    required this.emergencyType,
    required this.date,
    required this.locationLink,
    required this.phoneNumber,
    required this.message,
    required this.residentProfile,
    required this.image,
    required this.locationName,
  });
}

class History extends StatefulWidget {





  final auth = FirebaseAuth.instance;
  User? user;
  String? uid = FirebaseAuth.instance.currentUser?.uid;

  History({required this.uid});
  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> with SingleTickerProviderStateMixin {


  late Function(bool) updateButtonState;
  final auth = FirebaseAuth.instance;
  User? user;
  String? uid = FirebaseAuth.instance.currentUser?.uid;

  int expandedCardIndex = -1;
  List<HistoryRequestCard> historyData = [];
  List<HistoryRequestCard> historyDataAccepted = [];
  List<HistoryRequestCard> historyDataArchive = [];

  late TabController _tabController;

  bool historyDataIsFetching = false;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);

    // Fetch data when the widget is initialized
    fetchData();
    fetchAcceptedData();
    fetchArchivedData();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      if (_tabController.index == 0) {
        fetchData();
      } else if (_tabController.index == 1) {
        fetchAcceptedData();
      } else if (_tabController.index == 2) {
        fetchArchivedData();
      }
    }
  }


  void removeFromList(String reportId) {
    // Find the index of the item with the given reportId
    int index = historyData.indexWhere((element) => element.reportId == reportId);

    if (index != -1) {
      // Remove the item from the list
      setState(() {
        historyData.removeAt(index);
      });

      // Call the API to remove the data from the database
      removeDataFromDatabase(reportId);
    }
  }

  Future<void> removeDataFromDatabase(String reportId) async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();

      if (connectivityResult == ConnectivityResult.none) {
        // No internet connection
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.rightSlide,
          btnOkColor: Color.fromRGBO(51, 71, 246, 1),
          title: "No Internet Connection",
          desc: 'Please check your internet connection and try again.',
          btnOkOnPress: () {},
          dismissOnTouchOutside: false,
        )..show();
        return;
      }

      // Make an API call to remove data from the database based on reportId
      final String apiUrl = 'http://192.168.100.66/e-ligtas-resident/delete_pending_history.php?report_id=${reportId}';
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.rightSlide,
          btnOkColor: Color.fromRGBO(51, 71, 246, 1),
          title: "Report Remove Successfully",
          btnOkOnPress: () {},
          dismissOnTouchOutside: false,
        )..show();
        print('Data removed from the database successfully.');
      } else {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.rightSlide,
          btnOkColor: Color.fromRGBO(51, 71, 246, 1),
          title: "Confirm Information",
          desc: 'Error removing report, please try again later',
          btnOkOnPress: () {},
          dismissOnTouchOutside: false,
        )..show();
      }
    } catch (error) {
      // Handle exception
      print('Error: $error');
    }
  }

  Future<void> fetchData() async {
    setState(() {
      historyDataIsFetching = true; // Set to false when fetching data ends
    });

    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        historyDataIsFetching = false; // Set to false when fetching data ends
      });

      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        btnOkColor: Color.fromRGBO(51, 71, 246, 1),
        title: "No Internet Connection",
        desc: 'Please try again',
        btnOkOnPress: () {},
        dismissOnTouchOutside: false,
      )..show();

      print('No Internet Connection');
      // Handle the case when there is no internet connection, e.g., show an error message.
      return;
    }

    try {
      final String apiUrl =
          'http://192.168.100.66/e-ligtas-resident/get_pending_history.php?uid=${widget.uid}';
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        List<HistoryRequestCard> data = jsonData
            .asMap()
            .map((index, item) => MapEntry(
          index,
          HistoryRequestCard(
            id: index,
            name: item['resident_name'],
            emergencyType: item['emergency_type'],
            date: item['dateandTime'],
            locationName: item['locationName'],
            locationLink: item['locationLink'],
            phoneNumber: item['phoneNumber'],
            message: item['message'],
            residentProfile: item['residentProfile'],
            image: List<String>.from(item['imageEvidence']), // Convert to List<String>
            reportId: item['report_id'],
          ),
        ))
            .values
            .toList();

        setState(() {
          historyData = data;
          historyDataIsFetching = false;
        });
      } else {
        print('Error: ${response.statusCode}');
        setState(() {
          historyData = [];
          historyDataIsFetching = false; // Set to false when fetching data ends
        });
      }
    } catch (error) {
      print('Error: $error');
      setState(() {
        historyData = [];
        historyDataIsFetching = false; // Set to false when fetching data ends
      });
    }
  }


  List<String> _getImagePaths(dynamic imageEvidence) {
    if (imageEvidence is String) {
      // If it's a comma-separated string, split it
      return imageEvidence.split(',');
    } else if (imageEvidence is List) {
      // If it's already a list, use it
      return List<String>.from(imageEvidence);
    } else {
      // Handle other cases accordingly
      return [];
    }
  }

  Future<void> fetchAcceptedData() async {
    setState(() {
      historyDataIsFetching = true; // Set to false when fetching data ends
    });

    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      // Handle the case when there is no internet connection, e.g., show an error message.
      // You can use AwesomeDialog or any other method to show an error message.
      print('No Internet Connection');
      setState(() {
        historyDataIsFetching = false; // Set to false when fetching data ends
      });
      return;
    }

    try {
      final String apiUrl = 'http://192.168.100.66/e-ligtas-resident/get_accepted_history.php?uid=${widget.uid}';
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        List<HistoryRequestCard> data = jsonData
            .asMap()
            .map((index, item) => MapEntry(
          index,
          HistoryRequestCard(
            id: index,
            name: item['resident_name'],
            emergencyType: item['emergency_type'],
            date: item['dateandTime'],
            locationName: item['locationName'],
            locationLink: item['locationLink'],
            phoneNumber: item['phoneNumber'],
            message: item['message'],
            residentProfile: item['residentProfile'],
            image: _getImagePaths(item['imageEvidence']),
            reportId: item['report_id'],
          ),
        ))
            .values
            .toList();

        // Debug print to check if data is received
        print('Accepted Data Fetched: $data');

        // Assuming historyDataAccepted is a List<HistoryRequestCard> variable
        setState(() {
          historyDataAccepted = data;
          historyDataIsFetching = false; // Set to false when fetching data ends
        });
      } else {
        print('Error: ${response.statusCode}');
        setState(() {
          historyDataAccepted = [];
          historyDataIsFetching = false; // Set to false when fetching data ends
        });
      }
    } catch (error) {
      print('Error Here: $error');
      setState(() {
        historyDataAccepted = [];
        historyDataIsFetching = false; // Set to false when fetching data ends
      });
    }
  }



  Future<void> fetchArchivedData() async {
    // Fetch archived data using a similar approach as fetchPendingData and fetchAcceptedData
    // Update the API endpoint and response parsing accordingly

    // Example:

    try {
      final String apiUrl = 'http://192.168.100.66/e-ligtas-resident/get_archived_history.php?uid=${widget.uid}';
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        List<HistoryRequestCard> data = jsonData
            .asMap()
            .map((index, item) => MapEntry(
          index,
          HistoryRequestCard(
            id: index,
            name: item['resident_name'],
            emergencyType: item['emergency_type'],
            date: item['dateandTime'],
            locationName: item['locationName'],
            locationLink: item['locationLink'],
            phoneNumber: item['phoneNumber'],
            message: item['message'],
            residentProfile: item['residentProfile'],
            image: List<String>.from(item['imageEvidence']),
            reportId: item['report_id'],
          ),
        ))
            .values
            .toList();

        setState(() {
          historyDataArchive = data;
          historyDataIsFetching = false;
        });
      } else {
        print('Error: ${response.statusCode}');
        setState(() {
          historyDataArchive = [];
          historyDataIsFetching = false;
        });
      }
    } catch (error) {
      print('Error: $error');
      setState(() {
        historyDataArchive = [];
        historyDataIsFetching = false;
      });
    }

  }



  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('History'),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Accepted'),
              Tab(text: 'Archive'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            buildPendingTab(),
            buildAcceptedTab(),
            buildArchivedTab(),
          ],
        ),
      ),
    );
  }

  Widget buildArchivedTab() {
    return RefreshIndicator(
      onRefresh: fetchArchivedData,
      child: historyDataIsFetching
          ? Center(
        child: CircularProgressIndicator(),
      )
          : historyDataArchive.isEmpty
          ? Center(
        child: Text('No archived data available'),
      )
          : ListView.builder(
        itemCount: historyDataArchive.length,
        itemBuilder: (BuildContext context, int index) {
          HistoryRequestCard card = historyDataArchive[index];
          return buildCard(
            index,
            card.emergencyType,
            card.date,
            showButtons: false,
            name: card.name,
            residentProfile: card.residentProfile,
            locationName: card.locationName,
            locationLink: card.locationLink,
            phoneNumber: card.phoneNumber,
            message: card.message,
            image: card.image,
            report_id: card.reportId,
          );
        },
      ),
    );
  }

  Widget buildPendingTab() {
    return RefreshIndicator(
      onRefresh: fetchData,
      child: historyDataIsFetching
          ? Center(
        child: CircularProgressIndicator(),
      )
          : historyData.isEmpty
          ? Center(
        child: Text('No pending data available'),
      )
          : ListView.builder(
        itemCount: historyData.length,
        itemBuilder: (BuildContext context, int index) {
          HistoryRequestCard card = historyData[index];
          return buildCard(
            index,
            card.emergencyType,
            card.date,
            showButtons: true,
            name: card.name,
            residentProfile: card.residentProfile,
            locationName: card.locationName,
            locationLink: card.locationLink,
            phoneNumber: card.phoneNumber,
            message: card.message,
            image: card.image,
            report_id: card.reportId,
          );
        },
      ),
    );
  }

  Widget buildAcceptedTab() {
    return RefreshIndicator(
      onRefresh: fetchAcceptedData,
      child: historyDataIsFetching
          ? Center(
        child: CircularProgressIndicator(),
      )
          : historyDataAccepted.isEmpty
          ? Center(
        child: Text('No accepted data available'),
      )
          : ListView.builder(
        itemCount: historyDataAccepted.length,
        itemBuilder: (BuildContext context, int index) {
          HistoryRequestCard card = historyDataAccepted[index];
          return buildCard(
            index,
            card.emergencyType,
            card.date,
            showButtons: false,
            name: card.name,
            residentProfile: card.residentProfile,
            locationName: card.locationName,
            locationLink: card.locationLink,
            phoneNumber: card.phoneNumber,
            message: card.message,
            image: card.image,
            report_id: card.reportId,
          );
        },
      ),
    );
  }



  Widget buildCard(
      int index,
      String emergencyType,
      String date, {
        bool showButtons = true,
        required String name,
        required String residentProfile,
        required String locationName,
        required String locationLink,
        required String phoneNumber,
        required String message,
        required List<String>? image,
        required report_id,
      }) {
    bool isPendingTab = showButtons; // Assuming showButtons indicates the "Pending" tab

    return GestureDetector(
      onTap: () {
        setState(() {
          expandedCardIndex = (expandedCardIndex == index) ? -1 : index;
        });
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(2.h, 2.h,2.h, 0.h),
        child: Card(
          elevation: 5,
          child: Padding(
            padding: EdgeInsets.all(2.w), // Adjusted padding here
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: residentProfile.isNotEmpty
                          ? Image.memory(base64Decode(residentProfile)).image
                          : AssetImage('path/to/placeholder_image.png'),
                    ),
                    SizedBox(width: 12), // Adjusted width here
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('Emergency type: $emergencyType'),
                        Text(
                          'Date: $date',
                          style: TextStyle(
                            fontSize: 9.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 1.h,),
                if (isPendingTab)
                  Text(
                    'If no respond within 3 minutes, try to call in the nearest barangay and cancel the report! Please visit Hotlines Tab.\nDO NOT SPAM REPORTS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (isPendingTab) SizedBox(height: 8), // Adjusted height here
                if (isPendingTab)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          AwesomeDialog(
                            context: context,
                            dialogType: DialogType.warning,
                            animType: AnimType.rightSlide,
                            btnOkColor: Color.fromRGBO(51, 71, 246, 1),
                            title: "Confirm Information",
                            desc: 'Are you sure to delete the report?',
                            btnCancelOnPress: () {},
                            btnOkOnPress: ()  async {

                              final prefs = await SharedPreferences.getInstance();
                              prefs.setBool('isButtonDisabled', false);
                              print("Report ID: ${report_id}");
                              removeFromList(report_id);
                            },
                            dismissOnTouchOutside: false,
                          )..show();
                        },
                        child: Text(
                          'Cancel Report',
                          style: TextStyle(
                            fontFamily: 'Montserrat-Regular',
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ButtonStyle(
                          shape:
                          MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side: BorderSide(color: Colors.red),
                            ),
                          ),
                          backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.red),
                        ),
                      ),
                    ],
                  ),
                Container(
                  width: isPendingTab ? 500 : 300, // Adjusted width here
                  child: Visibility(
                    visible: expandedCardIndex == index,
                    child: Padding(
                      padding: EdgeInsets.all(8.0), // Adjusted padding here
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Details:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 5.0),
                          SizedBox(height: 5.0),
                          Row(
                            children: [
                              Text('Location Name: '),
                              SizedBox(width: 5.0),
                              Flexible(
                                  child: Text(locationName, softWrap: true)),
                            ],
                          ),
                          SizedBox(height: 5.0),
                          Row(
                            children: [
                              Text('Location Link: ',
                                  style: TextStyle(color: Colors.black)),
                              SizedBox(width: 5.0),
                              Flexible(
                                child: GestureDetector(
                                  onTap: () {
                                    launch(locationLink);
                                  },
                                  child: Text(
                                    locationLink,
                                    softWrap: true,
                                    style: TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5.0),
                          GestureDetector(
                            onTap: () {
                              launch('tel:+$phoneNumber');
                            },
                            child: Row(
                              children: [
                                Text('Phone Number: '),
                                SizedBox(width: 5.0),
                                Text(
                                  '+${phoneNumber}',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 5.0),
                          Row(
                            children: [
                              Text('Message: '),
                              SizedBox(width: 5.0),
                              Flexible(child: Text(message, softWrap: true)),
                            ],
                          ),
                          SizedBox(height: 10.0),

                          buildSwiper(image),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget buildSwiper(List<String>? images) {
    if (images == null || images.isEmpty) {
      // Return a placeholder or empty container if there are no images
      return Container();
    }

    return Container(
      width: double.infinity,
      height: 400,
      child: Swiper(
        loop: false,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            alignment: Alignment.center,
            child: Image.memory(
              base64Decode(images[index]),
              fit: BoxFit.cover,
            ),
          );
        },
        itemCount: images.length,
        pagination: SwiperPagination(), // Add pagination dots if needed
        control: SwiperControl(), // Add control arrows if needed
        // Other Swiper configurations
      ),
    );
  }


}


