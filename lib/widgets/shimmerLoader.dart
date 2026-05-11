import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../appTheme.dart';

class ShimmerLoader extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const ShimmerLoader({
    super.key,
    this.width = double.infinity,
    this.height = 80,
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: AppTheme.surfaceContainer,
    highlightColor: AppTheme.surface,
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(radius),
      ),
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
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      childAspectRatio: 0.9,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
    ),
    itemCount: count,
    itemBuilder: (_, __) => const ShimmerLoader(height: 100, radius: 24),
  );
}

class ShimmerListLoader extends StatelessWidget {
  const ShimmerListLoader({super.key});

  @override
  Widget build(BuildContext context) => ListView.builder(
    shrinkWrap: true,
    padding: const EdgeInsets.all(20),
    itemCount: 5,
    itemBuilder: (_, __) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ShimmerLoader(height: 80, radius: 20),
    ),
  );
}