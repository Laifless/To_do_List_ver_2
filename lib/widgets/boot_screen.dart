import 'package:flutter/material.dart';
import '../core/colors.dart';

/// Schermata di boot stile terminale: righe che appaiono in sequenza,
/// poi "SYSTEM ONLINE" pulsa e si carica.
class BootScreen extends StatefulWidget {
  const BootScreen({super.key});

  @override
  State<BootScreen> createState() => _BootScreenState();
}

class _BootScreenState extends State<BootScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowCtrl;
  late final Animation<double> _glow;

  final List<String> _lines = [];
  static const _bootSequence = [
    '> initializing hunter system...',
    '> loading quest registry...',
    '> mounting dungeon archive...',
    '> calibrating mana flow...',
    '> SYSTEM ONLINE',
  ];

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
    _runSequence();
  }

  Future<void> _runSequence() async {
    for (final line in _bootSequence) {
      await Future.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;
      setState(() => _lines.add(line));
    }
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _glow,
                builder: (_, __) => Text(
                  'HUNTER SYSTEM',
                  style: TextStyle(
                    color: AppColors.alpha(AppColors.blue, _glow.value),
                    fontSize: 22,
                    letterSpacing: 6,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: AppColors.alpha(AppColors.blue, _glow.value),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.blueDim),
                  color: AppColors.alpha(AppColors.blue, 0.03),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final line in _lines)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          line,
                          style: TextStyle(
                            color: line.contains('ONLINE')
                                ? AppColors.green
                                : AppColors.alpha(AppColors.blue, 0.8),
                            fontFamily: 'monospace',
                            fontSize: 11,
                          ),
                        ),
                      ),
                    if (_lines.length < _bootSequence.length)
                      AnimatedBuilder(
                        animation: _glow,
                        builder: (_, __) => Text(
                          '_',
                          style: TextStyle(
                            color: AppColors.alpha(
                              AppColors.blue,
                              _glow.value,
                            ),
                            fontFamily: 'monospace',
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}