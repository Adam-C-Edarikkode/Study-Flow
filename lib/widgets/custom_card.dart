import 'package:flutter/material.dart';
import 'package:study_app/theme/app_theme.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;
  final Color? color;
  final double width;
  final double height;
  final BoxBorder? border;

  const CustomCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding = const EdgeInsets.all(16.0),
    this.gradient,
    this.color,
    this.width = double.infinity,
    this.height = double.infinity,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: width == double.infinity ? null : width,
      height: height == double.infinity ? null : height,
      decoration: BoxDecoration(
        color: color ?? (gradient == null ? Theme.of(context).cardTheme.color : null),
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        border: border,
        boxShadow: [
          isDark ? AppTheme.softShadowDark : AppTheme.softShadowLight,
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
