import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TowTruckListPage extends StatefulWidget {
  @override
  _TowTruckListPageState createState() => _TowTruckListPageState();
}

class _TowTruckListPageState extends State<TowTruckListPage> {
  final DatabaseReference towTrucksRef = FirebaseDatabase.instance.ref().child("towTrucks");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('Tow Truck List'),
      ),
      body: FutureBuilder(
        future: towTrucksRef.once(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No tow trucks available.'));
          }

          Map<dynamic, dynamic> towTrucks = snapshot.data?.snapshot.value as Map<dynamic, dynamic>;

          return ListView.builder(
            itemCount: towTrucks.length,
            itemBuilder: (context, index) {
              String key = towTrucks.keys.elementAt(index);
              Map<dynamic, dynamic> towTruck = towTrucks[key];

              double latitude = towTruck['latitude'];
              double longitude = towTruck['longitude'];
              String name = towTruck['name'];

              return ListTile(
                title: Text(name),
                subtitle: Text('Location: $latitude, $longitude'),
                onTap: () {
                  // Optionally, you can open the map to show the truck's location
                  Navigator.pop(context, LatLng(latitude, longitude));
                },
              );
            },
          );
        },
      ),
    );
  }
}
