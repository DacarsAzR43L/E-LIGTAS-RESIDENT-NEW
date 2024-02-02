import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' as io;
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../CustomDialog/GalleryErrorDialog.dart';
import '../CustomDialog/SetUpSuccessDialog.dart';
import 'Home.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';



class Edit_ProfileScreen extends StatefulWidget {

  final auth = FirebaseAuth.instance;
  User? user;
  String? uid = FirebaseAuth.instance.currentUser?.uid;


  Edit_ProfileScreen({required this.uid});

  @override
  State<Edit_ProfileScreen> createState() => _Edit_ProfileScreenState();
}



class _Edit_ProfileScreenState extends State<Edit_ProfileScreen> {

 late Map<String, dynamic> userInfo;

  //Form Fields
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
 late GlobalKey<FormState> formKey;
 Random _random = Random();

  String finalNumber = "";
  String countryCode = '63';
  String setcountryCode = '+63';

//Status Permission
  late PermissionStatus status;
  late PermissionStatus statusCamera;

//Firebase Login
  final auth = FirebaseAuth.instance;
  User? user;
  String? uid = FirebaseAuth.instance.currentUser?.uid;

//Picked Profile

  late io.File? _imageFile = null;
  late String? _imageName =null;
  late String? _imageData =null;
  io.File file2 = io.File('/data/user/0/com.example.eligtas_resident/app_flutter/local_image.jpg');

