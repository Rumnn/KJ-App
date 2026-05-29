class GrammarExampleModel {
  final String jp;
  final String romaji;
  final String vn;

  const GrammarExampleModel({
    required this.jp,
    required this.romaji,
    required this.vn,
  });

  factory GrammarExampleModel.fromJson(Map<String, dynamic> json) =>
      GrammarExampleModel(
        jp: json['jp'] as String? ?? '',
        romaji: json['romaji'] as String? ?? '',
        vn: json['vn'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'jp': jp,
        'romaji': romaji,
        'vn': vn,
      };
}

class GrammarModel {
  final String level;
  final String title;
  final String shortExplanation;
  final String longExplanation;
  final String formation;
  final List<GrammarExampleModel> examples;

  const GrammarModel({
    required this.level,
    required this.title,
    required this.shortExplanation,
    required this.longExplanation,
    required this.formation,
    required this.examples,
  });

  factory GrammarModel.fromJson(Map<String, dynamic> json, String level) =>
      GrammarModel(
        level: level,
        title: json['title'] as String? ?? '',
        shortExplanation: json['short_explanation'] as String? ?? '',
        longExplanation: json['long_explanation'] as String? ?? '',
        formation: json['formation'] as String? ?? '',
        examples: (json['examples'] as List<dynamic>?)
                ?.whereType<Map<String, dynamic>>()
                .map(GrammarExampleModel.fromJson)
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'level': level,
        'title': title,
        'short_explanation': shortExplanation,
        'long_explanation': longExplanation,
        'formation': formation,
        'examples': examples.map((e) => e.toJson()).toList(),
      };
}
