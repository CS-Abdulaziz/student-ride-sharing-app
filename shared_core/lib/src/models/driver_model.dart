import 'package:shared_core/src/models/base_user_model.dart';

class DriverModel extends BaseUserModel {

  final String bloodType;
  final DateTime birthOfDate;
  final String address;
  final String bankIBAN;

  DriverModel({

    required super.id,
    required super.userName,
    required super.phoneNumber,
    required super.universityId,
    required this.bloodType,
    required this.birthOfDate,
    required this.address,
    required this.bankIBAN,
  });

  /// Converts the [DriverModel] instance into a JSON map.
  /// This is used when sending data *TO* the server (e.g., during registration).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': userName,
      'universityId': universityId,
      'phoneNumber': phoneNumber,
      'bloodType': bloodType,
      'birthOfDate': birthOfDate.toIso8601String(),
      'address': address,
      'bankIBAN': bankIBAN,
    };
  }

  /// Creates a new [DriverModel] instance from a JSON map.
  /// This is used when receiving data *FROM* the server (e.g., after login).
  factory DriverModel.fromJson(Map<String, dynamic> json) {

    return DriverModel(
      id: json['id'],
      userName: json['name'],
      universityId: json['universityId'], 
      phoneNumber: json['phoneNumber'],
      bloodType: json['bloodType'],
      birthOfDate: DateTime.parse(json['birthOfDate']),
      address: json['address'],
      bankIBAN: json['bankIBAN'],
    );
  }
}
