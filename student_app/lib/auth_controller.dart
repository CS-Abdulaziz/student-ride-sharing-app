import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authControllerProvider = Provider((ref) => AuthController());

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _generateEmail(String universityId) {
    return "$universityId@student.app";
  }

  Future<void> signUp({
    required String name,
    required String universityId,
    required String phone,
    required String password,
  }) async {
    try {
      print("Starting Sign Up for $universityId...");
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _generateEmail(universityId),
        password: password,
      );
      print("User Created in Auth: ${userCredential.user!.uid}");

      print("Trying to save to Firestore...");
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name': name,
        'universityId': universityId,
        'phone': phone,
        'role': 'student',
        'createdAt': DateTime.now(),
      });
      print("Data Saved Successfully!");
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "An error occurred during registration";
    } catch (e) {
      print("ERROR IN FIRESTORE: $e");
      throw "Firestore Error: $e";
    }
  }

  Future<void> login({
    required String universityId,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _generateEmail(universityId),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = '';

      switch (e.code) {
        case 'invalid-credential':
        case 'user-not-found':
        case 'wrong-password':
          errorMessage = "Incorrect University ID or Password.";
          break;
        case 'user-disabled':
          errorMessage = "This account has been disabled.";
          break;
        case 'too-many-requests':
          errorMessage = "Too many failed attempts. Please try again later.";
          break;
        case 'network-request-failed':
          errorMessage =
              "Network error. Please check your internet connection.";
          break;
        default:
          errorMessage = "Login failed. Please try again.";
      }

      throw errorMessage;
    } catch (e) {
      throw "An unexpected error occurred. Please try again.";
    }
  }
}
