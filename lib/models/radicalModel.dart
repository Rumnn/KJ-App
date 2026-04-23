class RadicalModel {
  final String character;
  final String meaning;
  final int strokes;
  const RadicalModel({required this.character, required this.meaning, required this.strokes});
  factory RadicalModel.fromJson(Map<String, dynamic> json) => RadicalModel(
    character: json['character'] as String? ?? '',
    meaning: json['meaning'] as String? ?? '',
    strokes: (json['strokes'] as num?)?.toInt() ?? 0,
  );
  Map<String, dynamic> toJson() => {'character': character, 'meaning': meaning, 'strokes': strokes};
}