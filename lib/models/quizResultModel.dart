class QuizResultModel {
  final String level;
  final int score;
  final int total;
  final DateTime date;
  const QuizResultModel({required this.level, required this.score, required this.total, required this.date});
  factory QuizResultModel.fromJson(Map<String, dynamic> json) => QuizResultModel(
    level: json['level'] as String,
    score: (json['score'] as num).toInt(),
    total: (json['total'] as num).toInt(),
    date: DateTime.parse(json['date'] as String),
  );
  Map<String, dynamic> toJson() => {
    'level': level,
    'score': score,
    'total': total,
    'date': date.toIso8601String(),
  };
  double get percentage => total == 0 ? 0 : score / total;
}