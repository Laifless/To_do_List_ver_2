import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/colors.dart';
import '../models/hunter_rank.dart';
import '../providers/system_provider.dart';
import '../widgets/glow_box.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<SystemProvider>();
    final lvl = prov.playerLevel;
    final rank = prov.rank;
    final totalQuests = prov.quests.length;
    final completedQ = prov.completedQuestCount;
    final gymSessions = prov.clearedDungeonCount;
    final (xpInLevel, xpForLevel) =
        LevelSystem.xpInCurrentLevel(prov.totalXp);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          '// STATUS WINDOW',
          style: TextStyle(
            color: AppColors.blue,
            letterSpacing: 4,
            fontFamily: 'monospace',
            fontSize: 14,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Level + Rank display
            AnimatedBuilder(
              animation: _glow,
              builder: (context, child) => GlowBox(
                color: rank.color,
                padding: const EdgeInsets.symmetric(vertical: 32),
                glowIntensity: _glow.value,
                child: Column(
                  children: [
                    Text(
                      'HUNTER LEVEL',
                      style: TextStyle(
                        color: AppColors.alpha(rank.color, _glow.value),
                        letterSpacing: 4,
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$lvl',
                      style: TextStyle(
                        color: rank.color,
                        fontSize: 72,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color:
                                AppColors.alpha(rank.color, _glow.value),
                            blurRadius: 30,
                          ),
                          Shadow(
                            color: AppColors.alpha(
                              rank.color,
                              _glow.value * 0.5,
                            ),
                            blurRadius: 60,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: rank.color),
                        color: AppColors.alpha(rank.color, 0.1),
                      ),
                      child: Text(
                        'RANK ${rank.label}',
                        style: TextStyle(
                          color: rank.color,
                          fontFamily: 'monospace',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      rank.title,
                      style: TextStyle(
                        color: AppColors.alpha(Colors.grey, _glow.value),
                        letterSpacing: 3,
                        fontFamily: 'monospace',
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Stats grid
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'VOLUME TOTALE',
                    value: '${prov.totalVolume}kg',
                    color: AppColors.purple,
                    icon: Icons.fitness_center,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'DUNGEON CLEARED',
                    value: '$gymSessions',
                    color: AppColors.green,
                    icon: Icons.vpn_key,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'QUEST COMPLETE',
                    value: '$completedQ',
                    color: AppColors.gold,
                    icon: Icons.check_circle_outline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'QUEST TOTALI',
                    value: '$totalQuests',
                    color: AppColors.blue,
                    icon: Icons.list_alt,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // XP Bar verso prossimo livello
            GlowBox(
              color: AppColors.blueDim,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'NEXT LEVEL',
                        style: TextStyle(
                          color: Colors.grey,
                          fontFamily: 'monospace',
                          fontSize: 10,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        '$xpInLevel / $xpForLevel XP',
                        style: const TextStyle(
                          color: AppColors.blue,
                          fontFamily: 'monospace',
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: prov.levelProgress,
                      color: AppColors.blue,
                      backgroundColor: AppColors.blueDim,
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Prossimo rank
            if (rank.next != null)
              GlowBox(
                color: AppColors.alpha(rank.next!.color, 0.5),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'NEXT RANK',
                      style: TextStyle(
                        color: Colors.grey,
                        fontFamily: 'monospace',
                        fontSize: 10,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: rank.next!.color),
                          ),
                          child: Text(
                            rank.next!.label,
                            style: TextStyle(
                              color: rank.next!.color,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            rank.next!.title,
                            style: TextStyle(
                              color: rank.next!.color,
                              fontFamily: 'monospace',
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        Text(
                          'LV. ${rank.next!.minLevel}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontFamily: 'monospace',
                            fontSize: 11,
                          ),
                        ),
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

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => GlowBox(
    color: color,
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontFamily: 'monospace',
                  fontSize: 9,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'monospace',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: AppColors.alpha(color, 0.5),
                blurRadius: 10,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}