import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eligtas_resident/page/Home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:eligtas_resident/page/onboarding_page.dart';
import 'package:eligtas_resident/page/sign_up.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:eligtas_resident/CustomDialog/LoginSuccessDialog.dart';

class LoginPage extends StatefulWidget {

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  //Form Fields
  final _formField = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passController = TextEditingController();

  //Pass Toggle
  bool passToggle = true;

  //Firebase
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
        return AbsorbPointer(absorbing:true,child: Center(child: CircularProgressIndicator(),));
      },
    );

    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      // No internet connection
      Navigator.of(context).pop();
      showAlertDialog('Error', 'No internet connection. Please try again.');
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;
      print("User logged in: ${user?.uid}");

    await  _storeLoginInfo();

      // Navigate to the next screen or perform any other desired action.
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) =>HomeScreen(uid: uid)),(route) => false);


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
         }else{
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
  Widget build(BuildContext context) =>

      Scaffold(
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: SafeArea(
            child: Container(
                width: 100.w,    //It will take a 20% of screen width
                height:90.h,  //It will take a 30% of screen height
              margin: EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 0),
              //decoration: BoxDecoration(
                 // color: Colors.white,
                 // border: Border.all(
                   //color: Colors.red,
                   // width: 5,
                // )),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: CircleAvatar(
                      backgroundImage: AssetImage('Assets/appIcon.png'),
                      radius: 100.0,
                    ),
                  ),

                  SizedBox(height: 10.0,),

                  Container(
                    width: 255.0,
                    height: 40.0,
                    alignment: Alignment.center,
                    //decoration: BoxDecoration(
                    // color: Colors.white,
                    //border: Border.all(
                    // color: Colors.red,
                    //  width: 5,
                   // )),
                    child: Text('Log in to your account',
                      style: TextStyle(
                        fontFamily: 'Montserrat-Regular',
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),),
                  ),

                  SizedBox(height: 25.0,),

                  Container(
                    width: 100.w,
                    height: 33.0.h,
                    alignment: Alignment.center,
                    //decoration: BoxDecoration(
                      //color: Colors.white,
                     //  border: Border.all(
                      // color: Colors.red,
                          //width: 5,
                     // )),
                    child: Form(
                      key: _formField,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('Email:',
                          style: TextStyle(
                            fontFamily: 'Montserrat-Regular',
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),),

                          SizedBox(height: 9.0,),

                          TextFormField(
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            keyboardType: TextInputType.emailAddress,
                            controller: emailController,
                            decoration: InputDecoration(
                              prefixIcon: new Icon(Icons.email,color: Colors.black,),
                              hintText: 'Email',
                                border: OutlineInputBorder(borderRadius:BorderRadius.circular(10.0),
                                    borderSide: BorderSide(color: Color.fromRGBO(122, 122, 122, 1), width: 1.0)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color.fromRGBO(51, 71, 246, 1),
                                  )
                              ),
                            ),
                          ),

                          SizedBox(height: 9.0,),

                          Text('Password:',
                            style: TextStyle(
                              fontFamily: 'Montserrat-Regular',
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),),

                          SizedBox(height: 9.0,),

                          TextFormField(
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            keyboardType: TextInputType.emailAddress,
                            controller: passController,
                            obscureText: passToggle,
                            decoration: InputDecoration(
                              prefixIcon: new Icon(Icons.lock,color: Colors.black,),
                              hintText: 'Password',
                             border: OutlineInputBorder(borderRadius:BorderRadius.circular(10.0),
                                  borderSide: BorderSide(color: Color.fromRGBO(122, 122, 122, 1), width: 1.0)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromRGBO(51, 71, 246, 1),
                                  )
                              ),

                              suffixIcon: InkWell(
                                onTap: (){
                                    setState(() {
                                       passToggle = !passToggle;
                                    });

                                },
                                child: Icon(passToggle ? Icons.visibility_off : Icons.visibility),
                              ),
                            ),
                            validator: (value) {
                              if(value!.isEmpty) {
                                return "Enter Password";

                              }
                              return null;

                            },
                          ),
                        ],
                      ),
                    ),
                  ),



                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 400.0,
                        height: 57.0 ,
                        child: TextButton(onPressed: (){

                          if(_formField.currentState!.validate()){

                            loginUser(emailController.text, passController.text);

                          }
                        },
                            child: Text('Log in',
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

                      SizedBox(height: 50.0,),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('No Account?',
                          style: TextStyle(
                            fontFamily: 'Montserrat-Regular',
                            fontSize: 15.0,
                          ),),
                          SizedBox(width: 4.0,),
                          InkWell(

                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => SignUpPage()));
                            },
                            child:Text('Sign Up',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color.fromRGBO(51, 71, 246, 1),
                              fontSize: 15.0,
                              fontFamily: 'Montserrat-Regular',
                            ),)
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

  void goToOnBoarding(context) => Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (_) => OnBoardingPage()),
  );
}
