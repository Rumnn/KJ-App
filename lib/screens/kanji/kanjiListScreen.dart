import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../providers/kanjiProvider.dart';
import '../../widgets/shimmerLoader.dart';
import '../../widgets/kanjiCard.dart';
import '../../widgets/searchBox.dart';
import '../../appTheme.dart';
final _levelColors = {
  'N5': AppTheme.jlptColors[0], 'N4': AppTheme.jlptColors[1],
  'N3': AppTheme.jlptColors[2], 'N2': AppTheme.jlptColors[3], 'N1': AppTheme.jlptColors[4],
};
class KanjiListScreen extends ConsumerStatefulWidget {
  final String level;
  const KanjiListScreen({super.key, required this.level});
  @override
  ConsumerState<KanjiListScreen> createState() => _KanjiListScreenState();
}
class _KanjiListScreenState extends ConsumerState<KanjiListScreen> {
  @override
  Widget build(BuildContext context) {
    final color = _levelColors[widget.level] ?? AppTheme.accent;
    final isGrid = ref.watch(viewModeProvider);
    final kanjiAsync = ref.watch(filteredKanjiProvider(widget.level));
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.level, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 22)),
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20)),
        actions: [
          IconButton(
            icon: Icon(isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded, color: AppTheme.textSecondary),
            onPressed: () => ref.read(viewModeProvider.notifier).toggle(),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SearchBox(
                onChanged: (v) => ref.read(searchQueryProvider.notifier).updateQuery(v),
                hintText: 'Search ${widget.level} Kanji...',
              ),
            ),
          ),
          kanjiAsync.when(
            loading: () => const SliverToBoxAdapter(child: ShimmerGrid()),
            error: (e, _) => SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(20), child: Text('Error: $e', style: const TextStyle(color: AppTheme.error)))),
            data: (list) => isGrid
              ? SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => KanjiCard(
                      kanji: list[i],
                      levelColor: color,
                      onTap: () => context.push('/home/kanji/${widget.level}/detail/${list[i].character}'),
                    ),
                    childCount: list.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 0.88, crossAxisSpacing: 10, mainAxisSpacing: 10),
                ),
              )
              : SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => KanjiListTile(
                      kanji: list[i],
                      levelColor: color,
                      onTap: () => context.push('/home/kanji/${widget.level}/detail/${list[i].character}'),
                    ),
                    childCount: list.length,
                  ),
                ),
              ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}