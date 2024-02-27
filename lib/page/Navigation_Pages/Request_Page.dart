import 'dart:async';
import 'dart:convert';
import 'dart:io'as io;
import 'dart:typed_data';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:eligtas_resident/page/History.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/cupertino.dart';
import 'package:dio/dio.dart';
import 'package:eligtas_resident/CustomDialog/GalleryErrorDialog.dart';
import 'package:connectivity_plus/connectivity_plus.dart';


class Request_Page extends StatefulWidget {

  final auth = FirebaseAuth.instance;
  User? user;
  String? uid = FirebaseAuth.instance.currentUser?.uid;


  Request_Page({required this.uid});


  @override
  State<Request_Page> createState() => _Request_PageState();
}

class _Request_PageState extends State<Request_Page> with AutomaticKeepAliveClientMixin<Request_Page> {

  Map<String, dynamic> userInfo = {};

  final auth = FirebaseAuth.instance;
  User? user;
  String? uid = FirebaseAuth.instance.currentUser?.uid;

  //Personal Info
  String name = "Not Available";
  String residentProfile = "";
  int phoneNumber = 0;
  String finalNumber = "Not Available";



  //Location
  Position? _currentPosition;
  String _currentAddress = 'Loading...';
  String locationLink ="";
  double latitude = 0;
  double longitude = 0;

  String statusReport = '0';


  bool _loading = false;
  String emergencyType ="";
  int _selectedButton = 4;

  //Form Validator
  final _formField = GlobalKey<FormState>();
  final descriptionController = TextEditingController();
  String Description = "";

//Status Permission
  late PermissionStatus status;
  late PermissionStatus statusCamera;

//Picked Profile
  late io.File? _imageFile =null;
  late String? _imageName =null;
  late String? _imageData =null;


  List<io.File> _imageFiles = [];
  List<String> _imageNames = [];
  List<String> _imageDataList = [];

  bool isButtonDisabled = false;
  int countdownDuration = 30; // 30 minutes in seconds
  late Timer countdownTimer;

  //Selected Barangay
  String? selectedBarangay = "NONE";


  void initState() {
    super.initState();
    fetchData();
  }

  @override
  bool get wantKeepAlive => true;


  Future<void> fetchData() async {
    try {
      var response = await http.get(
          Uri.parse("https://eligtas.site/public/storage/get_report_info.php?uid=${widget.uid}"));

      if (response.statusCode == 200) {
        setState(() {
          userInfo = json.decode(response.body);
        });
      }
    } catch (error) {
      print('Error fetching image: $error');
    }
  }

  Future<void> _refresh() async {

    await Future.delayed(Duration(seconds: 2));
    fetchData();
    _selectedButton =4;
    descriptionController.clear();
    _imageFile = null;
    selectedBarangay = 'NONE';

  }

  Future<void> _checkLocationServiceAndGetCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      print('Location services are disabled');

      showAlertDialog('Warning!', 'Please turn on your location service');

