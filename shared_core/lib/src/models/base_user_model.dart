class BaseUserModel {
  final String id;
  final String userName;
  final String phoneNumber;
  final String universityId;

  BaseUserModel({

    required this.id,
    required this.universityId,
    required this.userName,
    required this.phoneNumber,
  });
}
