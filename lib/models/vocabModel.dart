class VocabModel {
  final String kanji;
  final String reading;
  final List<String> meanings;
  final String romanji;
  const VocabModel({
    required this.kanji,
    required this.reading,
    required this.meanings,
    required this.romanji,
  });
  factory VocabModel.fromJson(Map<String, dynamic> json) => VocabModel(
    kanji: json['kanji'] as String? ?? '',
    reading: json['reading'] as String? ?? '',
    meanings: (json['meanings'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    romanji: json['romanji'] as String? ?? '',
  );
  Map<String, dynamic> toJson() => {
    'kanji': kanji,
    'reading': reading,
    'meanings': meanings,
    'romanji': romanji,
  };
}