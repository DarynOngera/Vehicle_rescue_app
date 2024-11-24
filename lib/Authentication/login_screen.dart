import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rescue/Authentication/signup_screen.dart';
import 'package:rescue/pages/home_page.dart';
import 'package:rescue/pages/profile_page.dart';
import 'package:rescue/widgets/loading_dialog.dart';
import 'package:rescue/methods/common_methods.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  CommonMethods cMethods = CommonMethods();

  // Function to handle login
  Future<void> loginUser(BuildContext context) async {
    String email = emailTextEditingController.text.trim();
    String password = passwordTextEditingController.text.trim();

    // Validate email and password fields
    if (email.isEmpty) {
      cMethods.displaySnackBar("Email cannot be empty", context);
      return;
    } else if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(email)) {
      cMethods.displaySnackBar("Invalid email address format", context);
      return;
    } else if (password.isEmpty) {
      cMethods.displaySnackBar("Password cannot be empty", context);
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => LoadingDialog(messageText: "Logging in..."),
    );

    // Sign in with Firebase Auth
    try {
      User? user = (await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      )).user;

      if (user != null) {
        // Hide the loading dialog after successful login
        Navigator.pop(context);

        // Navigate to the home page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage(user: user,)),
        );
      }
    } catch (e) {
      // Hide the loading dialog if there's an error
      Navigator.pop(context);

      // Display error message
      cMethods.displaySnackBar("Login failed. Please check your credentials.", context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Image.asset("assets/images/logo.png"),
              const Text(
                "Login",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Text fields + buttons
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    TextField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "User Email",
                        labelStyle: const TextStyle(fontSize: 14),
                      ),
                      style: const TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: passwordTextEditingController,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: "User Password",
                        labelStyle: const TextStyle(fontSize: 14),
                      ),
                      style: const TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                    const SizedBox(height: 22),
                    ElevatedButton(
                      onPressed: () {
                        loginUser(context); // Call the login function
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 10),
                      ),
                      child: const Text("Log In"),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Text button for navigating to Signup screen
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => const SignupScreen()),
                  );
                },
                child: const Text(
                  " Don\'t have an account? Sign up",
                  style: TextStyle(color: Colors.greenAccent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
