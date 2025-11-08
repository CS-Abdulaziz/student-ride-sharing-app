// The structure of login/Registeration class logic (I have to implement it after we add an API/DataBase)

import 'package:shared_core/src/models/driver_model.dart';
import 'package:shared_core/src/models/vehicle_model.dart';

class AuthRepository {
  
  Future<bool> login({

    required String universityId,
    required String password,

  }) async {

    throw UnimplementedError('Login functionality is not implemented yet.');
  }

  Future<bool> registerDriver({

    required DriverModel driverData,
    required VehicleModel vehicleData,
    required String password,

  }) async {

    throw UnimplementedError('Registration functionality is not implemented yet.');
  }
}

