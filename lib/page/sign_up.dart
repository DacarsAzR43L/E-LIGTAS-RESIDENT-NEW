import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:eligtas_resident/page/login_page.dart';
import 'package:flutter/material.dart';
import 'package:eligtas_resident/page/verify_page.dart';
import 'package:sizer/sizer.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../RouteArguments/RouteArguments.dart';

class SignUpPage extends StatefulWidget {
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Validation for the form
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final _mailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool passToggle = true;
  bool confirmToggle = true;
  bool verifyButton = false;
  String verifyLink = '';

  // Firebase Plugins
  final auth = FirebaseAuth.instance;

  // Route Arguments
  late RouteArguments arguments;
  String _textFieldValue = '';

  Future<void> registerWithEmailAndPassword(
      String email, String password) async {
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
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => VerifyScreen(),
          settings: RouteSettings(
            arguments: arguments,
          ),
        ),
            (route) => false,
      );
      // User registered successfully
      print("User registered: ${userCredential.user?.uid}");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        Navigator.of(context).pop();

        AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          animType: AnimType.rightSlide,
          btnOkColor: Color.fromRGBO(51, 71, 246, 1),
          title: 'Error',
          desc: 'Email is already in use, please try again',
          btnOkOnPress: () {},
          dismissOnTouchOutside: false,
        )..show();
      } else {
        Navigator.of(context).pop();

        AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          animType: AnimType.rightSlide,
          btnOkColor: Color.fromRGBO(51, 71, 246, 1),
          title: 'Error',
          desc: 'Please Check your Internet Connection and try again!',
          btnOkOnPress: () {},
          dismissOnTouchOutside: false,
        )..show();
      }
    } on Exception catch (e) {
      Navigator.of(context).pop();
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        animType: AnimType.rightSlide,
        btnOkColor: Color.fromRGBO(51, 71, 246, 1),
        title: 'Error',
        desc: 'An Error Occurred.  Please Try Again!',
        btnOkOnPress: () {},
        dismissOnTouchOutside: false,
      )..show();
      print('An error occurred during registration: $e');
    }
  }

  void initializeArguments() {
    arguments = RouteArguments(_textFieldValue);
    // Use 'arguments' for navigation or any other purpose.
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(2.h,16.h,2.h,0.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Text(
                          "Sign up",
                          style: TextStyle(
                            fontFamily: 'Montserrat-Regular',
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2.0.h),
                        Text(
                          "Create an account, It's free ",
                          style: TextStyle(
                              fontFamily: 'Montserrat-Regular',
                              fontSize: 15.sp,
                              color: Colors.grey[700]),
                        )
                      ],
                    ),
                    SizedBox(height: 3.0.h),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Email',
                            style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                                color: Colors.black87),
                          ),
                          SizedBox(height: 1.0.h),
                          TextFormField(
                            autovalidateMode:
                            AutovalidateMode.onUserInteraction,
                            controller: _mailController,
                            decoration: InputDecoration(
                              prefixIcon: new Icon(Icons.mail, color: Colors.black),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 1.0.w),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(1.0.h),
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey)),
                            ),
                            //VALIDATOR FOR EMAIL
                            validator: (value) {
                              bool emailValid = RegExp(
                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                  .hasMatch(value!);

                              if (value.isEmpty) {
                                return "Please Enter Email Address";
                              } else if (!emailValid) {
                                return "Enter Valid Email";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 1.0.h),
                          Text(
                            'Password',
                            style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                                color: Colors.black87),
                          ),
                          SizedBox(height: 1.0.h),
                          TextFormField(
                            autovalidateMode:
                            AutovalidateMode.onUserInteraction,
                            controller: _passwordController,
                            obscureText: passToggle,
                            decoration: InputDecoration(
                              prefixIcon:
                              new Icon(Icons.lock, color: Colors.black),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 1.0.w),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(1.0.h),
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey)),
                              suffixIcon: InkWell(
                                onTap: () {
                                  setState(() {
                                    passToggle = !passToggle;
                                  });
                                },
                                child: Icon(
                                    passToggle
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    size: 2.0.h),
                              ),
                            ),
                            //value on submit, must return null when everything is okay
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please Enter Password";
                              } else if (_passwordController.text.length < 6) {
                                return "Password must be more 6 characters";
                              }
                              if (!value.contains(RegExp(r'[A-Z]'))) {
                                return "Password must contain at least one uppercase letter";
                              }
                              if (!value.contains(RegExp(r'[a-z]'))) {
                                return "Password must contain at least one lowercase letter";
                              }
                              if (!value.contains(RegExp(r'[0-9]'))) {
                                return "Password must contain at least one numeric character";
                              }
                              if (!value
                                  .contains(RegExp(r'[!@#\$%^&*()<>?/|}{~:]'))) {
                                return "Password must contain at least one special character";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 1.0.h),
                          Text(
                            'Confirm Password',
                            style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                                color: Colors.black87),
                          ),
                          SizedBox(height: 1.0.h),
                          TextFormField(
                            autovalidateMode:
                            AutovalidateMode.onUserInteraction,
                            controller: _confirmController,
                            obscureText: confirmToggle,
                            decoration: InputDecoration(
                              prefixIcon:
                              new Icon(Icons.lock, color: Colors.black),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 1.0.w),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(1.0.h),
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey)),
                              suffixIcon: InkWell(
                                onTap: () {
                                  setState(() {
                                    confirmToggle = !confirmToggle;
                                  });
                                },
                                child: Icon(
                                    confirmToggle
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    size: 2.0.h),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please Confirm Password";
                              } else if (value != _passwordController.text) {
                                return "Password Mismatch";
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 5.0.h),
                    Container(
                      padding: EdgeInsets.only(top: 0.5.h, left: 0.5.h),
                      child: MaterialButton(
                        minWidth: double.infinity,
                        height: 7.0.h,
                        onPressed: () {
                          //Validate returns true if the form is valid.
                          if (_formKey.currentState!.validate()) {
                            _textFieldValue = _mailController.text;
                            initializeArguments();
                            registerWithEmailAndPassword(
                                _mailController.text, _passwordController.text);
                          }
                        },
                        color: Color.fromRGBO(51, 71, 246, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(1.0.h),
                        ),
                        child: Text(
                          "Sign up",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                            fontFamily: 'Montserrat-Regular',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 3.0.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Already have an account?",
                          style: TextStyle(
                            fontFamily: 'Montserrat-Regular',
                            fontSize:10.sp,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginPage()),
                                    (route) => false);
                          },
                          child: Text(
                            " Log in",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Montserrat-Regular',
                              color: Color.fromRGBO(51, 71, 246, 1),
                              fontSize: 10.sp,
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
