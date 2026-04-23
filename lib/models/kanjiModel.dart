import 'vocabModel.dart';
class KanjiModel {
  final String character;
  final String jlpt;
  final List<String> meanings;
  final List<String> onReadings;
  final List<String> kunReadings;
  final int strokeCount;
  final String unicode;
  final List<VocabModel> vocab;
  const KanjiModel({
    required this.character,
    required this.jlpt,
    required this.meanings,
    required this.onReadings,
    required this.kunReadings,
    required this.strokeCount,
    required this.unicode,
    required this.vocab,
  });
  factory KanjiModel.fromJson(Map<String, dynamic> json) => KanjiModel(
    character: json['character'] as String,
    jlpt: json['jlpt'] as String,
    meanings: List<String>.from(json['meanings'] ?? []),
    onReadings: List<String>.from(json['onReadings'] ?? []),
    kunReadings: List<String>.from(json['kunReadings'] ?? []),
    strokeCount: (json['strokeCount'] as num?)?.toInt() ?? 0,
    unicode: json['unicode'] as String? ?? '',
    vocab: (json['vocab'] as List<dynamic>?)?.map((e) => VocabModel.fromJson(e as Map<String, dynamic>)).toList() ?? [],
  );
  Map<String, dynamic> toJson() => {
    'character': character,
    'jlpt': jlpt,
    'meanings': meanings,
    'onReadings': onReadings,
    'kunReadings': kunReadings,
    'strokeCount': strokeCount,
    'unicode': unicode,
    'vocab': vocab.map((v) => v.toJson()).toList(),
  };
  String get primaryMeaning => meanings.isNotEmpty ? meanings.first : '';
  String get onReadingsText => onReadings.join('、');
  String get kunReadingsText => kunReadings.join('、');
}