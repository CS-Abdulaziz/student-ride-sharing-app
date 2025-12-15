import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatelessWidget {
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          "Ride History",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('rides')
            .where('passengerId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error loading data"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: Color(0xFF6A1B9A)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 70, color: Colors.grey[300]),
                SizedBox(height: 10),
                Text("No ride history", style: TextStyle(color: Colors.grey)),
              ],
            ));
          }

          return ListView.builder(
            padding: EdgeInsets.all(15),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var ride =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return _buildRideHistoryCard(ride);
            },
          );
        },
      ),
    );
  }

  Widget _buildRideHistoryCard(Map<String, dynamic> ride) {
    String status = ride['status'] ?? 'pending';
    String? driverId = ride['driverId'];

    Color statusColor;
    String statusText;
    IconData statusIcon;
    Color statusBgColor;

    switch (status) {
      case 'completed':
        statusColor = Colors.green;
        statusBgColor = Colors.green.withOpacity(0.1);
        statusText = "Completed";
        statusIcon = Icons.check_circle;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusBgColor = Colors.red.withOpacity(0.1);
        statusText = "Cancelled";
        statusIcon = Icons.cancel;
        break;
      case 'rejected':
        statusColor = Colors.orange;
        statusBgColor = Colors.orange.withOpacity(0.1);
        statusText = "Rejected";
        statusIcon = Icons.block;
        break;
      case 'accepted':
        statusColor = Colors.blue;
        statusBgColor = Colors.blue.withOpacity(0.1);
        statusText = "Accepted";
        statusIcon = Icons.thumb_up;
        break;
      default:
        statusColor = Colors.amber[700]!;
        statusBgColor = Colors.amber.withOpacity(0.1);
        statusText = "Pending";
        statusIcon = Icons.access_time;
    }

    String dateStr = "";
    if (ride['createdAt'] != null) {
      Timestamp t = ride['createdAt'];
      dateStr = DateFormat('dd MMM - hh:mm a').format(t.toDate());
    }

    return Card(
      margin: EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 1,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(dateStr,
                    style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      SizedBox(width: 5),
                      Text(statusText,
                          style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            Divider(color: Colors.grey[200], height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLocationRow(Icons.circle, ride['pickupAddress'],
                          Color(0xFF6A1B9A)),
                      SizedBox(height: 10),
                      _buildLocationRow(Icons.location_on,
                          ride['destinationAddress'], Colors.red),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  ride['price'] ?? "",
                  style: TextStyle(
                      color: Color(0xFF6A1B9A),
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (driverId != null) ...[
              Divider(height: 25, color: Colors.grey[300]),
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('drivers')
                    .doc(driverId)
                    .get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return SizedBox();

                  if (!snapshot.data!.exists || snapshot.data!.data() == null) {
                    return Text("Driver information unavailable",
                        style: TextStyle(color: Colors.grey, fontSize: 12));
                  }

                  var driver = snapshot.data!.data() as Map<String, dynamic>;
                  String driverName = driver['fullName'] ?? "---";
                  String driverPhone = driver['phone'] ?? "---";
                  String carInfo =
                      "${driver['vehicleBrand'] ?? ''} ${driver['vehicleModel'] ?? ''}";
                  String plate = driver['vehiclePlate'] ?? "---";

                  return Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey[200]!)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person,
                                size: 16, color: Color(0xFF6A1B9A)),
                            SizedBox(width: 5),
                            Text("Driver: $driverName",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13)),
                            Spacer(),
                            Icon(Icons.phone, size: 14, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(driverPhone,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[700])),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(Icons.directions_car,
                                size: 16, color: Colors.black54),
                            SizedBox(width: 5),
                            Text("$carInfo - ", style: TextStyle(fontSize: 13)),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                  color: Colors.black12,
                                  borderRadius: BorderRadius.circular(4)),
                              child: Text(plate,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
            if (status == 'cancelled' || status == 'rejected') ...[
              SizedBox(height: 10),
              Text("Reason: ${ride['cancelReason'] ?? 'Not specified'}",
                  style: TextStyle(color: Colors.red, fontSize: 12)),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow(IconData icon, String? text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Icon(icon, size: 12, color: color),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text ?? "---",
            style: TextStyle(fontSize: 13, color: Colors.grey[800]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
