import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'home_page.dart';
import 'cancel_booking_page.dart';
import 'rating_page.dart';
import 'payment_page.dart';

class TrackingPage extends StatelessWidget {
  final String rideId;

  const TrackingPage({Key? key, required this.rideId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('rides')
              .doc(rideId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return Center(child: Text("Error occurred"));
            if (!snapshot.hasData || !snapshot.data!.exists)
              return Center(
                  child: CircularProgressIndicator(color: Color(0xFF6A1B9A)));

            var rideData = snapshot.data!.data() as Map<String, dynamic>;
            String status = rideData['status'] ?? 'pending';
            String? driverId = rideData['driverId'];
            String price = rideData['price'] ?? "15 SAR";

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
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => HomePage()),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF6A1B9A)),
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
                Positioned.fill(
                  child: FlutterMap(
                    options: MapOptions(
                        initialCenter: pickupLatLng, initialZoom: 13.0),
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
                                color: Color(0xFF6A1B9A), size: 35)),
                        Marker(
                            point: destinationLatLng,
                            width: 40,
                            height: 40,
                            child: Icon(Icons.location_on,
                                color: Colors.red, size: 40)),
                      ]),
                    ],
                  ),
                ),
                Positioned(
                  top: 50,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 10)
                        ],
                      ),
                      child: Text("Track Ride",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(25, 10, 25, 50),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(30)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 15,
                            spreadRadius: 2)
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 5,
                          margin: EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        if (status == 'pending') ...[
                          Text("Searching for a driver...",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 15),
                          LinearProgressIndicator(
                              color: Color(0xFF6A1B9A),
                              backgroundColor: Colors.grey[200]),
                          SizedBox(height: 20),
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
                        ] else if ((status == 'accepted' ||
                                status == 'arrived' ||
                                status == 'in_progress') &&
                            driverId != null) ...[
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
                                  if (status == 'arrived')
                                    Text("Driver has Arrived!",
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold))
                                  else if (status == 'in_progress')
                                    Text("Enjoy your ride...",
                                        style: TextStyle(
                                            color: Color(0xFF6A1B9A),
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold))
                                  else
                                    Text("Driver is on the way!",
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold)),
                                  SizedBox(height: 15),
                                  Row(
                                    children: [
                                      CircleAvatar(
                                          radius: 35,
                                          backgroundColor: Colors.grey[200],
                                          child: Icon(Icons.person,
                                              size: 40, color: Colors.black)),
                                      SizedBox(width: 15),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                dData['fullName'] ??
                                                    "Unknown Driver",
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text(
                                                "${dData['vehicleBrand']} • ${dData['vehiclePlate']}",
                                                style: TextStyle(
                                                    color: Colors.grey[700],
                                                    fontSize: 16)),
                                          ],
                                        ),
                                      ),
                                      if (status == 'arrived' ||
                                          status == 'accepted')
                                        IconButton(
                                            onPressed: () {},
                                            icon: Icon(Icons.phone,
                                                color: Colors.green)),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  if (status == 'arrived') ...[
                                    SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => PaymentPage(
                                                  rideId: rideId,
                                                  amount: price),
                                            ),
                                          );
                                        },
                                        icon: Icon(Icons.payment,
                                            color: const Color.fromARGB(
                                                255, 0, 0, 0)),
                                        label: Text("Pay Now to Start",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30)),
                                        ),
                                      ),
                                    ),
                                  ] else if (status == 'in_progress') ...[
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                                  255, 70, 232, 6)
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.check_circle,
                                              size: 20,
                                              color: const Color.fromARGB(
                                                  255, 69, 197, 0)),
                                          SizedBox(width: 5),
                                          Text("Ride Confirmed & Paid"),
                                        ],
                                      ),
                                    )
                                  ]
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
      ),
    );
  }
}
