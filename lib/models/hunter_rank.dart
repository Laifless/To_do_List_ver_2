import 'package:flutter/material.dart';
import '../core/colors.dart';

/// Sistema di rank ispirato a Solo Leveling.
/// Ogni rank ha un livello minimo, un colore e un titolo.
enum HunterRank {
  e(
    minLevel: 1,
    label: 'E',
    title: 'WEAKEST HUNTER',
    color: AppColors.rankE,
  ),
  d(
    minLevel: 5,
    label: 'D',
    title: 'AWAKENED',
    color: AppColors.rankD,
  ),
  c(
    minLevel: 10,
    label: 'C',
    title: 'COMPETENT',
    color: AppColors.rankC,
  ),
  b(
    minLevel: 20,
    label: 'B',
    title: 'ELITE HUNTER',
    color: AppColors.rankB,
  ),
  a(
    minLevel: 35,
    label: 'A',
    title: 'NATIONAL ASSET',
    color: AppColors.rankA,
  ),
  s(
    minLevel: 60,
    label: 'S',
    title: 'SHADOW MONARCH',
    color: AppColors.rankS,
  );

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

  /// Restituisce il rank corrispondente a un livello dato.
  static HunterRank fromLevel(int level) {
    HunterRank current = HunterRank.e;
    for (final r in HunterRank.values) {
      if (level >= r.minLevel) current = r;
    }
    return current;
  }

  /// Prossimo rank, o null se già S.
  HunterRank? get next {
    final i = HunterRank.values.indexOf(this);
    if (i == HunterRank.values.length - 1) return null;
    return HunterRank.values[i + 1];
  }
}

/// Calcola progressione e XP a partire da quest completate e volume sollevato.
///
/// Formula:
/// - Ogni quest non-gym completata = 50 XP
/// - Ogni dungeon (gym quest) completato = 200 XP
/// - Ogni 10kg di volume = 1 XP
///
/// Soglie livello: XP necessari per il livello N = 100 * N * 1.2^(N-1)
/// (cresce, ma non troppo brutalmente).
class LevelSystem {
  LevelSystem._();

  static int xpFor({
    required int completedQuests,
    required int clearedDungeons,
    required int totalVolume,
  }) {
    return completedQuests * 50 + clearedDungeons * 200 + (totalVolume ~/ 10);
  }

  /// XP totali necessari per ARRIVARE al livello [level] (cumulativo).
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
      if (level > 200) break; // safety cap
    }
    return level;
  }

  /// Progresso (0.0 → 1.0) verso il prossimo livello.
  static double progressInLevel(int xp) {
    final lvl = levelFromXp(xp);
    final start = xpRequiredForLevel(lvl);
    final end = xpRequiredForLevel(lvl + 1);
    final span = end - start;
    if (span <= 0) return 1.0;
    return ((xp - start) / span).clamp(0.0, 1.0);
  }

  /// XP guadagnati nel livello attuale e XP totali del livello.
  static (int current, int total) xpInCurrentLevel(int xp) {
    final lvl = levelFromXp(xp);
    final start = xpRequiredForLevel(lvl);
    final end = xpRequiredForLevel(lvl + 1);
    return (xp - start, end - start);
  }

  static double _pow(double base, int exp) {
    double r = 1;
    for (int i = 0; i < exp; i++) {
      r *= base;
    }
    return r;
  }
}