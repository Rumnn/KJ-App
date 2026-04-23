import 'package:flutter/material.dart';
import '../appTheme.dart';
class SearchBox extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final String hintText;
  const SearchBox({super.key, required this.onChanged, this.hintText = 'Search Kanji, Meaning...'});
  @override
  State<SearchBox> createState() => _SearchBoxState();
}
class _SearchBoxState extends State<SearchBox> {
  final TextEditingController _ctrl = TextEditingController();
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) => Container(
    height: 48,
    decoration: BoxDecoration(
      color: AppTheme.card,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppTheme.border),
    ),
    child: TextField(
      controller: _ctrl,
      onChanged: widget.onChanged,
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
        prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textMuted, size: 20),
        suffixIcon: _ctrl.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded, color: AppTheme.textMuted, size: 18),
                onPressed: () { _ctrl.clear(); widget.onChanged(''); setState(() {}); },
              )
            : null,
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),
  );
}