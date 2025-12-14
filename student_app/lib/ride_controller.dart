import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

final rideControllerProvider = Provider((ref) => RideController());

class RideController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _cancelPreviousPendingRides(String userId) async {
    QuerySnapshot previousRides = await _firestore
        .collection('rides')
        .where('passengerId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .get();

    if (previousRides.docs.isNotEmpty) {
      WriteBatch batch = _firestore.batch();
      for (var doc in previousRides.docs) {
        batch.update(doc.reference, {
          'status': 'cancelled',
          'cancelReason': 'Auto-cancelled: New ride requested.',
          'cancelledAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
      print("Cancelled ${previousRides.docs.length} previous pending rides.");
    }
  }

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

      await _cancelPreviousPendingRides(userId);

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
