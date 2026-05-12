import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/colors.dart';
import '../models/hunter_rank.dart';
import '../providers/system_provider.dart';
import '../widgets/glow_box.dart';
import '../widgets/muscle_graph.dart';

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
        duration: const Duration(seconds: 3), vsync: this)
      ..repeat(reverse: true);
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

    final allMuscles = {
      'Petto', 'Spalle', 'Braccia', 'Addome', 'Quadricipiti',
      'Polpacci', 'Schiena', 'Glutei', 'Femorali', 'Trapezi',
      'Tricipiti', 'Core',
    };
    final muscleMap = {
      for (final m in allMuscles) m: prov.tierForMuscle(m),
    };

    // Lista muscoli allenati, ordinata per volume decrescente
    final trainedMuscles = prov.muscleVolume.entries
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Due pannelli livello affiancati ──────────────────────────
            Row(
              children: [
                Expanded(
                  child: _LevelPanel(
                    label: 'QUEST',
                    icon: Icons.list_alt,
                    level: prov.questLevel,
                    rank: prov.questRank,
                    progress: prov.questLevelProgress,
                    xp: prov.questXp,
                    glow: _glow,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _LevelPanel(
                    label: 'DUNGEON',
                    icon: Icons.fitness_center,
                    level: prov.dungeonLevel,
                    rank: prov.dungeonRank,
                    progress: prov.dungeonLevelProgress,
                    xp: prov.dungeonXp,
                    glow: _glow,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Stats ────────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'VOLUME',
                    value: _fmtVol(prov.totalVolume),
                    color: AppColors.purple,
                    icon: Icons.fitness_center,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'DUNGEON',
                    value: '${prov.clearedDungeonCount}',
                    color: AppColors.green,
                    icon: Icons.vpn_key,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'QUEST',
                    value: '${prov.completedNonGymQuests}',
                    color: AppColors.gold,
                    icon: Icons.check_circle_outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Muscle Graph ─────────────────────────────────────────────
            GlowBox(
              color: AppColors.blueDim,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.accessibility_new,
                          color: AppColors.blue, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'MUSCLE MAP',
                        style: TextStyle(
                          color: AppColors.blue,
                          fontFamily: 'monospace',
                          fontSize: 12,
                          letterSpacing: 3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tocca un muscolo per i dettagli',
                    style: TextStyle(
                      color: Colors.grey,
                      fontFamily: 'monospace',
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 16),
                  MuscleGraph(
                    muscleMap: muscleMap,
                    muscleVolume: prov.muscleVolume,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Tabella rank muscoli allenati ────────────────────────────
            if (trainedMuscles.isNotEmpty)
              GlowBox(
                color: AppColors.blueDim,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MUSCLE RANKS',
                      style: TextStyle(
                        color: Colors.grey,
                        fontFamily: 'monospace',
                        fontSize: 10,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Lista esplicita — niente cascade con .map()
                    for (final entry in trainedMuscles)
                      _MuscleRankRow(
                        muscle: entry.key,
                        volume: entry.value,
                        tier: prov.tierForMuscle(entry.key),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _fmtVol(int v) =>
      v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}k kg' : '$v kg';
}

// ── Riga singola muscolo ───────────────────────────────────────────────────

class _MuscleRankRow extends StatelessWidget {
  final String muscle;
  final int volume;
  final MuscleTier tier;

  const _MuscleRankRow({
    required this.muscle,
    required this.volume,
    required this.tier,
  });

  @override
  Widget build(BuildContext context) {
    final progress = tier.progressFrom(volume);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              muscle,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'monospace',
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress,
                color: tier.color,
                backgroundColor: AppColors.alpha(tier.color, 0.12),
                minHeight: 4,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.alpha(tier.color, 0.5)),
              color: AppColors.alpha(tier.color, 0.08),
            ),
            child: Text(
              tier.label,
              style: TextStyle(
                color: tier.color,
                fontFamily: 'monospace',
                fontSize: 9,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pannello livello ───────────────────────────────────────────────────────

class _LevelPanel extends StatelessWidget {
  final String label;
  final IconData icon;
  final int level;
  final HunterRank rank;
  final double progress;
  final int xp;
  final Animation<double> glow;

  const _LevelPanel({
    required this.label,
    required this.icon,
    required this.level,
    required this.rank,
    required this.progress,
    required this.xp,
    required this.glow,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glow,
      builder: (_, __) => GlowBox(
        color: rank.color,
        glowIntensity: glow.value,
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: rank.color, size: 12),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.alpha(rank.color, glow.value),
                    fontFamily: 'monospace',
                    fontSize: 10,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '$level',
              style: TextStyle(
                color: rank.color,
                fontSize: 42,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: AppColors.alpha(rank.color, glow.value),
                    blurRadius: 20,
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                border: Border.all(color: rank.color),
                color: AppColors.alpha(rank.color, 0.1),
              ),
              child: Text(
                rank.label,
                style: TextStyle(
                  color: rank.color,
                  fontFamily: 'monospace',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              rank.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.alpha(Colors.grey, glow.value),
                fontFamily: 'monospace',
                fontSize: 8,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress,
                color: rank.color,
                backgroundColor: AppColors.alpha(rank.color, 0.15),
                minHeight: 3,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '$xp XP',
              style: const TextStyle(
                color: Colors.grey,
                fontFamily: 'monospace',
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stat card ──────────────────────────────────────────────────────────────

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
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 13),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'monospace',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(color: AppColors.alpha(color, 0.5), blurRadius: 8),
                ],
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: AppColors.alpha(color, 0.7),
                fontFamily: 'monospace',
                fontSize: 9,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      );
}