  @override
  void initState()  {
    super.initState();

    userInfo = {};
    // Initialize controllers
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _phoneController = TextEditingController();
    formKey = GlobalKey<FormState>();

    //Fetch data and update controllers
    fetchData();
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
                _pickImage(ImageSource.camera);
              },
            ),
            CupertinoDialogAction(
              child: Text('Gallery'),
              onPressed: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        )
            : AlertDialog(
          title: Text('Select Image Source'),
          actions: <Widget>[
            TextButton(
              child: Text('Camera'),
              onPressed: ()  {

                //statCamera ==true ||
                if( statusCamera.isGranted) {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                }
                else  {
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
                if( status.isGranted ) {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                }
                else {
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

  Future<void> fetchData() async {
    try {
      var response = await http.get(Uri.parse(
          "https://eligtas.site/public/storage/get_profile_info.php?uid=${widget.uid}"));

      if (response.statusCode == 200) {
        setState(() {
          userInfo = json.decode(response.body);
          _nameController.text = userInfo['name'] ?? 'Not Available';
          _addressController.text = userInfo['address'] ?? 'Not Available';

          String originalNumber = userInfo['phoneNumber'] ?? 'Not Available';
          String cutNumber = originalNumber.substring(2);
          _phoneController.text = cutNumber;

          saveImageToLocal(userInfo['image']);
        });
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  Future<void> saveImageToLocal(String base64Image) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/local_image.jpg';

      // Check if the file exists and delete it
      if (await io.File(imagePath).exists()) {
        await io.File(imagePath).delete();
      }

      // Decode base64 to bytes
      List<int> imageBytes = base64Decode(base64Image);

      // Write the bytes to a file
      await io.File(imagePath).writeAsBytes(imageBytes);

      setState(() {
        // Use Image.memory to directly read image bytes
        _imageFile = io.File('$imagePath');
      });

    } catch (error) {
      print('Error saving image: $error');
    }
  }

  Future<void> _pickImage(ImageSource gallery) async {
    final XFile? image = await ImagePicker().pickImage(source: gallery);

    if (image != null) {
      List<int> imageBytes = await io.File(image.path).readAsBytes();

      // Convert bytes to Uint8List
      Uint8List uint8List = Uint8List.fromList(imageBytes);

      // Encode Uint8List to base64
      String base64Image = 'data:image/${image.path.split('.').last};base64,' + base64Encode(imageBytes);

      setState(() {
        _imageFile = io.File(image.path);
        _imageName = image.path.split('/').last;
        _imageData = base64Image;

        print("Base64 Image Data: $_imageData");
        print("Image Name: $_imageName");
        print("Image File: $_imageFile");
      });
    }
  }

  Future<void> uploadNewImage() async {
    showDialog(
      context: context,
      builder: (context) {
        return AbsorbPointer(
          absorbing: true,
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );

    FormData formData = FormData.fromMap({
      'uid': uid,
      'name': _nameController.text,
      'address': _addressController.text,
      'phonenumber': finalNumber,
      'image': await MultipartFile.fromFile(_imageFile!.path, filename: 'image.jpg'),
    });

    Dio dio = Dio();
    var response = await dio.post('https://eligtas.site/public/storage/save_edit_profile_new_picture.php', data: formData);

    var res = response.data;

    if (res['success'] == true) {
      Navigator.of(context).pop();

      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) => HomeScreen(uid: uid,)), (
              route) => false);

      showDialog(
        context: context,
        builder: (context) {
          return SetUpSuccessDialog();
        },
      );
      print('Image uploaded successfully!');
    }
  }

  Future<void> uploadOldImage() async {
    showDialog(
      context: context,
      builder: (context) {
        return AbsorbPointer(
          absorbing: true,
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );

    FormData formData = FormData.fromMap({
      'uid': uid,
      'name': _nameController.text,
      'address': _addressController.text,
      'phonenumber': finalNumber,
    });

    Dio dio = Dio();
    var response = await dio.post('https://eligtas.site/public/storage/save_edit_profile_old_picture.php', data: formData);

    var res = response.data;

    if (res['success'] == true) {
      Navigator.of(context).pop();

      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) => HomeScreen(uid: uid,)), (
              route) => false);

      showDialog(
        context: context,
        builder: (context) {
          return SetUpSuccessDialog();
        },
      );
      print('Image uploaded successfully!');
    }
  }

  Future<void> checkPhoneNumber(String phone_number) async {
    showDialog(
      context: context,
      builder: (context) {
        return AbsorbPointer(
          absorbing: true,
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );

    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      // No internet connection
      Navigator.of(context).pop();
      showAlertDialog('Error', 'No internet connection. Please try again.');
      return;
    }

    final response = await http.get(Uri.parse(
        'https://eligtas.site/public/storage/check_edit_number.php?uid=$uid&phonenumber=$phone_number'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      Navigator.of(context).pop();

      if (data['status'] == 'does_not_exist') {
        print('number does not exist');
        AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          animType: AnimType.rightSlide,
          btnOkColor: Color.fromRGBO(51, 71, 246, 1),
          title: "Confirm Information",
          desc: 'Are you sure that the information is accurate?',
          btnCancelOnPress: () {},
          btnOkOnPress: () {
            uploadNewImage();
          },
          dismissOnTouchOutside: false,
        )..show();
      }

     else if (data['status'] == 'exists_only_this_uid') {
        print('exist only on the uid');
        AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          animType: AnimType.rightSlide,
          btnOkColor: Color.fromRGBO(51, 71, 246, 1),
          title: "Confirm Information",
          desc: 'Are you sure that the information is accurate?',
          btnCancelOnPress: () {},
          btnOkOnPress: () {
            uploadNewImage();
          },
          dismissOnTouchOutside: false,
        )..show();
      }

      else {
        // Number does not exist
        print('exists_other_uid');
        AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          animType: AnimType.rightSlide,
          btnOkColor: Color.fromRGBO(51, 71, 246, 1),
          title: 'Error',
          desc: 'Number is already in use, please try again',
          btnOkOnPress: () {},
          dismissOnTouchOutside: false,
        )..show();
      }
    }
  }


  Future<void> checkPhoneNumberOldPicture(String phone_number) async {
    showDialog(
      context: context,
      builder: (context) {
        return AbsorbPointer(
          absorbing: true,
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );

    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      // No internet connection
      Navigator.of(context).pop();
      showAlertDialog('Error', 'No internet connection. Please try again.');
      return;
    }

    final response = await http.get(Uri.parse(
        'https://eligtas.site/public/storage/check_edit_number.php?uid=$uid&phonenumber=$phone_number'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      Navigator.of(context).pop();

      if (data['status'] == 'does_not_exist') {
        print('number does not exist');
        AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          animType: AnimType.rightSlide,
          btnOkColor: Color.fromRGBO(51, 71, 246, 1),
          title: "Confirm Information",
          desc: 'Are you sure that the information is accurate?',
          btnCancelOnPress: () {},
          btnOkOnPress: () {
            uploadOldImage();
          },
          dismissOnTouchOutside: false,
        )..show();
      }

      else if (data['status'] == 'exists_only_this_uid') {
        print('exist only on the uid');
        AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          animType: AnimType.rightSlide,
          btnOkColor: Color.fromRGBO(51, 71, 246, 1),
          title: "Confirm Information",
          desc: 'Are you sure that the information is accurate?',
          btnCancelOnPress: () {},
          btnOkOnPress: () {
            uploadOldImage();
          },
          dismissOnTouchOutside: false,
        )..show();
      }

      else {
        // Number does not exist
        print('exists_other_uid');
        AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          animType: AnimType.rightSlide,
          btnOkColor: Color.fromRGBO(51, 71, 246, 1),
          title: 'Error',
          desc: 'Number is already in use, please try again',
          btnOkOnPress: () {},
          dismissOnTouchOutside: false,
        )..show();
      }
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

  @override
  Widget build(BuildContext context) => Scaffold(
    resizeToAvoidBottomInset: true,
    appBar: AppBar(
      title: Text('Edit Profile'),
      elevation: 4.0,
      toolbarHeight: 60.0,
      shadowColor: Colors.black,
    ),
    body: SingleChildScrollView(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(1.h,4.h,1.h,3.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Show CircleAvatar if _imageFile is null
             /* if (_imageFile == null)
                CircleAvatar(
                  radius: 100.0,
                  backgroundColor: Colors.grey,
                  backgroundImage: userInfo.containsKey('image') &&
                      userInfo['image'] != null
                      ? Image.memory(base64Decode(userInfo['image']!)).image
                      : AssetImage('Assets/appIcon.png'),
                ),*/

              CircleAvatar(
                key: _imageFile != null ? ValueKey<String>(_imageFile!.path) : null,
                radius: 15.w,
                backgroundColor: Colors.grey,
                child: _imageFile == null
                    ? Icon(Icons.person, size: 80, color: Colors.white)
                    : ClipOval(
                  child: Image.memory(
                    _imageFile!.readAsBytesSync(), // Read image bytes directly
                    key: ValueKey<String>(_imageFile!.path), // Use the file path as a key
                    width: 40.w,
                    height: 40.w,
                    fit: BoxFit.cover,
                  ),
                ),
              ),




              SizedBox(height: 20.0,),
              ElevatedButton(
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
                child: Text("Upload Image",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Montserrat-Regular",
                  ),),
                style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll<Color>(Color.fromRGBO(51, 71, 246, 1)),
                ),
              ),
              SizedBox(height: 9.0,),
              Padding(
                padding: EdgeInsets.fromLTRB(1.h,2.h,1.h,0.h),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Full Name:',
                        style: TextStyle(
                          fontFamily: 'Montserrat-Regular',
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),),
                      SizedBox(height: 10.0,),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        keyboardType: TextInputType.name,
                        controller: _nameController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(5.0),
                          prefixIcon: new Icon(Icons.account_circle_outlined, color: Colors.black,),
                          hintText: 'Full Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Color.fromRGBO(122, 122, 122, 1), width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(51, 71, 246, 1),
                              )
                          ),
                        ),
                        validator: (value) {
                          if(value!.isEmpty) {
                            return "Enter Name";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height:10.0),
                      Text('Full Address: ',
                        style: TextStyle(
                          fontFamily: 'Montserrat-Regular',
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),),
                      SizedBox(height: 10.0,),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        keyboardType: TextInputType.streetAddress,
                        controller: _addressController,
                        decoration: InputDecoration(
                          prefixIcon: new Icon(Icons.location_on_outlined, color: Colors.black,),
                          hintText: 'House/Lot/Street/Municipality/Region',
                          contentPadding: EdgeInsets.all(5.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Color.fromRGBO(122, 122, 122, 1), width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(51, 71, 246, 1),
                              )
                          ),
                        ),
                        validator: (value) {
                          if(value!.isEmpty) {
                            return "Enter Address";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10.0,),
                      Text('Phone Number:',
                        style: TextStyle(
                          fontFamily: 'Montserrat-Regular',
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),),
                      SizedBox(height: 10.0,),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        keyboardType: TextInputType.number,
                        controller: _phoneController,
                        maxLength: 10,
                        maxLengthEnforcement:null ,
                        decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 13.0, vertical: 18.0),
                            child: Text(setcountryCode, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0),),
                          ),
                          hintText: 'e.g +639993161582',
                          contentPadding: EdgeInsets.all(5.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Color.fromRGBO(122, 122, 122, 1), width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(51, 71, 246, 1),
                              )
                          ),
                        ),
                        validator: (value) {
                          if(value!.isEmpty) {
                            return "Enter Phone Number";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 90.w,
                      height: 7.h,
                      child: TextButton(
                        onPressed: () {
                          String _userInput = _phoneController.text;
                          if (formKey.currentState!.validate() && _imageFile?.path != file2.path) {
                            String mergePhoneNumber = '$countryCode$_userInput';
                            finalNumber = mergePhoneNumber;
                            print('Merged Phone Number: $mergePhoneNumber');
                            print('_imageFile: $_imageFile');
                            print('File2: $file2');

                            checkPhoneNumber(mergePhoneNumber);

                          } else if(formKey.currentState!.validate() && _imageFile?.path == file2.path) {
                            String mergePhoneNumber = '$countryCode$_userInput';
                            finalNumber = mergePhoneNumber;
                            print('Merged Phone Number: $mergePhoneNumber');
                            print('_imageFile: $_imageFile');
                            print('File2: $file2');

                            checkPhoneNumberOldPicture(mergePhoneNumber);
                          }

                            else {
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.warning,
                              animType: AnimType.rightSlide,
                              title: 'Warning!',
                              btnOkColor: Color.fromRGBO(51, 71, 246, 1),
                              desc: 'All Fields are Required and must have no Error',
                              btnOkOnPress: () {},
                            )..show();
                          }
                        },
                        child: Text('Save',
                          style: TextStyle(
                            fontFamily: 'Montserrat-Regular',
                            fontSize:24.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),),
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side: BorderSide(color: Color.fromRGBO(51, 71, 246, 1)),
                            ),
                          ),
                          backgroundColor: MaterialStatePropertyAll<Color>(Color.fromRGBO(51, 71, 246, 1)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}