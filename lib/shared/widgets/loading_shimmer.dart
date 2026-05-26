import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';

class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class PropertyCardShimmer extends StatelessWidget {
  const PropertyCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          const ShimmerBox(width: double.infinity, height: 190, borderRadius: 20),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: MediaQuery.of(context).size.width * 0.6, height: 16, borderRadius: 8),
                const SizedBox(height: 8),
                ShimmerBox(width: MediaQuery.of(context).size.width * 0.4, height: 12, borderRadius: 6),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    ShimmerBox(width: 64, height: 26, borderRadius: 8),
                    SizedBox(width: 8),
                    ShimmerBox(width: 64, height: 26, borderRadius: 8),
                    SizedBox(width: 8),
                    ShimmerBox(width: 80, height: 26, borderRadius: 8),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ListShimmer extends StatelessWidget {
  final int count;

  const ListShimmer({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: count,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (_, __) => const PropertyCardShimmer(),
    );
  }
}
