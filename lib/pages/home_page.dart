import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'addtrucks.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GoogleMapController? mapController;
  Set<Marker> _markers = {};
  late LatLng _userLocation;
  bool _isLocationLoaded = false;

  final DatabaseReference towTrucksRef = FirebaseDatabase.instance.ref().child("towTrucks");
  final DatabaseReference sosRef = FirebaseDatabase.instance.ref().child("sos_requests");

  // Function to get the user's current location and add the marker
  void _setCurrentLocation(LatLng userLocation) {
    setState(() {
      _userLocation = userLocation;
      _isLocationLoaded = true;
      _markers.add(Marker(
        markerId: MarkerId("current_user"),
        position: _userLocation,
        infoWindow: InfoWindow(title: "Your Location"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ));
    });

    if (mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _userLocation,
            zoom: 14.0,
          ),
        ),
      );
    }
  }

  // Function to get tow truck locations from Firebase
  void getTowTruckLocations() {
    towTrucksRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> towTrucks = event.snapshot.value as Map<dynamic, dynamic>;

        // Clear existing markers before adding new ones
        _markers.clear();

        if (_isLocationLoaded) {
          _markers.add(Marker(
            markerId: MarkerId("current_user"),
            position: _userLocation,
            infoWindow: InfoWindow(title: "Your Location"),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          ));
        }

        towTrucks.forEach((key, value) {
          double latitude = value['latitude'];
          double longitude = value['longitude'];
          String name = value['name'];

          _markers.add(Marker(
            markerId: MarkerId(key),
            position: LatLng(latitude, longitude),
            infoWindow: InfoWindow(title: name),
          ));
        });

        setState(() {});
      }
    });
  }

  // Function to send SOS notification and alert nearby tow trucks
  void _sendSOS() async {
    // Get user's current location
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    LatLng currentLatLng = LatLng(position.latitude, position.longitude);

    // Save the SOS request to Firebase
    String sosId = "sos_${DateTime.now().millisecondsSinceEpoch}";
    sosRef.push().set({
      "user_id": "user_${DateTime.now().millisecondsSinceEpoch}",  // Replace with actual user ID
      "latitude": currentLatLng.latitude,
      "longitude": currentLatLng.longitude,
      "timestamp": DateTime.now().toIso8601String(),
      "sos_id": sosId,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('SOS sent!')));

      // Add SOS marker to the map
      setState(() {
        _markers.add(Marker(
          markerId: MarkerId(sosId),
          position: currentLatLng,
          infoWindow: InfoWindow(title: "SOS Request"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),  // Red color for SOS
        ));
      });

      // Send alert to nearby tow trucks
      _alertNearbyTowTrucks(currentLatLng, sosId);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send SOS')));
    });
  }

  // Function to alert nearby tow trucks
  void _alertNearbyTowTrucks(LatLng sosLocation, String sosId) {
    towTrucksRef.once().then((event) {
      Map<dynamic, dynamic> towTrucks = event.snapshot.value as Map<dynamic, dynamic>;
      towTrucks.forEach((key, value) {
        double truckLat = value['latitude'];
        double truckLng = value['longitude'];

        // Calculate the distance to the tow truck
        double distance = Geolocator.distanceBetween(sosLocation.latitude, sosLocation.longitude, truckLat, truckLng);

        if (distance < 10000) {  // Only alert if the tow truck is within 10 km
          // Send a notification to the tow truck (This can be a Firebase message or update in database)
          towTrucksRef.child(key).update({
            'alert': 'New SOS request within 10 km at location: $sosLocation',
          });
        }
      });
    });
  }

  // Listen for new SOS requests and add markers to the map in real-time
  void _listenForSOSRequests() {
    sosRef.onChildAdded.listen((event) {
      // Check if the snapshot data exists
      if (event.snapshot.value != null) {
        var sosData = event.snapshot.value;

        // Make sure sosData contains the necessary fields before accessing
        if (sosData is Map<dynamic, dynamic>) {
          double? latitude = sosData['latitude'];
          double? longitude = sosData['longitude'];

          // Ensure latitude and longitude are not null
          if (latitude != null && longitude != null) {
            LatLng sosLocation = LatLng(latitude, longitude);

            setState(() {
              _markers.add(Marker(
                markerId: MarkerId("sos_${event.snapshot.key}"),
                position: sosLocation,
                infoWindow: InfoWindow(title: "SOS Request"),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              ));
            });
          } else {
            // Handle case where latitude or longitude is missing
            print("SOS request missing latitude or longitude.");
          }
        } else {
          print("SOS data is not in the expected format.");
        }
      } else {
        print("No SOS data found.");
      }
    });
  }


  @override
  void initState() {
    super.initState();
    _setCurrentLocation(LatLng(37.7749, -122.4194)); // Example location, replace with actual
    getTowTruckLocations(); // Load tow truck data from Firebase
    _listenForSOSRequests(); // Listen for new SOS requests in real-time
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tow Trucks Map'),
      ),
      body: _isLocationLoaded
          ? GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _userLocation,
          zoom: 14.0,
        ),
        myLocationEnabled: true,
        markers: _markers,
      )
          : Center(child: CircularProgressIndicator()),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _sendSOS,
            child: Icon(Icons.warning),
            backgroundColor: Colors.red,
            tooltip: 'Send SOS',
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddTowTruckPage()),
              );
            },
            child: Icon(Icons.add),
            tooltip: 'Add Tow Truck',
          ),
        ],
      ),
    );
  }
}
