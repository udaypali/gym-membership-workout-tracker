// A reusable card with a subtle purple-pink gradient border like the screenshot.
import 'package:flutter/material.dart';
import '../theme/colors.dart';

class GradientBorderCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double borderWidth;

  const GradientBorderCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = kRadiusLg,
    this.borderWidth = 1.2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(kRadiusLg)),
        ),
        gradient: kPurplePinkGradient,
      ),
      child: Container(
        margin: EdgeInsets.all(borderWidth),
        decoration: const BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.all(Radius.circular(kRadiusLg - 1)),
        ),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
