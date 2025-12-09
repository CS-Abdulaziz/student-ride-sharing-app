import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

final rideControllerProvider = Provider((ref) => RideController());

class RideController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> requestRide({
    required String pickupAddress,
    required LatLng pickupLatLng,
    required String destinationAddress,
    required LatLng destinationLatLng,
    required String carType,
    required String price,
  }) async {
    try {
      String userId = _auth.currentUser!.uid;

      DocumentReference rideRef = _firestore.collection('rides').doc();

      await rideRef.set({
        'rideId': rideRef.id,
        'passengerId': userId,
        'driverId': null,
        'status': 'pending',
        'pickupAddress': pickupAddress,
        'pickupLat': pickupLatLng.latitude,
        'pickupLng': pickupLatLng.longitude,
        'destinationAddress': destinationAddress,
        'destinationLat': destinationLatLng.latitude,
        'destinationLng': destinationLatLng.longitude,
        'carType': carType,
        'price': price,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return rideRef.id;
    } catch (e) {
      throw "Failed to send request: $e";
    }
  }
}
