class VehicleModel {

  final String id; // Unique id for each Vehicle in the database.
  final String driverId; // Uses for mapping the driver with his car.

  final String carType;
  final int yearOfManufacture;
  final String color;
  final int seatsNumber;
  final String carPlate;

  VehicleModel({

    required this.id,
    required this.driverId,
    required this.carType,
    required this.yearOfManufacture,
    required this.color,
    required this.seatsNumber,
    required this.carPlate
  });

  /// Converts the [VehicleModel] instance into a JSON map.
  /// This is used when sending data *TO* the server (e.g., during registration).
  Map<String, dynamic> toJson() {

    return {
      'id': id,
      'driverId': driverId,
      'carType': carType,
      'yearOfManufacture': yearOfManufacture,
      'color': color,
      'seatsNumber': seatsNumber,
      'carPlate': carPlate,
    };
  }

  /// Creates a new [VehicleModel] instance from a JSON map.
  /// This is used when receiving data *FROM* the server (e.g., after login).
  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'],
      driverId: json['driverId'],
      carType: json['carType'],
      yearOfManufacture: json['yearOfManufacture'],
      color: json['color'],
      seatsNumber: json['seatsNumber'],
      carPlate: json['carPlate'],
    );
  }
}
