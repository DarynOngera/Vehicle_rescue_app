import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AddTowTruckPage extends StatefulWidget {
  @override
  _AddTowTruckPageState createState() => _AddTowTruckPageState();
}

class _AddTowTruckPageState extends State<AddTowTruckPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController driverNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();
  TextEditingController statusController = TextEditingController();

  final DatabaseReference towTrucksRef = FirebaseDatabase.instance.ref().child("towTrucks");

  // Function to add a new tow truck to Firebase
  void addTowTruck() {
    String name = nameController.text.trim();
    String driverName = driverNameController.text.trim();
    String phone = phoneController.text.trim();
    double latitude = double.parse(latitudeController.text.trim());
    double longitude = double.parse(longitudeController.text.trim());
    String status = statusController.text.trim();

    // Create a new tow truck object with the provided data
    String towTruckId = towTrucksRef.push().key!;  // Firebase will generate a unique ID for the new truck

    Map<String, dynamic> towTruckData = {
      'name': name,
      'driverName': driverName,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
    };

    // Store the new tow truck data in Firebase
    towTrucksRef.child(towTruckId).set(towTruckData).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Tow Truck added successfully")));
      Navigator.pop(context);  // Go back to the previous page after adding the truck
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to add Tow Truck: $error")));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('Add Tow Truck'),

      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Tow Truck Name"),
            ),
            TextField(
              controller: driverNameController,
              decoration: InputDecoration(labelText: "Driver Name"),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: "Driver Phone"),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: latitudeController,
              decoration: InputDecoration(labelText: "Latitude"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: longitudeController,
              decoration: InputDecoration(labelText: "Longitude"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: statusController,
              decoration: InputDecoration(labelText: "Status (Available/On Duty/etc.)"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: addTowTruck,
              child: Text('Add Tow Truck'),
            ),
          ],
        ),
      ),
    );
  }
}
