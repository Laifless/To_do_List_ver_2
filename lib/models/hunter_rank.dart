import 'package:flutter/material.dart';
import '../core/colors.dart';

// ─────────────────────────────────────────────
// RANK DEL HUNTER (E → SSS)
// Due istanze indipendenti: una per le Quest, una per i Dungeon.
// ─────────────────────────────────────────────

enum HunterRank {
  e(minLevel: 1,  label: 'E',   title: 'WEAKEST HUNTER',   color: AppColors.rankE),
  d(minLevel: 5,  label: 'D',   title: 'AWAKENED',          color: AppColors.rankD),
  c(minLevel: 10, label: 'C',   title: 'COMPETENT',         color: AppColors.rankC),
  b(minLevel: 20, label: 'B',   title: 'ELITE HUNTER',      color: AppColors.rankB),
  a(minLevel: 35, label: 'A',   title: 'NATIONAL ASSET',    color: AppColors.rankA),
  s(minLevel: 60, label: 'S',   title: 'SHADOW MONARCH',    color: AppColors.rankS),
  ss(minLevel: 90,  label: 'SS',  title: 'ABSOLUTE BEING',  color: AppColors.rankSS),
  ssPlus(minLevel: 120, label: 'SS+', title: 'BEYOND LIMIT', color: AppColors.rankSSPlus),
  sss(minLevel: 150, label: 'SSS', title: 'RULER OF RULERS', color: AppColors.rankSSS);

  const HunterRank({
    required this.minLevel,
    required this.label,
    required this.title,
    required this.color,
  });

  final int minLevel;
  final String label;
  final String title;
  final Color color;

  static HunterRank fromLevel(int level) {
    HunterRank current = HunterRank.e;
    for (final r in HunterRank.values) {
      if (level >= r.minLevel) current = r;
    }
    return current;
  }

  HunterRank? get next {
    final i = HunterRank.values.indexOf(this);
    if (i == HunterRank.values.length - 1) return null;
    return HunterRank.values[i + 1];
  }
}

// ─────────────────────────────────────────────
// SISTEMA XP DOPPIO
// QuestLevel  → daily + adventure completate
// DungeonLevel → dungeon completati + volume sollevato
// ─────────────────────────────────────────────

class LevelSystem {
  LevelSystem._();

  // XP per tipo di azione
  static const int xpPerQuest   = 50;
  static const int xpPerDungeon = 300;
  static const int xpPerVolume  = 1; // ogni 10 kg

  static int questXp({required int completedQuests}) =>
      completedQuests * xpPerQuest;

  static int dungeonXp({
    required int clearedDungeons,
    required int totalVolumeKg,
  }) =>
      clearedDungeons * xpPerDungeon + (totalVolumeKg ~/ 10) * xpPerVolume;

  /// XP totali necessari per arrivare AL livello [level] (cumulativo).
  /// Curva: 100 × N × 1.2^(N-1)  — cresce ma non brutalmente.
  static int xpRequiredForLevel(int level) {
    if (level <= 1) return 0;
    int total = 0;
    for (int n = 1; n < level; n++) {
      total += (100 * n * _pow(1.2, n - 1)).round();
    }
    return total;
  }

  static int levelFromXp(int xp) {
    int level = 1;
    while (xpRequiredForLevel(level + 1) <= xp) {
      level++;
      if (level > 300) break;
    }
    return level;
  }

  static double progressInLevel(int xp) {
    final lvl = levelFromXp(xp);
    final start = xpRequiredForLevel(lvl);
    final end   = xpRequiredForLevel(lvl + 1);
    final span  = end - start;
    if (span <= 0) return 1.0;
    return ((xp - start) / span).clamp(0.0, 1.0);
  }

  static (int current, int total) xpInCurrentLevel(int xp) {
    final lvl   = levelFromXp(xp);
    final start = xpRequiredForLevel(lvl);
    final end   = xpRequiredForLevel(lvl + 1);
    return (xp - start, end - start);
  }

  static double _pow(double base, int exp) {
    double r = 1;
    for (int i = 0; i < exp; i++) r *= base;
    return r;
  }
}

// ─────────────────────────────────────────────
// TIER MUSCOLARE
// Basato sul volume cumulativo (kg × reps) per ogni gruppo muscolare.
// ─────────────────────────────────────────────

enum MuscleTier {
  unranked(minVolume: 0,      label: '—',          color: Color(0xFF222233)),
  bronze(  minVolume: 500,    label: 'BRONZE',     color: Color(0xFFCD7F32)),
  silver(  minVolume: 2000,   label: 'SILVER',     color: Color(0xFFC0C0C0)),
  gold(    minVolume: 5000,   label: 'GOLD',       color: Color(0xFFFFD700)),
  platinum(minVolume: 10000,  label: 'PLATINUM',   color: Color(0xFFE5E4E2)),
  diamond( minVolume: 20000,  label: 'DIAMOND',    color: Color(0xFF9FE2FF)),
  ruby(    minVolume: 35000,  label: 'RUBY',       color: Color(0xFF9B111E)),
  crystal( minVolume: 55000,  label: 'CRYSTAL',    color: Color(0xFFAA88FF)),
  elite(   minVolume: 80000,  label: 'ELITE',      color: Color(0xFF00FFC8)),
  champion(minVolume: 120000, label: 'CHAMPION',   color: Color(0xFFFF8C00)),
  celestial(minVolume:175000, label: 'CELESTIAL',  color: Color(0xFF00EAFF)),
  titan(   minVolume: 250000, label: 'TITAN',      color: Color(0xFFFF3A5C));

  const MuscleTier({
    required this.minVolume,
    required this.label,
    required this.color,
  });

  final int minVolume; // volume cumulativo in kg (peso × reps)
  final String label;
  final Color color;

  static MuscleTier fromVolume(int volume) {
    MuscleTier current = MuscleTier.unranked;
    for (final t in MuscleTier.values) {
      if (volume >= t.minVolume) current = t;
    }
    return current;
  }

  MuscleTier? get next {
    final i = MuscleTier.values.indexOf(this);
    if (i == MuscleTier.values.length - 1) return null;
    return MuscleTier.values[i + 1];
  }

  /// Progresso (0.0 → 1.0) verso il tier successivo.
  double progressFrom(int volume) {
    final n = next;
    if (n == null) return 1.0;
    final span = n.minVolume - minVolume;
    if (span <= 0) return 1.0;
    return ((volume - minVolume) / span).clamp(0.0, 1.0);
  }
}