import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:rescue/methods/common_methods.dart';
import 'package:rescue/pages/home_page.dart';
import 'package:rescue/pages/profile_page.dart';
import 'package:rescue/widgets/loading_dialog.dart';

import 'login_screen.dart';


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
{
  TextEditingController userNameTextEditingController = TextEditingController();
  TextEditingController userPhoneTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  CommonMethods cMethods = CommonMethods();

  checkIfNetIsAvailable()
  {


    signUpValidation(context);

  }
  signUpValidation(BuildContext context) {
    String userName = userNameTextEditingController.text.trim();
    String userPhone = userPhoneTextEditingController.text.trim();
    String email = emailTextEditingController.text.trim();

    // Username validation
    if (userName.isEmpty) {
      cMethods.displaySnackBar("Name cannot be empty", context);
    } else if (userName.length < 4) {
      cMethods.displaySnackBar("Name should be at least 4 characters long", context);
    } else if (!RegExp(r"^[a-zA-Z0-9_]+$").hasMatch(userName)) {
      cMethods.displaySnackBar("Name can only contain letters, numbers, and underscores", context);
    }
    // Phone number validation
    else if (userPhone.isEmpty) {
      cMethods.displaySnackBar("Phone number cannot be empty", context);
    } else if (!RegExp(r"^\d{10}$").hasMatch(userPhone)) {
      cMethods.displaySnackBar("Phone number must be 10 digits long", context);
    }
    // Email address validation
    else if (email.isEmpty) {
      cMethods.displaySnackBar("Email address cannot be empty", context);
    } else if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(email)) {
      cMethods.displaySnackBar("Invalid email address format", context);
    } else {
      // Validation passed
      cMethods.displaySnackBar("Validation successful!", context);
      registerNewUser();
    }
  }

  registerNewUser() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => LoadingDialog(messageText: "Account registration"),
    );

    final User? userFirebase = (
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailTextEditingController.text.trim(),
        password: passwordTextEditingController.text.trim()
      ).catchError((errorMsg)
      {
        cMethods.displaySnackBar(errorMsg, context);
      }
      )
    ).user;
    if(!context.mounted) return;
    Navigator.pop(context);

    DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("users").child(userFirebase!.uid);

    Map userDataMap = {
      "name": userNameTextEditingController,
      "email": emailTextEditingController,
      "phone": userPhoneTextEditingController,
      "id":userFirebase.uid,
      "blockStatus": "no",

    };

    usersRef.set(userDataMap);

    Navigator.push(context, MaterialPageRoute(builder: (c)=> ProfilePage(user: userFirebase,) ));

  }


  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: SingleChildScrollView(
        child:Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [

                Image.asset(
                  "assets/images/logo.png"
                ),
                const Text(
                  "Create a User\'s Account",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight:FontWeight.bold,
                  ),
                ),
                 //Text fields + button
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [

                      TextField(
                        controller: userNameTextEditingController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: "User Name",
                          labelStyle: TextStyle(
                            fontSize: 14,
                          ),

                        ),
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 22,),

                      TextField(
                        controller: userPhoneTextEditingController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: "Phone Number",
                          labelStyle: TextStyle(
                            fontSize: 14,
                          ),

                        ),
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 22,),

                      TextField(
                        controller: emailTextEditingController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: "User Email",
                          labelStyle: TextStyle(
                            fontSize: 14,
                          ),

                        ),
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 22,),


                      TextField(
                        controller: passwordTextEditingController,
                        obscureText: true,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: "User Password",
                          labelStyle: TextStyle(
                            fontSize: 14,
                          ),

                        ),
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      ),

                      ElevatedButton(
                          onPressed:()
                              {
                                checkIfNetIsAvailable();

                              },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            padding: EdgeInsets.symmetric(horizontal: 80, vertical: 10)
                          ),
                        child: const Text(
                          "Sign Up"
                        ),
                      )
                    ],
                  ),

                ),


                const SizedBox(height: 12,),

                //text button
                TextButton(
                  onPressed: ()
                  {
                    Navigator.push(context, MaterialPageRoute(builder: (c) => LoginScreen()));
                  },

                  child: const Text(
                    "Already have an account?,Log in",
                    style: TextStyle(
                      color: Colors.purpleAccent,
                    ),
                  ),
                ),



              ],
            ),
        )
      )
    );
  }
}
