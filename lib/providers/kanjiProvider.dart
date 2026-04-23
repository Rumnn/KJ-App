import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/kanjiModel.dart';
import '../data/kanjiData.dart';
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void updateQuery(String q) => state = q;
}
final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);
class ViewModeNotifier extends Notifier<bool> {
  @override
  bool build() => true;
  void toggle() => state = !state;
}
final viewModeProvider = NotifierProvider<ViewModeNotifier, bool>(ViewModeNotifier.new);
final filteredKanjiProvider = Provider.family<AsyncValue<List<KanjiModel>>, String>((ref, level) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  return ref.watch(kanjiByLevelProvider(level)).whenData((list) {
    if (query.isEmpty) return list;
    return list.where((k) =>
      k.character.contains(query) ||
      k.meanings.any((m) => m.toLowerCase().contains(query)) ||
      k.onReadings.any((r) => r.toLowerCase().contains(query)) ||
      k.kunReadings.any((r) => r.toLowerCase().contains(query))
    ).toList();
  });
});