import 'package:rescue/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';


class ProfilePage extends StatefulWidget {
  final User user;

  ProfilePage({required this.user});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController userNameTextEditingController = TextEditingController();
  TextEditingController userPhoneTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController mpesaNumberTextEditingController = TextEditingController();
  TextEditingController paypalEmailTextEditingController = TextEditingController();
  bool isEditing = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    // Fetching the current user's info from Firebase
    DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users").child(widget.user.uid);
    userRef.once().then((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.exists) {
        Map data = snapshot.value as Map;
        userNameTextEditingController.text = data['name'] ?? '';
        userPhoneTextEditingController.text = data['phone'] ?? '';
        emailTextEditingController.text = data['email'] ?? '';
        mpesaNumberTextEditingController.text = data['mpesaNumber'] ?? '';
        paypalEmailTextEditingController.text = data['paypalEmail'] ?? '';
        setState(() {});
      }
    }).catchError((error) {
      print("Error fetching user data: $error");
    });
  }

  void saveProfile() {
    setState(() {
      isLoading = true;
    });

    DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users").child(widget.user.uid);

    userRef.update({
      "name": userNameTextEditingController.text,
      "phone": userPhoneTextEditingController.text,
      "email": emailTextEditingController.text,
      "mpesaNumber": mpesaNumberTextEditingController.text,
      "paypalEmail": paypalEmailTextEditingController.text,
    }).then((_) {
      setState(() {
        isEditing = false;
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully')));
    }).catchError((error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update profile')));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isEditing)
                ...[
                  buildTextField('Name', userNameTextEditingController, Icons.person),
                  buildTextField('Phone', userPhoneTextEditingController, Icons.phone),
                  buildTextField('Email', emailTextEditingController, Icons.email),
                  buildTextField('MPesa Number', mpesaNumberTextEditingController, Icons.phone_android),
                  buildTextField('PayPal Email', paypalEmailTextEditingController, Icons.email),
                ]
              else
                ...[
                  buildProfileTextWithIcon('Name:', userNameTextEditingController.text, Icons.person),
                  buildProfileTextWithIcon('Phone:', userPhoneTextEditingController.text, Icons.phone),
                  buildProfileTextWithIcon('Email:', emailTextEditingController.text, Icons.email),
                  buildProfileTextWithIcon('MPesa Number:', mpesaNumberTextEditingController.text, Icons.phone_android),
                  buildProfileTextWithIcon('PayPal Email:', paypalEmailTextEditingController.text, Icons.email),
                ],
              SizedBox(height: 24),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Column(
                children: [
                  buildActionButton(
                    isEditing ? 'Save Changes' : 'Edit Profile',
                    onPressed: () {
                      if (isEditing) {
                        saveProfile();
                      } else {
                        setState(() {
                          isEditing = true;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  buildActionButton(
                    'Go to Home Page',
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePage(), // Pass the user object
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.green),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green, width: 2.0),
            borderRadius: BorderRadius.circular(12.0),
          ),
          prefixIcon: Icon(icon, color: Colors.green),
          contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        ),
      ),
    );
  }

  Widget buildProfileTextWithIcon(String label, String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.green),
          SizedBox(width: 8),
          Text(
            '$label $text',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget buildActionButton(String text, {required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text, style: TextStyle(fontSize: 16.0)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: EdgeInsets.symmetric(vertical: 14.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 5,
      ),
    );
  }
}