      setState(() {
        _loading = false;
      });
      return;
    }

    if (io.Platform.isAndroid) {
      await _requestLocationPermissionAndroid();
    } else if (io.Platform.isIOS) {
      await _requestLocationPermissionIOS();
    }

    // Continue to get the current location
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    setState(() {
      _currentPosition = position;
      longitude =position.longitude;
      latitude = position.latitude;
    });

    // Call convertCoordinatesToAddress with the obtained latitude and longitude
    await convertCoordinatesToAddress(position.latitude, position.longitude);

    setState(() {
      _loading = false;
    });

  }

  Future<void> _requestLocationPermissionAndroid() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      print('Location permission denied');

      showAlertDialog('Warning!', 'Please grant permission to access your current location!');
    }
  }

  Future<void> convertCoordinatesToAddress(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks != null && placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _currentAddress = "${place.street}, ${place.subLocality}, ${place.locality}";
        });
      } else {
        setState(() {
          _currentAddress = 'No address found';
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _currentAddress = 'Error occurred during geocoding';
      });
    }
  }

  void showAlertDialog(String title, String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.rightSlide,
      btnOkColor: Color.fromRGBO(51, 71, 246, 1),
      title: title,
      desc: message,
      btnOkOnPress: () {},
      dismissOnTouchOutside: false,
    )..show();
  }

  Future<void> _requestLocationPermissionIOS() async {
    // On iOS, location permission is usually requested when you attempt to use location services.
  }

  Future<void> _showImageSourceDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return io.Platform.isIOS
            ? CupertinoAlertDialog(
          title: Text('Select Image Source'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('Camera'),
              onPressed: () {
                Navigator.pop(context);
                _pickImages1(ImageSource.camera);
              },
            ),
            CupertinoDialogAction(
              child: Text('Gallery'),
              onPressed: () {
                Navigator.pop(context);
                _pickImages(ImageSource.gallery);
              },
            ),
          ],
        )
            : AlertDialog(
          title: Text('Select Image Source'),
          actions: <Widget>[
            TextButton(
              child: Text('Camera'),
              onPressed: () {
                // statCamera ==true ||
                if (statusCamera.isGranted) {
                  Navigator.pop(context);
                  _pickImages1(ImageSource.camera);
                } else {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) {
                      return GalleryErrorDialog();
                    },
                  );
                }
              },
            ),
            TextButton(
              child: Text('Gallery'),
              onPressed: () {
                // statGallery == true ||
                if (status.isGranted) {
                  Navigator.pop(context);
                  _pickImages(ImageSource.gallery);
                } else {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) {
                      return GalleryErrorDialog();
                    },
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildImageWithCloseButton(io.File imageFile, String base64Image, int index) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Image.file(
            imageFile,
            width: 50.0,
            height: 50.0,
            fit: BoxFit.cover,
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _imageFiles.removeAt(index);
              _imageDataList.removeAt(index);
            });
          },
          child: CircleAvatar(
            radius: 12.0,
            backgroundColor: Colors.red,
            child: Icon(
              Icons.close,
              color: Colors.white,
              size: 16.0,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImages1(ImageSource gallery) async {
    try {
      final XFile? image = await ImagePicker().pickImage(source: gallery);

      if (image != null) {

        // Show CircularProgressIndicator while picking images
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text("Loading images..."),
                ],
              ),
            );
          },
          barrierDismissible: false,
        );

        List<int> imageBytes = await io.File(image.path).readAsBytes();

        // Convert List<int> to Uint8List
        Uint8List uint8List = Uint8List.fromList(imageBytes);

        // Print original image size
        print("Original Size: ${uint8List.length} bytes");

        // Compress image using flutter_image_compress
        List<int> compressedBytes = await FlutterImageCompress.compressWithList(
          uint8List,
          minHeight: 720,
          minWidth: 720,
          quality: 50,
          format: CompressFormat.webp,
        );

        // Print compressed image size
        print("Compressed Size: ${compressedBytes.length} bytes");

        // Save compressed bytes to the image file
        await io.File(image.path).writeAsBytes(compressedBytes);

        // Convert compressed bytes to Uint8List
        Uint8List compressedUint8List = Uint8List.fromList(compressedBytes);

        // Encode Uint8List to base64
        String base64Image =
            'data:image/${image.path.split('.').last};base64,' +
                base64Encode(compressedUint8List);

        // Print image file size after compression
        print(
            "Image File Size After Compression: ${io.File(image.path).lengthSync()} bytes");

        setState(() {
          _imageFiles.add(io.File(image.path));
          _imageNames.add(image.path.split('/').last);
          _imageDataList.add(base64Image);

          print("Base64 Image Data List: $_imageDataList");
          print("Image Names List: $_imageNames");
          print("Image Files List: $_imageFiles");
        });
      }
      // Dismiss the CircularProgressIndicator dialog
      Navigator.pop(context);
    } catch (e) {
      print("Error during image picking: $e");
    }
  }

  Future<void> _pickImages(ImageSource gallery) async {
    try {

      final List<XFile>? newImages = await ImagePicker().pickMultiImage(
        maxWidth: 720,
        maxHeight: 720,
        imageQuality: 50,
      );

      if (newImages != null && newImages.isNotEmpty) {

        // Show CircularProgressIndicator while picking images
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text("Loading images..."),
                ],
              ),
            );
          },
          barrierDismissible: false,
        );

        List<String> base64Images = [];

        for (XFile image in newImages) {
          List<int> imageBytes = await io.File(image.path).readAsBytes();

          // Convert List<int> to Uint8List
          Uint8List uint8List = Uint8List.fromList(imageBytes);

          // Print original image size
          print("Original Size: ${uint8List.length} bytes");

          // Compress image using flutter_image_compress
          List<int> compressedBytes = await FlutterImageCompress.compressWithList(
            uint8List,
            minHeight: 720,
            minWidth: 720,
            quality: 50,
            format: CompressFormat.webp,
          );

          // Print compressed image size
          print("Compressed Size: ${compressedBytes.length} bytes");

          // Save compressed bytes to the image file
          await io.File(image.path).writeAsBytes(compressedBytes);

          // Convert compressed bytes to Uint8List
          Uint8List compressedUint8List = Uint8List.fromList(compressedBytes);

          // Encode Uint8List to base64
          String base64Image =
              'data:image/${image.path.split('.').last};base64,' +
                  base64Encode(compressedUint8List);

          // Print image file size after compression
          print("Image File Size After Compression: ${io.File(image.path).lengthSync()} bytes");

          base64Images.add(base64Image);
        }

        setState(() {
          // Add new images to the existing list
          _imageFiles.addAll(newImages.map((XFile file) => io.File(file.path)));
          _imageDataList.addAll(base64Images);

          print("Updated Base64 Image Data List: $_imageDataList");
          print("Updated Image Files List: $_imageFiles");
        });
      }

      // Dismiss the CircularProgressIndicator dialog
      Navigator.pop(context);
    } catch (e) {
      print("Error during image picking: $e");
    }
  }

  Future<void> uploadImage(List<io.File> imageFiles) async {
    // Check for internet connectivity
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // No internet connection
      // Handle the absence of internet connectivity as needed
      print('No internet connection');
      // You may show an error dialog or perform other actions here
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AbsorbPointer(
          absorbing: true,
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );

    try {
      FormData formData = FormData.fromMap({
        'uid': uid,
        'emergency_type': emergencyType,
        'resident_name': name,
        'locationName': _currentAddress,
        'locationLink': locationLink,
        'phoneNumber': finalNumber,
        'SectorName': selectedBarangay,
        'message': Description,
        'dateTime': DateTime.now().toLocal().toString(),
        'status': statusReport,
        'residentProfile': residentProfile,
      });

      for (int i = 0; i < imageFiles.length; i++) {
        formData.files.add(MapEntry(
          'imageEvidence[]',
          await MultipartFile.fromFile(imageFiles[i].path, filename: 'image_$i.webp'),
        ));
      }

      Dio dio = Dio();
      Response response = await dio.post(
        'https://eligtas.site/public/storage/send_reports.php',
        data: formData,
      );

      if (response.statusCode == 200) {
        var responseBody = jsonEncode(response.data);
        var res = jsonDecode(responseBody);

        print('Response from server: $res');
        print(imageFiles);

        if (res['success'] == true) {
          Navigator.of(context).pop();

          AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.rightSlide,
            btnOkColor: Color.fromRGBO(51, 71, 246, 1),
            title: 'Success',
            desc: 'Report Sent Successfully! ',
            btnOkOnPress: () {
              // Show Snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Please visit History Tab to check your report.\nONE REPORT ONLY PER EMERGENCY! DO NOT SPAM!'),
                  duration: Duration(seconds: 10),
                ),
              );
            },
            dismissOnTouchOutside: false,
          )..show();
          print('Images uploaded successfully!');

          setState(() {
            descriptionController.clear();
            _selectedButton = 4;
            _imageFiles = [];
          });
        }
      }
    } catch (error) {
      Navigator.of(context).pop();
      print('Error: $error');
      // Handle the error as needed
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('An error occurred. Please try again later.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }



  Widget _buildButton(int buttonIndex, String label, IconData icon, Color color)
  {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedButton = buttonIndex;

            switch (_selectedButton) {
              case 0:
                print('Fire');
                setState(() {
                  emergencyType ='Fire';
                });
                break;
              case 1:
                print('Crime');
                setState(() {
                  emergencyType ='Crime';
                });
                break;
              case 2:
                print('Accident');
                setState(() {
                  emergencyType ='Accident';
                });
                break;
              case 3:
                print('Medical');
                setState(() {
                  emergencyType ='Fire';
                });
                break;
              default:
                print('Null Emergency');
            }

          });
         print(_selectedButton);
        },
        child: Container(
          margin: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            border: Border.all(
              color: _selectedButton == buttonIndex ? Colors.blueAccent : Colors.black,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: TextButton.icon(
            onPressed: () {
              setState(() {
                _selectedButton = buttonIndex;
                switch (_selectedButton) {
                  case 0:
                    print('Fire');
                    setState(() {
                      emergencyType ='Fire';
                    });
                    break;
                  case 1:
                    print('Crime');
                    setState(() {
                      emergencyType ='Crime';
                    });
                    break;
                  case 2:
                    print('Accident');
                    setState(() {
                      emergencyType ='Accident';
                    });
                    break;
                  case 3:
                    print('Medical');
                    setState(() {
                      emergencyType ='Medical';
                    });
                    break;
                  default:
                    print('Default Emergency');
                }
              });
              print(_selectedButton);
            },
            icon: Icon(
              icon,
              size: 24,
            ),
    label: Text(
    label,
    style: TextStyle(
    color: Colors.black,
    fontSize: 14.sp,
    ),
          ),
        ),
      ),

      ));
  }


  
  @override
  Widget build(BuildContext context) {
    super.build(context);

      return Scaffold(
        resizeToAvoidBottomInset: true,
        body: RefreshIndicator(
          onRefresh: _refresh,
          child: SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(1.h,1.h,1.h,2.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Details of report',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 20.0,
                              fontFamily: "Montserrat-Bold",
                            ),
                          ),


                          TextButton.icon(
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => History(uid: uid)));
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.white),
                              foregroundColor: MaterialStateProperty.all(Colors.black),
                              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                                EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                              ),
                            ),
                            icon: Icon(Icons.restore),
                            label: Text('History',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 20.0,
                                fontFamily: "Montserrat-Bold",
                              ),
                            ),),

                        ]
                    ),

                    SizedBox(height: 1.0,),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Name: ',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15.0,
                            color: Colors.black,
                            fontFamily: "Montserrat-Regular",
                          ),
                        ),

                        Text('${userInfo['name']?? 'Not Available'}',
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.black,
                            fontFamily: "Montserrat-Regular",
                          ),
                        ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,

                      children: [
                        Text('Location: ',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15.0,
                            color: Colors.black,
                            fontFamily: "Montserrat-Regular",
                          ),
                        ),

                        Container(
                          width: 40.w,
                          // decoration: BoxDecoration(
                          // color: Colors.white,
                          //border: Border.all(
                          //color: Colors.red,
                          //  width: 5,
                          // )),
                          child:   _currentPosition != null
                              ?  Text(_currentAddress,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: "Montserrat-Regular",
                            ),
                          )
                              : Text('Location has not fetched yet', maxLines: 1,
                            overflow: TextOverflow.ellipsis,),
                        ),


                        SizedBox(width:1.0),

                        TextButton.icon(
                          onPressed: () {
                            _loading ? null : _checkLocationServiceAndGetCurrentLocation();
                          },
                          icon: Icon(Icons.location_on,size: 15.0,),
                          label:_loading
                              ? CircularProgressIndicator()
                              : Text('Get Location'),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.white),
                            foregroundColor: MaterialStateProperty.all(Colors.black),
                            padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                              EdgeInsets.symmetric(vertical: 0, horizontal:5),
                            ),
                          ),
                        ),


                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Phone Number: ',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15.0,
                            color: Colors.black,
                            fontFamily: "Montserrat-Regular",
                          ),
                        ),

                        Text('+${userInfo['phoneNumber']?? 'Not Available'}',
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.black,
                            fontFamily: "Montserrat-Regular",
                          ),
                        ),

                      ],
                    ),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Send to (Brgy/Sector):',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15.0,
                        color: Colors.black,
                        fontFamily: "Montserrat-Regular",
                      ),
                    ),

                    // SizedBox for spacing
                    SizedBox(width: 10.0),

                    // Dropdown Button
                    DropdownButton<String>(
                      value: selectedBarangay ?? 'NONE',
                      onChanged: (String? newValue) {
                        // When an item is selected, update the state
                        setState(() {
                          selectedBarangay = newValue!;
                          print(selectedBarangay);
                        });
                      },
                      items: <String>['NONE','BFP', 'PNP','MDRRMO', 'BAGBAGUIN', 'BALASING', 'BUENAVISTA', 'BULAC', 'CAMANGYANAN'
                                      ,'CATMON', 'CAYPOMBO', 'CAYSIO', 'GUYONG', 'LALAKHAN',
                                      'MAG-ASAWANG SAPA', 'MAHABANG PARANG', 'MANGGAHAN', 'PARADA', 'POBLACION',
                                       'PULONG BUHANGIN', 'SAN GABRIEL', 'SAN JOSE PATAG', 'SAN VICENTE', 'SANTA CLARA',
                                        'SANTA CRUZ', 'SANTO TOMAS', 'SILANGAN', 'TUMANA']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),


                    Text('Select the type of report',
                      style: TextStyle(
                        fontSize: 15.0,
                        color: Colors.grey,
                        fontFamily: "Montserrat-Regular",
                      ),
                    ),

                    SizedBox(height: 10.0,),

                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildButton(0, 'Fire',Icons.local_fire_department_outlined, Colors.blue),
                            _buildButton(1, 'Crime', Icons.local_police_outlined,Colors.blue),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildButton(2, 'Accident', Icons.car_crash,Colors.blue),
                            _buildButton(3, 'Medical', Icons.medical_information_outlined, Colors.blue),
                          ],
                        ),
                      ],
                    ),


                    SizedBox(height: 5.0),


                    /* Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                         setState(() {
                           _selectedButton =4;
                         });
                        },
                        icon: Icon(Icons.remove_circle_outline,size: 15.0,),
                        label:Text('Clear Selection'),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.white),
                          foregroundColor: MaterialStateProperty.all(Colors.black),
                          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                            EdgeInsets.symmetric(vertical: 0, horizontal:5),
                          ),
                        ),
                      ),
                    ],
                  ), */

                    SizedBox(height: 5.0),

                    Form(
                      key: _formField,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Describe your Situation',
                            style: TextStyle(

                              fontSize: 15.0,
                              color: Colors.grey,
                              fontFamily: "Montserrat-Regular",
                            ),
                          ),

                          SizedBox(height: 10.0),

                          SizedBox(
                            width: double.infinity, // <-- TextField width
                            height: 150, // <-- TextField height
                            child: TextFormField(
                              controller: descriptionController,
                              expands: true,
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                isCollapsed: true,
                                // isDense: true,
                                hintText: 'Enter your Message',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.only(top:15.0,bottom: 20.0, left:10.0, right: 10.0),
                              ),
                              validator: (value) {

                                if (value == null || value.isEmpty ) {
                                  return "Please Input Description";
                                }
                                return null;

                              },

                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.0),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Upload an Photo Evidence',
                          style: TextStyle(

                            fontSize: 15.0,
                            color: Colors.grey,
                            fontFamily: "Montserrat-Regular",
                          ),
                        ),

                        SizedBox(height: 10.0),

                        DottedBorder(
                          color: Colors.grey,
                          strokeWidth: 2,
                          dashPattern: [10, 5],
                          child: Container(
                            color: Colors.grey[200],
                            width: double.infinity,
                            height: 190,
                            child: _imageFiles.isNotEmpty
                                ? Center(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Container(
                                  padding: EdgeInsets.all(10.0),
                                  child: Wrap(
                                    spacing: 10.0,
                                    runSpacing: 10.0,
                                    children: List.generate(
                                      _imageFiles.length,
                                          (index) => _buildImageWithCloseButton(
                                        _imageFiles[index],
                                        _imageDataList[index],
                                        index,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                                : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    backgroundImage: AssetImage('Assets/appIcon.png'),
                                    radius: 50.0,
                                  ),
                                  Text(
                                    'Upload Evidence Photos',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Center(
                          child: TextButton(
                            onPressed: () async {
                              status =  await Permission.photos.request();
                              statusCamera =  await Permission.camera.request();

                              if (status.isGranted || statusCamera.isGranted) {
                                await _showImageSourceDialog(context);
                              } else {
                                AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.warning,
                                  animType: AnimType.rightSlide,
                                  btnOkColor: Color.fromRGBO(51, 71, 246, 1),
                                  title: 'Error',
                                  desc: 'Please Allow Access to the Media or Camera ',
                                  btnOkOnPress: () {},
                                  dismissOnTouchOutside: false,
                                )..show();
                              }
                            },
                            child: Text(
                              'Select Image',
                              style: TextStyle(
                                fontFamily: 'Montserrat-Regular',
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  side: BorderSide(color: Color.fromRGBO(51, 71, 246, 1)),
                                ),
                              ),
                              backgroundColor: MaterialStateProperty.all<Color>(Color.fromRGBO(51, 71, 246, 1)),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20.0,),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 290.0,
                          height: 50.0 ,
                          child: TextButton(
                              onPressed: () {

                                if (_formField.currentState!.validate() &&
                                    _selectedButton < 4 && _imageFiles != null && _imageFiles.isNotEmpty &&
                                    _currentPosition != null
                                    && userInfo['name'] != null && selectedBarangay != 'NONE') {

                                  selectedBarangay = selectedBarangay;
                                  print(selectedBarangay);
                                  Description = descriptionController.text;
                                  name = userInfo['name'];
                                  residentProfile = userInfo['image'];
                                  phoneNumber =
                                      int.parse(userInfo['phoneNumber']);
                                  finalNumber = phoneNumber.toString();

                                  Uri myLink = Uri.parse(
                                      "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude");
                                  locationLink = myLink.toString();

                                  AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.warning,
                                    animType: AnimType.rightSlide,
                                    btnOkColor: Color.fromRGBO(51, 71, 246, 1),
                                    title: "Confirm Information",
                                    desc: 'Are you sure that the information is accurate?',
                                    btnCancelOnPress: () {},
                                    btnOkOnPress: () {
                                      uploadImage(_imageFiles);
                                    },
                                    dismissOnTouchOutside: false,
                                  )
                                    ..show();
                                }

                                else {
                                  AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.warning,
                                    animType: AnimType.rightSlide,
                                    title: 'Warning!',
                                    btnOkColor: Color.fromRGBO(51, 71, 246, 1),
                                    desc: 'All Fields are Required',
                                    btnOkOnPress: () {},
                                  )
                                    ..show();
                                }
                              },
                            child: Text('Submit Report',
                              style: TextStyle(
                                fontFamily: 'Montserrat-Regular',
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  side: BorderSide(color: Color.fromRGBO(51, 71, 246, 1)),
                                ),
                              ),
                              backgroundColor: MaterialStatePropertyAll<Color>(
                                  Color.fromRGBO(51, 71, 246, 1)),
                            ),
                          ),
                        ),
                      ],
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











