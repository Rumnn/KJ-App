class VocabJlptModel {
  final int id;
  final String original;
  final String furigana;
  final String english;
  final String level;

  const VocabJlptModel({
    required this.id,
    required this.original,
    required this.furigana,
    required this.english,
    required this.level,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'original': original,
        'furigana': furigana,
        'english': english,
        'level': level,
      };
}
