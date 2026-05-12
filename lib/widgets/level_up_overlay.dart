import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/haptics.dart';
import '../models/hunter_rank.dart';

class LevelUpOverlay {
  LevelUpOverlay._();

  static Future<void> show(
    BuildContext context, {
    required int newLevel,
    required bool isDungeon,
    HunterRank? newRank,
  }) async {
    SystemFeedback.levelUp();
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: AppColors.alpha(Colors.black, 0.85),
      builder: (_) => _LevelUpDialog(
        level: newLevel,
        isDungeon: isDungeon,
        rank: newRank,
      ),
    );
  }
}

class _LevelUpDialog extends StatefulWidget {
  final int level;
  final bool isDungeon;
  final HunterRank? rank;
  const _LevelUpDialog({
    required this.level,
    required this.isDungeon,
    this.rank,
  });

  @override
  State<_LevelUpDialog> createState() => _LevelUpDialogState();
}

class _LevelUpDialogState extends State<_LevelUpDialog>
    with TickerProviderStateMixin {
  late final AnimationController _entryCtrl;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _scale;
  late final Animation<double> _glow;
  late final Animation<double> _shimmer;

  // Il colore della finestra cambia in base al tipo (quest = oro, dungeon = viola)
  Color get _baseColor =>
      widget.isDungeon ? AppColors.purple : AppColors.gold;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    )..forward();
    _pulseCtrl = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat(reverse: true);

    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.1)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.1, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
    ]).animate(_entryCtrl);

    _glow = Tween<double>(begin: 0.6, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _shimmer = Tween<double>(begin: -1.0, end: 2.0)
        .animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([_entryCtrl, _pulseCtrl]),
        builder: (_, __) => Transform.scale(
          scale: _scale.value,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 340),
              decoration: BoxDecoration(
                color: AppColors.black,
                border: Border.all(color: _baseColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.alpha(_baseColor, _glow.value * 0.7),
                    blurRadius: 50,
                    spreadRadius: 4,
                  ),
                  BoxShadow(
                    color: AppColors.alpha(_baseColor, _glow.value * 0.3),
                    blurRadius: 100,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Shimmer diagonale
                  Positioned.fill(
                    child: ClipRect(
                      child: Transform.translate(
                        offset: Offset(_shimmer.value * 340, 0),
                        child: Transform.rotate(
                          angle: -math.pi / 6,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                Colors.transparent,
                                AppColors.alpha(_baseColor, 0.15),
                                Colors.transparent,
                              ]),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 36),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Label tipo
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: AppColors.alpha(_baseColor, 0.5)),
                            color: AppColors.alpha(_baseColor, 0.08),
                          ),
                          child: Text(
                            widget.isDungeon
                                ? '⚔ DUNGEON LEVEL UP'
                                : '📋 QUEST LEVEL UP',
                            style: TextStyle(
                              color: AppColors.alpha(_baseColor, _glow.value),
                              fontFamily: 'monospace',
                              letterSpacing: 3,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'You have leveled up.',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'monospace',
                            fontSize: 15,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Numero che si conta su
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 900),
                          tween: Tween(
                              begin: 0, end: widget.level.toDouble()),
                          curve: Curves.easeOutCubic,
                          builder: (_, value, __) => Text(
                            'LV. ${value.toInt()}',
                            style: TextStyle(
                              color: _baseColor,
                              fontFamily: 'monospace',
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4,
                              shadows: [
                                Shadow(
                                  color: AppColors.alpha(
                                      _baseColor, _glow.value),
                                  blurRadius: 30,
                                ),
                                Shadow(
                                  color: AppColors.alpha(
                                      _baseColor, _glow.value * 0.5),
                                  blurRadius: 60,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Rank up se presente
                        if (widget.rank != null) ...[
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: widget.rank!.color),
                              color: AppColors.alpha(
                                  widget.rank!.color, 0.1),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'RANK ${widget.rank!.label}',
                                  style: TextStyle(
                                    color: widget.rank!.color,
                                    fontFamily: 'monospace',
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 6,
                                  ),
                                ),
                                Text(
                                  widget.rank!.title,
                                  style: TextStyle(
                                    color: AppColors.alpha(
                                        widget.rank!.color, 0.7),
                                    fontFamily: 'monospace',
                                    fontSize: 10,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        Text(
                          '[ TAP TO CLOSE ]',
                          style: TextStyle(
                            color: AppColors.alpha(
                                Colors.grey, _glow.value),
                            fontFamily: 'monospace',
                            fontSize: 10,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}