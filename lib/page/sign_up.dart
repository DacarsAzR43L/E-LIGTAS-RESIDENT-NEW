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

  //Validation for the form
  final _formKey = GlobalKey<FormState>();


  //Text Controllers
  final _mailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool passToggle = true;
  bool confirmToggle = true;
  bool verifyButton = false;
  String verifyLink="";

  //Firebase Plugins
  final auth = FirebaseAuth.instance;

//Route Arguments
   late RouteArguments arguments;
  String _textFieldValue = '';




  Future<void> registerWithEmailAndPassword(String email, String password) async {

    showDialog(
      context: context,
      builder: (context) {
        return AbsorbPointer( absorbing: true, child: Center(child: CircularProgressIndicator(),));
      },
    );

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => VerifyScreen(),
              settings: RouteSettings(
                arguments: arguments,)),(route) => false);
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
      }

      else {
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




  Widget build(BuildContext context) {


    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(

          child: Container(
            width: 100.w,    //It will take a 20% of screen width
            height:80.h,  //It will take a 30% of screen height
            margin: EdgeInsets.fromLTRB(20.0, 55.0, 20.0, 0),
            padding: EdgeInsets.only(top: 18.0),
            //decoration: BoxDecoration(
            //color: Colors.white,
           // border: Border.all(
           //  color: Colors.red,
           // width: 5,
           // )),


            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Text("Sign up",
                      style: TextStyle(
                        fontFamily: 'Montserrat-Regular',
                        fontSize: 30,
                        fontWeight: FontWeight.bold,

                      ),),
                    SizedBox(height: 20,),
                    Text("Create an account, It's free ",
                      style: TextStyle(
                          fontFamily: 'Montserrat-Regular',
                          fontSize: 15,
                          color:Colors.grey[700]),)


                  ],
                ),

                SizedBox(height: 50.0,),

                Form(
                  key: _formKey,
                  child: Column(

                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: <Widget>[

                      Text(
                        'Email',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color:Colors.black87
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: _mailController,
                        decoration: InputDecoration(
                            prefixIcon: new Icon(Icons.mail,color: Colors.black,),
                            contentPadding: EdgeInsets.symmetric(vertical: 0,
                                horizontal: 10),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                  color: Colors.grey
                              ),

                            ),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)
                            )
                        ),

                        //VALIDATOR FOR EMAIL
                        validator: (value) {

                          bool emailValid =
                          RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value!);

                          if (value.isEmpty ) {
                            return "Please Enter Email Address";
                          }
                          else if(!emailValid){
                            return "Enter Valid Email";
                          }
                          return null;
                        },


                      ),

                      SizedBox(height: 10,),

                      Text(
                        'Password',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color:Colors.black87
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: _passwordController,
                        obscureText: passToggle,
                        decoration: InputDecoration(
                            prefixIcon: new Icon(Icons.lock,color: Colors.black,),
                            contentPadding: EdgeInsets.symmetric(vertical: 0,
                                horizontal: 10),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                  color: Colors.grey
                              ),

                            ),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)
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


                        //value on submit, must return null when everything is okay
                        validator: (value) {

                          if (value == null || value.isEmpty ) {
                            return "Please Enter Password";
                          }
                          else if(_passwordController.text.length <6){
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
                          if (!value.contains(RegExp(r'[!@#\$%^&*()<>?/|}{~:]'))) {
                            return "Password must contain at least one special character";
                          }

                          return null;

                        },

                      ),

                      SizedBox(height: 10,),

                      Text(
                        'Confirm Password',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color:Colors.black87
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: _confirmController,
                        obscureText: confirmToggle,
                        decoration: InputDecoration(
                            prefixIcon: new Icon(Icons.lock,color: Colors.black,),
                            contentPadding: EdgeInsets.symmetric(vertical: 0,
                                horizontal: 10),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                  color: Colors.grey
                              ),

                            ),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)
                            ),

                          suffixIcon: InkWell(
                            onTap: (){
                              setState(() {
                                confirmToggle = !confirmToggle;
                              });

                            },
                            child: Icon(confirmToggle ? Icons.visibility_off : Icons.visibility),
                          ),

                        ),

                        validator: (value) {
                          if(value == null || value.isEmpty) {
                            return "Please Confirm Password";
                          }
                          else if(value != _passwordController.text){
                            return "Password Mismatch";
                          }
                          return null;

                        },

                      ),
                    ],
                  ),
                ),

            SizedBox(height: 20.0,),

                Container(
                  padding: EdgeInsets.only(top: 3, left: 3),
                  child: MaterialButton(
                    minWidth: double.infinity,
                    height: 60,
                    onPressed: () {
                      //Validate returns true if the form is valid.
                      if (_formKey.currentState!.validate()) {
                        _textFieldValue = _mailController.text;
                          initializeArguments();
                          registerWithEmailAndPassword(_mailController.text, _passwordController.text);

                      }



                    },
                    color:Color.fromRGBO(51, 71, 246, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),

                    ),
                    child: Text(
                      "Sign up", style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 24.0,
                      fontFamily: 'Montserrat-Regular',
                      color: Colors.white,

                    ),
                    ),

                  ),


                ),


                SizedBox(height: 30.0,),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Already have an account?",
                      style: TextStyle(
                        fontFamily: 'Montserrat-Regular',
                        fontSize: 15.0,
                      ),),
                    InkWell(
                      onTap: () {

                        Navigator.pushAndRemoveUntil(context,
                            MaterialPageRoute(builder: (context) => LoginPage()),(route) => false);

                      },
                      child: Text(" Log in", style:TextStyle(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat-Regular',
                        color: Color.fromRGBO(51, 71, 246, 1),
                        fontSize: 15.0,
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


  }
}





