import 'dart:async';
import 'dart:convert';
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
class SetUpProfile extends StatefulWidget {
  @override
  State<SetUpProfile> createState() => _SetUpProfileState();
}



class _SetUpProfileState extends State<SetUpProfile> {

  //Form Fields
  final _formField = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
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

  late io.File? _imageFile =null;
  late String? _imageName =null;
  late String? _imageData =null;


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

  Future<void> uploadImage() async {
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
      var response = await dio.post('http://192.168.100.7/e-ligtas-resident/upload_profile.php', data: formData);

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
        'http://192.168.100.7/e-ligtas-resident/check_number.php?phone_number=$phone_number'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      Navigator.of(context).pop();

      if (data['status'] == 'success') {
        print('number Exist');
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
      }else {
        // Number does not exist
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
            uploadImage();
          },
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
  Widget build(BuildContext context)  =>
    Scaffold(
      resizeToAvoidBottomInset: true,

      appBar: AppBar(
        elevation: 5,
        backgroundColor: Colors.white, // Set the background color to white
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Set up Profile',
            style: TextStyle(
              color: Colors.black,
              fontFamily: "Montserrat-Regular",
              fontWeight: FontWeight.bold,// Set the text color
            ),
          ),
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: SingleChildScrollView(
          child: SafeArea(
            child: Container(
              margin: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0),
              width: 100.w,    //It will take a 20% of screen width
              height:85.h, //It will take a 30% of screen height
              /*decoration: BoxDecoration(
               color: Colors.white,
               border: Border.all(
              color: Colors.red,
               width: 5,
               )),*/


              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.grey,
                    child: _imageFile == null
                        ? Icon(Icons.person, size: 80, color: Colors.white)
                        : ClipOval(
                      child: Image.file(
                        _imageFile!,
                        width: 170,
                        height: 170,
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

                  Container(
                    width: 100.w,
                    height: 41.8.h,

                   /* decoration: BoxDecoration(
                     color: Colors.white,
                     border: Border.all(
                    color: Colors.red,
                     width: 5,
                     )),*/

                    child: Form(
                      key:_formField,
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
                              prefixIcon: new Icon(Icons.account_circle_outlined,color: Colors.black,),
                              hintText: 'Full Name',
                              border: OutlineInputBorder(borderRadius:BorderRadius.circular(10.0),
                                  borderSide: BorderSide(color: Color.fromRGBO(122, 122, 122, 1), width: 1.0)),
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

                          Text('Address:',
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
                              prefixIcon: new Icon(Icons.location_on_outlined,color: Colors.black,),
                              hintText: 'Address',
                              contentPadding: EdgeInsets.all(5.0),
                              border: OutlineInputBorder(borderRadius:BorderRadius.circular(10.0),
                                  borderSide: BorderSide(color: Color.fromRGBO(122, 122, 122, 1), width: 1.0),),
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
                                padding: EdgeInsets.symmetric(horizontal: 13.0,vertical: 18.0), // Adjust the spacing as needed
                                child: Text(setcountryCode,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 13.0),), // Set the country code as a prefix
                              ),
                              hintText: 'e.g +639993161582',
                              contentPadding: EdgeInsets.all(5.0),
                              border: OutlineInputBorder(borderRadius:BorderRadius.circular(10.0),
                                borderSide: BorderSide(color: Color.fromRGBO(122, 122, 122, 1), width: 1.0),),
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
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 400.0,
                          height: 50.0 ,
                          child: TextButton(onPressed: (){

                            String _userInput = _phoneController.text;

                            if(_formField.currentState!.validate() && _imageFile != null){


                              String mergePhoneNumber = '$countryCode$_userInput';
                              finalNumber = mergePhoneNumber;
                              print('Merged Phone Number: $mergePhoneNumber');

                              checkPhoneNumber(mergePhoneNumber);
                            }

                            else if(_formField.currentState!.validate() && _imageFile == null){

                              _nameController.clear();
                              _phoneController.clear();
                              _addressController.clear();

                              AwesomeDialog(
                                context: context,
                                dialogType: DialogType.warning,
                                animType: AnimType.rightSlide,
                                title: 'Warning!',
                                btnOkColor: Color.fromRGBO(51, 71, 246, 1),
                                desc: 'Please Input a Photo',
                                btnOkOnPress: () {},
                              )..show();

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
                              )..show();

                              print(uid);
                            }



                          },
                              child: Text('Continue',
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
                                  ),),
                                backgroundColor: MaterialStatePropertyAll<Color>(Color.fromRGBO(51, 71, 246, 1)),
                              )),
                        ),
                      ],
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
