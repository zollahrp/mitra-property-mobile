import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class PropertySkeleton extends StatelessWidget {
  const PropertySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _line(width: 80, height: 16),
                  const SizedBox(height: 8),
                  _line(width: 120, height: 14),
                  const SizedBox(height: 6),
                  _line(width: double.infinity, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _line({double width = double.infinity, double height = 12}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
