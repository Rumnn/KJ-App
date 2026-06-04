class UserModel {
  final String email;
  final String token;
  final int xp;
  final int points;
  final int quizCount;
  final String role;
  final String status;

  const UserModel({
    required this.email, 
    required this.token,
    this.xp = 0,
    this.points = 0,
    this.quizCount = 0,
    this.role = 'user',
    this.status = 'active',
  });

  bool get isAdmin => role == 'admin';

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        email: json['email'] as String,
        token: json['token'] as String? ?? '',
        xp: json['xp'] as int? ?? 0,
        points: json['points'] as int? ?? 0,
        quizCount: json['quizCount'] as int? ?? 0,
        role: json['role'] as String? ?? 'user',
        status: json['status'] as String? ?? 'active',
      );
}
