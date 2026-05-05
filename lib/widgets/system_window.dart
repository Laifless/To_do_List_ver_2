import 'package:flutter/material.dart';
import '../core/colors.dart';

/// Finestra di sistema "alla Solo Leveling": appare con un effetto di
/// scale + glow + scan-line animato. Usata per dialog importanti, level-up,
/// quest accept, etc.
class SystemWindow extends StatefulWidget {
  final Widget child;
  final Color color;
  final double width;
  final EdgeInsets padding;

  const SystemWindow({
    super.key,
    required this.child,
    this.color = AppColors.blue,
    this.width = 320,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  State<SystemWindow> createState() => _SystemWindowState();
}

class _SystemWindowState extends State<SystemWindow>
    with TickerProviderStateMixin {
  late final AnimationController _entryCtrl;
  late final AnimationController _glowCtrl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    )..forward();

    _glowCtrl = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scale = Tween<double>(begin: 0.85, end: 1.0)
        .animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));
    _opacity = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _glow = Tween<double>(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_entryCtrl, _glowCtrl]),
      builder: (_, __) => Opacity(
        opacity: _opacity.value,
        child: Transform.scale(
          scale: _scale.value,
          child: Container(
            width: widget.width,
            decoration: BoxDecoration(
              color: AppColors.black,
              border: Border.all(
                color: AppColors.alpha(widget.color, 0.9),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.alpha(widget.color, _glow.value * 0.5),
                  blurRadius: 30,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: AppColors.alpha(widget.color, _glow.value * 0.2),
                  blurRadius: 60,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Corner brackets stile sci-fi
                ..._cornerBrackets(),
                Padding(padding: widget.padding, child: widget.child),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _cornerBrackets() {
    final c = widget.color;
    const size = 14.0;
    Widget bracket(Alignment alignment) {
      return Align(
        alignment: alignment,
        child: CustomPaint(
          size: const Size(size, size),
          painter: _BracketPainter(c, alignment),
        ),
      );
    }

    return [
      bracket(Alignment.topLeft),
      bracket(Alignment.topRight),
      bracket(Alignment.bottomLeft),
      bracket(Alignment.bottomRight),
    ];
  }
}

class _BracketPainter extends CustomPainter {
  final Color color;
  final Alignment alignment;
  _BracketPainter(this.color, this.alignment);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;
    final path = Path();

    if (alignment == Alignment.topLeft) {
      path.moveTo(0, h);
      path.lineTo(0, 0);
      path.lineTo(w, 0);
    } else if (alignment == Alignment.topRight) {
      path.moveTo(0, 0);
      path.lineTo(w, 0);
      path.lineTo(w, h);
    } else if (alignment == Alignment.bottomLeft) {
      path.moveTo(0, 0);
      path.lineTo(0, h);
      path.lineTo(w, h);
    } else {
      path.moveTo(w, 0);
      path.lineTo(w, h);
      path.lineTo(0, h);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}