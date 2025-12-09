import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'home_page.dart';
import 'cancel_booking_page.dart';
import 'rating_page.dart';

class TrackingPage extends StatelessWidget {
  final String rideId;

  const TrackingPage({Key? key, required this.rideId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Track Ride",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('rides')
            .doc(rideId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Error occurred"));
          if (!snapshot.hasData || !snapshot.data!.exists)
            return Center(
                child: CircularProgressIndicator(color: Color(0xFF7F00FF)));

          var rideData = snapshot.data!.data() as Map<String, dynamic>;
          String status = rideData['status'] ?? 'pending';
          String? driverId = rideData['driverId'];

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (status == 'cancelled') {
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => HomePage()),
                  (route) => false,
                );
              }
            } else if (status == 'completed') {
              if (context.mounted) {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => RatingPage(rideId: rideId)));
              }
            }
          });

          if (status == 'cancelled') return Container(color: Colors.white);

          if (status == 'rejected') {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cancel_presentation,
                      size: 80, color: Colors.orange),
                  SizedBox(height: 20),
                  Text("Sorry, Driver rejected your request",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Text("Redirecting to home...",
                      style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => HomePage()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF7F00FF)),
                    child: Text("Back to Home",
                        style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            );
          }

          LatLng pickupLatLng = LatLng(rideData['pickupLat'] ?? 24.7136,
              rideData['pickupLng'] ?? 46.6753);
          LatLng destinationLatLng = LatLng(
              rideData['destinationLat'] ?? 24.7136,
              rideData['destinationLng'] ?? 46.6753);

          return Stack(
            children: [
              FlutterMap(
                options:
                    MapOptions(initialCenter: pickupLatLng, initialZoom: 13.0),
                children: [
                  TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.student_app'),
                  PolylineLayer(polylines: [
                    Polyline(
                        points: [pickupLatLng, destinationLatLng],
                        strokeWidth: 4.0,
                        color: Colors.blue)
                  ]),
                  MarkerLayer(markers: [
                    Marker(
                        point: pickupLatLng,
                        width: 40,
                        height: 40,
                        child: Icon(Icons.my_location,
                            color: Color(0xFF7F00FF), size: 35)),
                    Marker(
                        point: destinationLatLng,
                        width: 40,
                        height: 40,
                        child: Icon(Icons.location_on,
                            color: Colors.red, size: 40)),
                  ]),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30)),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 15)
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (status == 'pending') ...[
                        Text("Searching for a driver...",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 15),
                        LinearProgressIndicator(
                            color: Color(0xFF7F00FF),
                            backgroundColor: Colors.grey[200]),
                        SizedBox(height: 15),
                        OutlinedButton.icon(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      CancelBookingPage(rideId: rideId))),
                          icon: Icon(Icons.close, color: Colors.red),
                          label: Text("Cancel Request",
                              style: TextStyle(color: Colors.red)),
                        ),
                      ] else if (status == 'accepted' && driverId != null) ...[
                        FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('drivers')
                              .doc(driverId)
                              .get(),
                          builder: (context, driverSnapshot) {
                            if (!driverSnapshot.hasData)
                              return LinearProgressIndicator();
                            var dData = driverSnapshot.data!.data()
                                    as Map<String, dynamic>? ??
                                {};
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                        radius: 30,
                                        backgroundColor: Colors.grey[200],
                                        child: Icon(Icons.person,
                                            size: 35, color: Colors.black)),
                                    SizedBox(width: 15),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("Driver is on the way!",
                                              style: TextStyle(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold)),
                                          Text(
                                              dData['fullName'] ??
                                                  "Unknown Driver",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold)),
                                          Text(
                                              "${dData['vehicleBrand']} • ${dData['vehiclePlate']}",
                                              style: TextStyle(
                                                  color: Colors.grey[700])),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
