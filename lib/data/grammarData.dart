import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/grammarModel.dart';

final grammarDataProvider =
    FutureProvider<Map<String, List<GrammarModel>>>((ref) async {
  final result = <String, List<GrammarModel>>{};

  for (final level in ['N5', 'N4', 'N3']) {
    final jsonStr =
        await rootBundle.loadString('assets/grammar/grammar_ja_$level.json');
    final list = json.decode(jsonStr) as List<dynamic>;
    result[level] = list
        .whereType<Map<String, dynamic>>()
        .map((e) => GrammarModel.fromJson(e, level))
        .toList();
  }

  return result;
});

final grammarByLevelProvider =
    Provider.family<AsyncValue<List<GrammarModel>>, String>((ref, level) {
  return ref.watch(grammarDataProvider).whenData((data) => data[level] ?? []);
});
