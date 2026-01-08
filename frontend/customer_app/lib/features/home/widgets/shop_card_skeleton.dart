import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShopCardSkeleton extends StatelessWidget {
  const ShopCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Placeholder
            Container(height: 150, width: double.infinity, color: Colors.white),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(width: 120, height: 20, color: Colors.white),
                      Container(width: 50, height: 20, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Rating Row
                  Row(
                    children: [
                      Container(width: 40, height: 16, color: Colors.white),
                      const SizedBox(width: 16),
                      Container(width: 80, height: 16, color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
