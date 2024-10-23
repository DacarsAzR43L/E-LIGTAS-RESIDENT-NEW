import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cached_memory_image/cached_memory_image.dart';
import 'package:sizer/sizer.dart';
import 'package:shimmer/shimmer.dart';
import '../Details.dart';

class Guidelines {
  final String id;
  final String name;
  final String thumbnail;
  final String disasterType;

  Guidelines({
    required this.id,
    required this.name,
    required this.thumbnail,
    required this.disasterType,
  });
}

class GuidelinesPage extends StatefulWidget {
  @override
  _GuidelinesPageState createState() => _GuidelinesPageState();
}

class _GuidelinesPageState extends State<GuidelinesPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<Guidelines> naturalDisasterData = [];
  List<Guidelines> manMadeDisasterData = [];
  bool isFetchingNaturalDisasters = true;
  bool isFetchingManMadeDisasters = true;
  bool isInternetConnected = true;

  @override
  void initState() {
    super.initState();
    checkInternetConnection();
    if (isInternetConnected) {
      fetchNaturalDisasterData();
      fetchManMadeDisasterData();
    }
  }

  Future<void> checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      isInternetConnected =
      (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi);
    });
  }

  Future<void> fetchNaturalDisasterData() async {
    setState(() {
      isFetchingNaturalDisasters = true;
    });
    await fetchData('Natural Disaster');
    setState(() {
      isFetchingNaturalDisasters = false;
    });
  }

  Future<void> fetchManMadeDisasterData() async {
    setState(() {
      isFetchingManMadeDisasters = true;
    });
    await fetchData('Man Made Disaster');
    setState(() {
      isFetchingManMadeDisasters = false;
    });
  }

  Future<void> fetchData(String category) async {
    if (!isInternetConnected) {
      return; // Don't fetch data if there's no internet connection
    }

    final String apiUrl =
        'http://192.168.100.66/e-ligtas-resident/get_disasters.php?disaster_type=$category';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200 && mounted) {
        // Decode the response body
        final Map<String, dynamic>? responseData = json.decode(response.body);

        // Assuming your data is nested under a key like 'data'
        final List<dynamic>? dataList = responseData?['data'];

        // Convert the server response to a list of Guidelines objects
        List<Guidelines> currentFetch = dataList
            ?.asMap()
            ?.map((index, data) =>
            MapEntry(
              index,
              Guidelines(
                id: data['guidelines_id'].toString(),
                name: data['guidelines_name'],
                thumbnail: data['thumbnail'],
                disasterType: data['disaster_type'],
              ),
            ))
            ?.values
            ?.toList() ??
            [];

        // Use the currentFetch list as needed
        for (var item in currentFetch) {
          print(
              "ID: ${item.id} - Name: ${item.name} - Thumbnail: ${item
                  .thumbnail} - Disaster Type: ${item.disasterType}");
        }

        // Store the data in the respective list
        if (category == 'Natural Disaster') {
          naturalDisasterData = currentFetch;
        } else if (category == 'Man Made Disaster') {
          manMadeDisasterData = currentFetch;
        }

        // Trigger a rebuild to update the UI with the new data
        setState(() {});
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> onRefresh() async {
    await checkInternetConnection();
    if (isInternetConnected) {
      await fetchNaturalDisasterData();
      await fetchManMadeDisasterData();
    }
  }

  Widget shimmerLoadingContainer(double height) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 4.5.h, left: 1.h, right: 1.h),
          child: isInternetConnected
              ? RefreshIndicator(
            onRefresh: onRefresh,
            child: Center(
              child: ListView(
                children: [
                  Text(
                    'Natural Disasters',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  isFetchingNaturalDisasters
                      ? shimmerLoadingContainer(
                      150.0) // Adjust height as needed
                      : Container(
                    height: MediaQuery
                        .of(context)
                        .size
                        .height * 0.3,
                    child: Swiper(
                      loop: false,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetailsPage(
                                      id: naturalDisasterData[index].id,
                                      name: naturalDisasterData[index].name,
                                    ),
                              ),
                            );
                          },
                          child: Card(
                            margin: EdgeInsets.all(8),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.memory(
                                  base64Decode(
                                      naturalDisasterData[index].thumbnail),
                                  fit: BoxFit.cover,
                                ),
                                Center(
                                  child: Text(
                                    naturalDisasterData[index].name,
                                    style: TextStyle(
                                      fontSize: 30.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Archivo_Expanded-ExtraBold",
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      itemCount: naturalDisasterData.length,
                      viewportFraction: 1.1,
                      scale: 0.9,
                      pagination: SwiperPagination(
                        margin: EdgeInsets.all(10.0),
                        alignment: Alignment.bottomCenter,
                      ),
                      control: SwiperControl(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'Man-Made Disasters',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  isFetchingManMadeDisasters
                      ? shimmerLoadingContainer(
                      150.0) // Adjust height as needed
                      : Container(
                    height: MediaQuery
                        .of(context)
                        .size
                        .height * 0.3,
                    child: Swiper(
                      loop: false,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetailsPage(
                                      id: manMadeDisasterData[index].id,
                                      name: manMadeDisasterData[index].name,
                                    ),
                              ),
                            );
                          },
                          child: Card(
                            margin: EdgeInsets.all(8),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.memory(
                                  base64Decode(
                                      manMadeDisasterData[index].thumbnail),
                                  fit: BoxFit.cover,
                                ),
                                Center(
                                  child: Text(
                                    manMadeDisasterData[index].name,
                                    style: TextStyle(
                                      fontSize: 30.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Archivo_Expanded-ExtraBold",
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      itemCount: manMadeDisasterData.length,
                      viewportFraction: 1.1,
                      scale: 0.9,
                      pagination: SwiperPagination(
                        margin: EdgeInsets.all(10.0),
                        alignment: Alignment.bottomCenter,
                      ),
                      control: SwiperControl(
                        color: Colors.white,
                      ),
                      autoplay: false,
                    ),
                  ),
                ],
              ),
            ),
          )
              : Center(
            child: Text('No Internet Connection'),
          ),
        ),
      ),
    );
  }
}
