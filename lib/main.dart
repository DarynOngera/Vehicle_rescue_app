import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rescue/Authentication/signup_screen.dart';

import 'Authentication/login_screen.dart';




Future <void> main() async
{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await Permission.locationWhenInUse.isDenied.then((valueOfPermission)
  {
    if(valueOfPermission){
      Permission.locationWhenInUse.request();

    }

  }
  );


  runApp(const MyApp());
}

class MyApp extends StatelessWidget
{
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context)
  {
    return MaterialApp(
      title: 'Rescue',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF6441A5), // Twitch purple
        scaffoldBackgroundColor: Color(0xFF2B3136),
      ),
      darkTheme: ThemeData.dark().copyWith( // Dark mode theme
        primaryColor: Color(0xFF6441A5), // Twitch purple
        scaffoldBackgroundColor: Colors.black,
      ),
      themeMode: ThemeMode.system, // Use system theme by default

      home: LoginScreen(),


    );
  }
}
