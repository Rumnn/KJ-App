class UserModel {
  final String email;
  final String token;
  const UserModel({required this.email, required this.token});
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    email: json['email'] as String,
    token: json['token'] as String,
  );
}