class UserModel {
  final String email;
  final String token;
  final int xp;
  final int points;
  final int quizCount;

  const UserModel({
    required this.email, 
    required this.token,
    this.xp = 0,
    this.points = 0,
    this.quizCount = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        email: json['email'] as String,
        token: json['token'] as String? ?? '',
        xp: json['xp'] as int? ?? 0,
        points: json['points'] as int? ?? 0,
        quizCount: json['quizCount'] as int? ?? 0,
      );
}
