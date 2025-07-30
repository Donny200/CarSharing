class UserModel {
  final String phoneNumber;
  final String passportNumber;
  final String pinfl;
  final String licenseCategory;
  final String? licenseImagePath;

  UserModel({
    required this.phoneNumber,
    required this.passportNumber,
    required this.pinfl,
    required this.licenseCategory,
    this.licenseImagePath,
  });
}
