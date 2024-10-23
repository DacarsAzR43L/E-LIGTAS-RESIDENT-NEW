import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class DetailsPage extends StatefulWidget {
  final String id;
  final String name;

  DetailsPage({required this.id, required this.name});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late Future<List<Map<String, dynamic>>> beforeData;
  late Future<List<Map<String, dynamic>>> duringData;
  late Future<List<Map<String, dynamic>>> afterData;

  @override
  void initState() {
    super.initState();
    beforeData = fetchGuidelinesData(widget.id, 'before');
    duringData = fetchGuidelinesData(widget.id, 'during');
    afterData = fetchGuidelinesData(widget.id, 'after');
  }

  Future<List<Map<String, dynamic>>> fetchGuidelinesData(String guidelinesId, String section) async {
    final apiUrl = 'http://192.168.100.66/e-ligtas-resident/get_${section}_guidelines.php?guidelines_id=$guidelinesId';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        // Handle errors
        print("Error1: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      // Handle network or other errors
      print("Error2: $e");
      return [];
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Before, During, and After combined
              FutureBuilder(
                future: Future.wait([beforeData, duringData, afterData]),
                builder: (context, AsyncSnapshot<List<List<Map<String, dynamic>>>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: CircularProgressIndicator(),
                        ),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  } else {
                    List<List<Map<String, dynamic>>> dataList = snapshot.data as List<List<Map<String, dynamic>>>;
                    return Column(
                      children: [
                        // Before
                        if (dataList[0].isNotEmpty)
                          SectionWidget(
                            heading: 'Before',
                            title: dataList[0][0]['headings'],
                            imageData: base64Decode(dataList[0][0]['image']),
                            sampleText: dataList[0][0]['description'],
                          )
                        else
                          Text("No data available for 'Before' section"),
                        SizedBox(height: 20),

                        // During
                        if (dataList[1].isNotEmpty)
                          SectionWidget(
                            heading: 'During',
                            title: dataList[1][0]['headings'],
                            imageData: base64Decode(dataList[1][0]['image']),
                            sampleText: dataList[1][0]['description'],
                          )
                        else
                          Text("No data available for 'During' section"),
                        SizedBox(height: 20),

                        // After
                        if (dataList[2].isNotEmpty)
                          SectionWidget(
                            heading: 'After',
                            title: dataList[2][0]['headings'],
                            imageData: base64Decode(dataList[2][0]['image']),
                            sampleText: dataList[2][0]['description'],
                          )
                        else
                          Text("No data available for 'After' section"),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionWidget extends StatelessWidget {
  final String heading;
  final String title;
  final Uint8List? imageData;
  final String sampleText;

  SectionWidget({
    required this.heading,
    required this.title,
    required this.imageData,
    required this.sampleText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10.sp),

        Text(
          title,
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10.sp),

        Center(
          child: imageData != null
              ? Image.memory(
            imageData!,
            width: 500.sp, // Adjust the width as needed
            height: 150.sp, // Adjust the height as needed
            fit: BoxFit.contain,
          )
              : Container(), // Placeholder for the image
        ),
        SizedBox(height: 10.sp),
        Text(
          sampleText,
          style: TextStyle(fontSize: 16.sp),
          textAlign: TextAlign.justify,
        ),
        SizedBox(height: 20.sp),
      ],
    );
  }
}