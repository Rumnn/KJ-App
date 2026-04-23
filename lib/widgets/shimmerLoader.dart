import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../appTheme.dart';
class ShimmerLoader extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  const ShimmerLoader({super.key, this.width = double.infinity, this.height = 80, this.radius = 16});
  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: AppTheme.card,
    highlightColor: AppTheme.cardHover,
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(radius)),
    ),
  );
}
class ShimmerGrid extends StatelessWidget {
  final int count;
  const ShimmerGrid({super.key, this.count = 6});
  @override
  Widget build(BuildContext context) => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    padding: const EdgeInsets.all(16),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 1, crossAxisSpacing: 12, mainAxisSpacing: 12),
    itemCount: count,
    itemBuilder: (_, __) => const ShimmerLoader(height: 100, radius: 16),
  );
}