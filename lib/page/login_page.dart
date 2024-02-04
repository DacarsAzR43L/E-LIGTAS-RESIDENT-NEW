import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eligtas_resident/page/Home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:eligtas_resident/page/onboarding_page.dart';
import 'package:eligtas_resident/page/sign_up.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:eligtas_resident/CustomDialog/LoginSuccessDialog.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Form Fields
  final _formField = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passController = TextEditingController();

  // Pass Toggle
  bool passToggle = true;

  // Firebase
  final auth = FirebaseAuth.instance;
  User? user;
  String? uid = FirebaseAuth.instance.currentUser?.uid;

  _storeLoginInfo() async {
    print("Shared pref called");
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isLoggedin', true);
    print(prefs.getBool('isLoggedin'));
  }

  Future<void> loginUser(String email, String password) async {
    showDialog(
      context: context,
      builder: (context) {
        return AbsorbPointer(
          absorbing: true,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );

    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      // No internet connection
      Navigator.of(context).pop();
      showAlertDialog(
        'Error',
        'No internet connection. Please try again.',
      );
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;
      print("User logged in: ${user?.uid}");

      await _storeLoginInfo();

      // Navigate to the next screen or perform any other desired action.
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(uid: uid)),
            (route) => false,
      );

      showDialog(
        context: context,
        builder: (context) {
          return LoginSuccessDialog();
        },
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'INVALID_LOGIN_CREDENTIALS') {
        // Handle the case when the password is incorrect.
        Navigator.of(context).pop();

        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.rightSlide,
          title: 'Error!',
          btnOkColor: Color.fromRGBO(51, 71, 246, 1),
          desc: 'Invalid Username or Password',
          dismissOnTouchOutside: false,
          btnOkOnPress: () {},
        )..show();
      } else {
        Navigator.of(context).pop();
        AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          animType: AnimType.rightSlide,
          title: 'Error!',
          btnOkColor: Color.fromRGBO(51, 71, 246, 1),
          desc: 'An error Occured, Please Try Again',
          dismissOnTouchOutside: false,
          btnOkOnPress: () {},
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
  void initState() {
    super.initState();
    initialization();
  }

  void initialization() async {
    print('ready in 3...');
    await Future.delayed(const Duration(seconds: 1));
    print('ready in 2...');
    await Future.delayed(const Duration(seconds: 1));
    print('ready in 1...');
    await Future.delayed(const Duration(seconds: 1));
    print('go!');
    FlutterNativeSplash.remove();
  }


  @override
  Widget build(BuildContext context) => Scaffold(
    resizeToAvoidBottomInset: true,
    body: SingleChildScrollView(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(1.h,10.h,1.h,0.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: CircleAvatar(
                  backgroundImage: AssetImage('Assets/appIcon.png'),
                  radius: 20.0.w,
                ),
              ),
              SizedBox(height: 2.0.h),
              Text(
                'Log in to your account',
                style: TextStyle(
                  fontFamily: 'Montserrat-Regular',
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 2.5.h),
              Padding(
                padding: EdgeInsets.all(2.w),
                child: Form(
                  key: _formField,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Email:',
                        style: TextStyle(
                          fontFamily: 'Montserrat-Regular',
                          fontSize: 15.0.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2.0.h),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        keyboardType: TextInputType.emailAddress,
                        controller: emailController,
                        decoration: InputDecoration(
                          prefixIcon: new Icon(Icons.email, color: Colors.black),
                          hintText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(1.0.h),
                            borderSide: BorderSide(
                              color: Color.fromRGBO(122, 122, 122, 1),
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromRGBO(51, 71, 246, 1),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 1.0.h),
                      Text(
                        'Password:',
                        style: TextStyle(
                          fontFamily: 'Montserrat-Regular',
                          fontSize: 15.0.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 1.0.h),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        keyboardType: TextInputType.emailAddress,
                        controller: passController,
                        obscureText: passToggle,
                        decoration: InputDecoration(
                          prefixIcon: new Icon(Icons.lock, color: Colors.black),
                          hintText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(1.0.h),
                            borderSide: BorderSide(
                              color: Color.fromRGBO(122, 122, 122, 1),
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromRGBO(51, 71, 246, 1),
                            ),
                          ),
                          suffixIcon: InkWell(
                            onTap: () {
                              setState(() {
                                passToggle = !passToggle;
                              });
                            },
                            child: Icon(passToggle
                                ? Icons.visibility_off
                                : Icons.visibility),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Enter Password";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 3.h,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 90.w,
                    height: 7.h,
                    child: TextButton(
                      onPressed: () {
                        if (_formField.currentState!.validate()) {
                          loginUser(emailController.text, passController.text);
                        }
                      },
                      child: Text(
                        'Log in',
                        style: TextStyle(
                          fontFamily: 'Montserrat-Regular',
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(1.0.h),
                            side: BorderSide(
                              color: Color.fromRGBO(51, 71, 246, 1),
                            ),
                          ),
                        ),
                        backgroundColor:
                        MaterialStatePropertyAll<Color>(Color.fromRGBO(51, 71, 246, 1)),
                      ),
                    ),
                  ),
                  SizedBox(height: 5.0.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'No Account?',
                        style: TextStyle(
                          fontFamily: 'Montserrat-Regular',
                          fontSize: 10.sp,
                        ),
                      ),
                      SizedBox(width: 0.5.w),
                      InkWell(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => SignUpPage()));
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color.fromRGBO(51, 71, 246, 1),
                            fontSize: 10.sp,
                            fontFamily: 'Montserrat-Regular',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
