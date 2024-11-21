import 'package:flutter/material.dart';
import 'package:rescue/Authentication/signup_screen.dart';


class LoginScreen extends StatefulWidget
{
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {


  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();


  @override
  Widget build(BuildContext context) {
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
                    "Login",
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

                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: EdgeInsets.symmetric(horizontal: 80, vertical: 10)
                          ),
                          child: const Text(
                              "Log In"
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
                      Navigator.push(context, MaterialPageRoute(builder: (c) => SignupScreen()));
                    },

                    child: const Text(
                      " Don\'t have an account? Sign up",
                      style: TextStyle(
                        color: Colors.greenAccent,
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
