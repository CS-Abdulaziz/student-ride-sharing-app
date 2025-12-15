// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import 'package:shared_core/shared_core.dart';

// abstract class LoginState {}

// class LoginInitial extends LoginState {}

// class LoginLoading extends LoginState {}

// class LoginSuccess extends LoginState {}

// class LoginFailure extends LoginState {
//   final String errorMessage;
//   LoginFailure(this.errorMessage);
// }

// class LoginCubit extends Cubit<LoginState> {
//   final AuthRepository _authRepository;

//   LoginCubit(this._authRepository) : super(LoginInitial());

//   Future<void> login({
//     required String universityId,
//     required String password,
//   }) async {
//     try {
//       emit(LoginLoading());
//       final bool didLogin = await _authRepository.login(
//         universityId: universityId,
//         password: password,
//       );

//       if (didLogin) {
//         emit(LoginSuccess());
//       } else {
//         emit(LoginFailure('Invalid credentials.'));
//       }
//     } catch (e) {
//       emit(LoginFailure('An error occurred: $e'));
//     }
//   }
// }
