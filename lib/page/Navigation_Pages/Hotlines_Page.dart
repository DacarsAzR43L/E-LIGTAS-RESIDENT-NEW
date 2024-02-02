import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Hotlines_Page extends StatefulWidget {
  @override
  State<Hotlines_Page> createState() => _Hotlines_PageState();
}

class _Hotlines_PageState extends State<Hotlines_Page> {
  late List<dynamic> originalData;
  late List<dynamic> displayedData;
  TextEditingController searchController = TextEditingController();
  late Database _database;
  bool isLoading = true;

  Future<Database> initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'hotlines1.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE hotlines (
            id INTEGER PRIMARY KEY,
            userfrom TEXT,
            hotlines_number TEXT
          )
        ''');
      },
    );
  }

  Future<void> saveToDatabase(List<dynamic> data) async {
    final batch = _database.batch();
    for (final item in data) {
      batch.insert('hotlines', item);
    }
    await batch.commit();
  }

  Future<List<dynamic>> readFromDatabase() async {
    final List<Map<String, dynamic>> maps = await _database.query('hotlines');
    return List.generate(maps.length, (i) {
      return {
        'userfrom': maps[i]['userfrom'],
        'hotlines_number': maps[i]['hotlines_number'],
      };
    });
  }

  Future<void> clearDatabase() async {
    await _database.delete('hotlines');
  }


  Future<void> fetchDataAndInit() async {
    try {
      _database = await initDatabase();

      setState(() {
        isLoading = true;
      });

      // Fetch remote data
      final remoteData = await fetchData();

      // Save fetched data to local database
      await clearDatabase();
      await saveToDatabase(remoteData);

      // Load data from local database
      final localData = await readFromDatabase();

      setState(() {
        originalData = List.from(localData);
        displayedData = List.from(originalData);
        isLoading = false;
      });
    } catch (e) {
      // Handle network-related errors
      print('Error: $e');

      // Load data from local database
      final localData = await readFromDatabase();

      setState(() {
        originalData = List.from(localData);
        displayedData = List.from(originalData);
        isLoading = false;
      });
    }
  }

  Future<void> _refresh() async {

    await Future.delayed(Duration(seconds: 2));
    fetchDataAndInit();

  }






  Future<List<dynamic>> fetchData() async {
    final response =
    await http.get(Uri.parse('https://eligtas.site/public/storage/retrieve_hotlines.php'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data. Error code: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    originalData = [];
    displayedData = [];
    fetchDataAndInit();
  }

  void filterData(String query) {
    setState(() {
      displayedData = originalData
          .where((item) =>
      item['userfrom'].toLowerCase().contains(query.toLowerCase()) ||
          item['hotlines_number'].contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height*0.8;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(0.h,1.h,0.h,2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 3.0.w),
                    child: Text(
                      'Emergency Hotlines',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16.0.sp,
                        fontFamily: "Montserrat-Bold",
                      ),
                    ),
                  ),
                  SizedBox(height: 1.0.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.0.w),
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) {
                        filterData(value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search by name or number...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 1.0.h),

                  Container(
                    height: 68.0.h,
                    width: 98.w,
                    margin: EdgeInsets.symmetric(horizontal: 1.0.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: isLoading
                        ? Center(child: CircularProgressIndicator())
                        : displayedData.isEmpty
                        ? Center(
                      child: Text('No items found'),
                    )
                        : ListView.builder(
                      itemCount: displayedData.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 2.0,
                          margin: EdgeInsets.symmetric(
                              vertical: 1.0.h, horizontal: 2.0.w),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ListTile(
                            title: Text(
                              '${displayedData[index]['userfrom']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0.sp,
                              ),
                            ),
                            subtitle: Text(
                              '+${displayedData[index]['hotlines_number']}',
                              style: TextStyle(fontSize: 12.0.sp),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.call,
                                  color: Colors.lightGreen),
                              onPressed: () async {
                                launch(
                                    'tel://+${displayedData[index]['hotlines_number']}');
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
