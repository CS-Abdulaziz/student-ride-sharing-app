import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'home_page.dart';
import 'cancel_booking_page.dart';

class TrackingPage extends StatelessWidget {
  final String rideId;

  const TrackingPage({Key? key, required this.rideId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("تتبع الرحلة",
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
          if (snapshot.hasError) return Center(child: Text("حدث خطأ"));
          if (!snapshot.hasData || !snapshot.data!.exists)
            return Center(
                child: CircularProgressIndicator(color: Color(0xFF7F00FF)));

          var rideData = snapshot.data!.data() as Map<String, dynamic>;
          String status = rideData['status'] ?? 'pending';

          if (status == 'cancelled') {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cancel, size: 80, color: Colors.red),
                  SizedBox(height: 20),
                  Text("تم إلغاء الرحلة",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
                    child: Text("العودة للرئيسية",
                        style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            );
          }
          // -------------------------------------------------------------

          LatLng pickupLatLng = LatLng(rideData['pickupLat'] ?? 24.7136,
              rideData['pickupLng'] ?? 46.6753);

          return Stack(
            children: [
              FlutterMap(
                options:
                    MapOptions(initialCenter: pickupLatLng, initialZoom: 15.0),
                children: [
                  TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.student_app'),
                  MarkerLayer(markers: [
                    Marker(
                        point: pickupLatLng,
                        width: 40,
                        height: 40,
                        child: Icon(Icons.location_pin,
                            color: Color(0xFF7F00FF), size: 40)),
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
                        Text("جاري البحث عن سائق...",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 15),
                        LinearProgressIndicator(
                            color: Color(0xFF7F00FF),
                            backgroundColor: Colors.grey[200]),
                        SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          CancelBookingPage(rideId: rideId)));
                            },
                            icon: Icon(Icons.close, color: Colors.red),
                            label: Text("إلغاء الطلب",
                                style: TextStyle(color: Colors.red)),
                            style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.red),
                                padding: EdgeInsets.symmetric(vertical: 12)),
                          ),
                        ),
                      ] else if (status == 'accepted') ...[
                        Row(
                          children: [
                            Icon(Icons.check_circle,
                                color: Colors.green, size: 40),
                            SizedBox(width: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("تم قبول الرحلة!",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green)),
                                Text("السائق قادم إليك",
                                    style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ],
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
