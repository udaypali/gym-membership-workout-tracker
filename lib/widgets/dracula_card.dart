import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DraculaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const DraculaCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(16);

    final content = Container(
      decoration: BoxDecoration(
        // inner surface to sit inside the gradient border
        color: AppTheme.surface.withOpacity(0.8),
        borderRadius: borderRadius,
      ),
      child: Padding(padding: padding, child: child),
    );

    final withBorder = Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: borderRadius,
      ),
      child: Container(
        margin: const EdgeInsets.all(1.2), // thin gradient border
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: borderRadius,
        ),
        child: content,
      ),
    );

    return onTap != null
        ? Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: borderRadius,
              onTap: onTap,
              splashColor: AppTheme.accent.withOpacity(0.08),
              highlightColor: Colors.transparent,
              child: withBorder,
            ),
          )
        : withBorder;
  }
}
