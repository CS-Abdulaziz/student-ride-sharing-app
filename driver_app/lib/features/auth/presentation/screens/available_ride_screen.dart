import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'current_ride_screen.dart';
import 'package:driver_app/features/auth/presentation/screens/login_screen.dart';

class AvailableRidesScreen extends StatefulWidget {
  const AvailableRidesScreen({super.key});

  @override
  State<AvailableRidesScreen> createState() => _AvailableRidesScreenState();
}

class _AvailableRidesScreenState extends State<AvailableRidesScreen> {
  Future<void> _acceptRide(String rideId) async {
    try {
      final String currentDriverId = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('rides').doc(rideId).update({
        'status': 'accepted',
        'driverId': currentDriverId,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Ride Accepted! 🚗"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CurrentRideScreen(rideId: rideId),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _rejectRide(String rideId) async {
    try {
      await FirebaseFirestore.instance.collection('rides').doc(rideId).update({
        'status': 'rejected',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Ride Rejected ❌"),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error rejecting ride: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color mainPurpleColor = Color(0xFF9446C2);

    return Scaffold(
      backgroundColor: mainPurpleColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Available Rides",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: "Logout",
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('rides')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.white));
          }
          if (snapshot.hasError) {
            return Center(
                child: Text("Error: ${snapshot.error}",
                    style: const TextStyle(color: Colors.white)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_car_outlined,
                      size: 80, color: Colors.white.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    "No rides available yet",
                    style: TextStyle(
                        fontSize: 18, color: Colors.white.withOpacity(0.9)),
                  ),
                ],
              ),
            );
          }

          final rides = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: rides.length,
            itemBuilder: (context, index) {
              var rideData = rides[index].data() as Map<String, dynamic>;
              String rideId = rides[index].id;

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 5)),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: mainPurpleColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              "${rideData['price'] ?? '--'} SAR",
                              style: const TextStyle(
                                color: mainPurpleColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _rejectRide(rideId),
                            icon: const Icon(Icons.cancel,
                                color: Colors.redAccent, size: 28),
                            tooltip: "Reject Ride",
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildLocationRow(
                        icon: Icons.my_location,
                        iconColor: mainPurpleColor,
                        title: "Pickup Location",
                        address: rideData['pickupAddress'] ?? "Unknown",
                        isLast: false,
                      ),
                      _buildLocationRow(
                        icon: Icons.location_on,
                        iconColor: Colors.redAccent,
                        title: "Drop-off Location",
                        address: rideData['destinationAddress'] ?? "Unknown",
                        isLast: true,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () => _acceptRide(rideId),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainPurpleColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text(
                            "Accept Ride",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLocationRow(
      {required IconData icon,
      required Color iconColor,
      required String title,
      required String address,
      required bool isLast}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(icon, color: iconColor, size: 24),
            if (!isLast)
              Container(
                  width: 2,
                  height: 40,
                  color: Colors.grey.shade300,
                  margin: const EdgeInsets.symmetric(vertical: 4)),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(address,
                  style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              if (!isLast) const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
