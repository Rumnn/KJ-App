import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/vocabJlptModel.dart';

final vocabJlptDataProvider =
    FutureProvider<Map<String, List<VocabJlptModel>>>((ref) async {
  final csv = await rootBundle.loadString('assets/jlpt_vocab.csv');
  final rows = _parseCsv(csv);
  final result = <String, List<VocabJlptModel>>{
    for (final level in _levels) level: [],
  };

  for (var i = 1; i < rows.length; i++) {
    final row = rows[i];
    if (row.length < 4) continue;
    final level = row[3].trim();
    if (!result.containsKey(level)) continue;
    result[level]!.add(
      VocabJlptModel(
        id: i,
        original: row[0].trim(),
        furigana: row[1].trim(),
        english: row[2].trim(),
        level: level,
      ),
    );
  }

  return result;
});

final vocabJlptByLevelProvider =
    Provider.family<AsyncValue<List<VocabJlptModel>>, String>((ref, level) {
  return ref.watch(vocabJlptDataProvider).whenData((data) => data[level] ?? []);
});

const _levels = ['N5', 'N4', 'N3', 'N2', 'N1'];

List<List<String>> _parseCsv(String input) {
  final rows = <List<String>>[];
  var row = <String>[];
  final cell = StringBuffer();
  var inQuotes = false;

  for (var i = 0; i < input.length; i++) {
    final char = input[i];
    final next = i + 1 < input.length ? input[i + 1] : '';

    if (char == '"') {
      if (inQuotes && next == '"') {
        cell.write('"');
        i++;
      } else {
        inQuotes = !inQuotes;
      }
    } else if (char == ',' && !inQuotes) {
      row.add(cell.toString());
      cell.clear();
    } else if ((char == '\n' || char == '\r') && !inQuotes) {
      if (char == '\r' && next == '\n') i++;
      row.add(cell.toString());
      cell.clear();
      if (row.any((value) => value.isNotEmpty)) rows.add(row);
      row = <String>[];
    } else {
      cell.write(char);
    }
  }

  if (cell.isNotEmpty || row.isNotEmpty) {
    row.add(cell.toString());
    if (row.any((value) => value.isNotEmpty)) rows.add(row);
  }

  return rows;
}
