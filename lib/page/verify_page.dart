import 'package:eligtas_resident/page/sign_up.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../RouteArguments/RouteArguments.dart';
import 'package:eligtas_resident/page/setup_profile.dart';
import 'package:eligtas_resident/CustomDialog/RegisterSucessDialog.dart';
import 'package:sizer/sizer.dart';

class VerifyScreen extends StatefulWidget {
  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  int minutes = 0;
  int seconds = 60;
  bool buttonenabled = false;
  bool isRunning = false;
  bool isClicked = false;
  late Timer timer;

  //Firebase Login
  final auth = FirebaseAuth.instance;
  User? user;
  String? uid = FirebaseAuth.instance.currentUser?.uid;
  String? email = FirebaseAuth.instance.currentUser?.email;

  @override
  void initState() {
    super.initState();
    startTimer();
    user = auth.currentUser;
    user?.sendEmailVerification();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (minutes == 0 && seconds == 0) {
        setState(() {
          buttonenabled = true;
          isRunning = false;
          checkEmailVerified();
        });
      } else if (seconds > 0 && isClicked == true) {
        setState(() {
          if (seconds == 0) {
            minutes--;
            seconds = 59;
            checkEmailVerified();
          } else {
            seconds--;
            checkEmailVerified();
          }
        });
      } else {
        setState(() {
          if (seconds == 0) {
            minutes--;
            seconds = 59;
            checkEmailVerified();
          } else {
            seconds--;
            checkEmailVerified();
          }
        });
      }
    });
  }

  Future<void> fetchData(BuildContext context) async {
    // Retrieve the arguments
    final arguments =
    ModalRoute.of(context)?.settings.arguments as RouteArguments;

    final String arg1 = arguments.arg1.toString();

    try {
      signUp(arg1);
      print('arg1: $arg1');
      print(uid);
    } catch (e) {
      // Handle errors
      print('Error: $e');
    }
  }

  Future<void> checkEmailVerified() async {
    user = auth.currentUser;
    await user?.reload();

    if (user!.emailVerified) {
      timer.cancel();
      fetchData(context);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => SetUpProfile()),
            (route) => false,
      );

      showDialog(
        context: context,
        builder: (context) {
          return RegisterSuccessDialog();
        },
      );
    }
  }

  Future signUp(arg1) async {
    var url = Uri.parse('http://192.168.100.7/e-ligtas-resident/signup.php');

    var response = await http.post(url, body: {
      "uid": uid,
      "email": arg1,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return SafeArea(
          child: Scaffold(
            body: WillPopScope(
              onWillPop: () async {
                return false;
              },
              child: Container(
                margin: EdgeInsets.all(5.0.w),
                child: Column(
                  children: [
                    Center(
                      child: Image.asset(
                        'Assets/email.gif',
                        height: 40.0.h,
                        width: 90.0.w,
                      ),
                    ),
                    SizedBox(height: 3.0.h),
                    Text(
                      "Verify your Email Address",
                      style: TextStyle(
                        fontFamily: "Montserrat-Regular",
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                      ),
                    ),
                    SizedBox(height: 3.0.h),
                    Center(
                      child: Text(
                        "We have just sent an email verification link to $email."
                            " Please check your email and click on that link to verify your "
                            "email address.",
                        style: TextStyle(
                          fontFamily: "Montserrat-Regular",
                          fontSize: 10.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 3.0.h),
                    Text(
                      '$minutes:${seconds.toString().padLeft(2, '0')}',
                      style: TextStyle(fontSize: 30.sp),
                    ),
                    SizedBox(height: 3.0.h),
                    ElevatedButton(
                      onPressed: buttonenabled
                          ? () {
                        setState(() {
                          print("Enabled");
                          minutes = 0;
                          seconds = 60;
                          buttonenabled = false;
                          isRunning = true;
                          isClicked = true;
                          user?.sendEmailVerification();
                        });
                      }
                          : null,
                      child: Text("Resend Email"),
                    ),
                    SizedBox(height: 4.0.h),
                    InkWell(
                      onTap: () {
                        DeleteAccount();
                        timer.cancel();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpPage()),
                              (route) => false,
                        );
                      },
                      child: Text(
                        " Back to Sign up",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Montserrat-Regular',
                          color: Color.fromRGBO(51, 71, 246, 1),
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
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

void DeleteAccount() async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null && !user.emailVerified) {
    // User's email is not verified, proceed to delete the account.
    await user.delete();
  }
}
