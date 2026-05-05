import 'package:flutter/material.dart';
import '../core/colors.dart';

/// Container con bordo "glowy" stile Solo Leveling.
/// Doppio shadow per dare un'aura più ricca rispetto al singolo blur.
class GlowBox extends StatelessWidget {
  final Widget child;
  final Color color;
  final double borderWidth;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;
  final double glowIntensity;

  const GlowBox({
    super.key,
    required this.child,
    this.color = AppColors.blue,
    this.borderWidth = 1,
    this.padding,
    this.margin,
    this.borderRadius,
    this.glowIntensity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: borderRadius ?? BorderRadius.circular(4),
        border: Border.all(
          color: AppColors.alpha(color, 0.7),
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.alpha(color, 0.25 * glowIntensity),
            blurRadius: 18,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: AppColors.alpha(color, 0.1 * glowIntensity),
            blurRadius: 40,
            spreadRadius: 2,
          ),
        ],
      ),
      child: child,
    );
  }
}