import 'package:flutter/material.dart';
import '../core/colors.dart';

class GlowFAB extends StatefulWidget {
  final VoidCallback onPressed;
  const GlowFAB({super.key, required this.onPressed});

  @override
  State<GlowFAB> createState() => _GlowFABState();
}

class _GlowFABState extends State<GlowFAB>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _anim,
    builder: (_, __) => Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.alpha(AppColors.blue, _anim.value * 0.6),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: FloatingActionButton(
        backgroundColor: AppColors.blue,
        onPressed: widget.onPressed,
        child: const Icon(Icons.add, color: Colors.black, size: 28),
      ),
    ),
  );
}