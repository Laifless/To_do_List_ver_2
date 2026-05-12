import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/notifications.dart';
import '../models/exercise_blueprint.dart';
import '../models/gym_task.dart';
import '../models/hunter_rank.dart';
import '../models/quest.dart';
import '../models/set_log.dart';

class SystemProvider extends ChangeNotifier {
  // ── State ──────────────────────────────────────────────────────────────
  List<Quest> _quests     = [];
  List<ExerciseBlueprint> _exercises = [];

  // Volume separato per gruppo muscolare: { 'Petto': 12400, 'Schiena': 8000, ... }
  Map<String, int> _muscleVolume = {};

  int _notifCounter = 100;
  bool _isLoading   = true;

  // Level-up separati per i due sistemi
  int _lastQuestLevel   = 1;
  int _lastDungeonLevel = 1;

  final StreamController<({int level, bool isDungeon})> _levelUpController =
      StreamController<({int level, bool isDungeon})>.broadcast();

  Stream<({int level, bool isDungeon})> get levelUpEvents =>
      _levelUpController.stream;

  // ── Getters base ───────────────────────────────────────────────────────
  bool get isLoading  => _isLoading;
  List<Quest> get quests    => List.unmodifiable(_quests);
  List<ExerciseBlueprint> get exercises => List.unmodifiable(_exercises);
  Map<String, int> get muscleVolume => Map.unmodifiable(_muscleVolume);

  List<Quest> get dailyQuests => _quests.where((q) => q.type == QuestType.daily).toList();
  List<Quest> get gymQuests   => _quests.where((q) => q.type == QuestType.gym).toList();
  List<Quest> get advQuests   => _quests.where((q) => q.type == QuestType.adventure).toList();

  int get completedNonGymQuests =>
      _quests.where((q) => q.type != QuestType.gym && q.isCompleted).length;
  int get clearedDungeonCount =>
      gymQuests.where((q) => q.isGymComplete).length;
  int get totalVolume =>
      _muscleVolume.values.fold(0, (a, b) => a + b);

  // ── XP e livelli separati ──────────────────────────────────────────────
  int get questXp =>
      LevelSystem.questXp(completedQuests: completedNonGymQuests);

  int get dungeonXp => LevelSystem.dungeonXp(
        clearedDungeons: clearedDungeonCount,
        totalVolumeKg: totalVolume,
      );

  int get questLevel   => LevelSystem.levelFromXp(questXp);
  int get dungeonLevel => LevelSystem.levelFromXp(dungeonXp);

  HunterRank get questRank   => HunterRank.fromLevel(questLevel);
  HunterRank get dungeonRank => HunterRank.fromLevel(dungeonLevel);

  double get questLevelProgress   => LevelSystem.progressInLevel(questXp);
  double get dungeonLevelProgress => LevelSystem.progressInLevel(dungeonXp);

  // Tier per ogni gruppo muscolare
  MuscleTier tierForMuscle(String muscle) =>
      MuscleTier.fromVolume(_muscleVolume[muscle] ?? 0);

  int volumeForMuscle(String muscle) => _muscleVolume[muscle] ?? 0;

  // ── Persistenza ────────────────────────────────────────────────────────
  Future<void> loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Esercizi
      final defaults = ExerciseBlueprint.defaults();
      final exJson = prefs.getString('exercises');
      if (exJson != null) {
        final List decoded = jsonDecode(exJson) as List;
        _exercises = decoded
            .map((e) => ExerciseBlueprint.fromJson(e as Map<String, dynamic>))
            .toList();
        for (final d in defaults) {
          if (!_exercises.any((e) => e.id == d.id)) _exercises.insert(0, d);
        }
      } else {
        _exercises = defaults;
      }

      // Quest
      final questsJson = prefs.getString('quests');
      if (questsJson != null) {
        final List decoded = jsonDecode(questsJson) as List;
        _quests = decoded
            .map((q) => Quest.fromJson(q as Map<String, dynamic>))
            .toList();
      }

      // Volume per muscolo
      final mvJson = prefs.getString('muscleVolume');
      if (mvJson != null) {
        final Map decoded = jsonDecode(mvJson) as Map;
        _muscleVolume = decoded.map((k, v) => MapEntry(k as String, v as int));
      }

      _notifCounter     = prefs.getInt('notifCounter') ?? 100;
      _lastQuestLevel   = questLevel;
      _lastDungeonLevel = dungeonLevel;
    } catch (e, st) {
      debugPrint('loadData error: $e\n$st');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'quests', jsonEncode(_quests.map((q) => q.toJson()).toList()));
      await prefs.setString(
          'exercises', jsonEncode(_exercises.map((e) => e.toJson()).toList()));
      await prefs.setString('muscleVolume', jsonEncode(_muscleVolume));
      await prefs.setInt('notifCounter', _notifCounter);
    } catch (e) {
      debugPrint('save error: $e');
    }
  }

  void _checkLevelUp() {
    final qLvl = questLevel;
    if (qLvl > _lastQuestLevel) {
      _levelUpController.add((level: qLvl, isDungeon: false));
      _lastQuestLevel = qLvl;
    } else {
      _lastQuestLevel = qLvl;
    }

    final dLvl = dungeonLevel;
    if (dLvl > _lastDungeonLevel) {
      _levelUpController.add((level: dLvl, isDungeon: true));
      _lastDungeonLevel = dLvl;
    } else {
      _lastDungeonLevel = dLvl;
    }
  }

  // ── Quest actions ──────────────────────────────────────────────────────
  Future<void> addQuest(Quest q) async {
    _quests.add(q);
    notifyListeners();
    await _save();
  }

  Future<void> removeQuest(Quest q) async {
    if (q.notifId != null) await NotificationService.instance.cancel(q.notifId!);
    _quests.remove(q);
    notifyListeners();
    await _save();
  }

  Future<void> toggleDaily(Quest q) async {
    q.isDone = !q.isDone;
    notifyListeners();
    _checkLevelUp();
    await _save();
  }

  Future<void> resetDailies() async {
    for (final q in _quests.where((q) => q.type == QuestType.daily)) {
      q.isDone = false;
    }
    notifyListeners();
    await _save();
  }

  // ── Gym actions ────────────────────────────────────────────────────────
  Future<void> logSet(GymTask task, double weight, int reps) async {
    task.lastWeight  = weight;
    task.lastReps    = reps;
    task.completedSets += 1;
    task.history.add(SetLog(date: DateTime.now(), weight: weight, reps: reps));

    // Aggiorna volume per gruppo muscolare
    final vol = (weight * reps).round();
    _muscleVolume[task.targetMuscle] =
        (_muscleVolume[task.targetMuscle] ?? 0) + vol;

    notifyListeners();
    _checkLevelUp();
    await _save();
  }

  Future<void> resetGymSession(Quest quest) async {
    for (final t in quest.gymRoutine) t.completedSets = 0;
    notifyListeners();
    await _save();
  }

  // ── Custom exercises ───────────────────────────────────────────────────
  Future<void> addCustomExercise(String name, String muscleGroup) async {
    final ex = ExerciseBlueprint(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      muscleGroup: muscleGroup,
      isCustom: true,
    );
    _exercises.add(ex);
    notifyListeners();
    await _save();
  }

  Future<void> deleteCustomExercise(ExerciseBlueprint ex) async {
    _exercises.remove(ex);
    notifyListeners();
    await _save();
  }

  // ── Notifications ──────────────────────────────────────────────────────
  Future<void> scheduleQuestReminder(Quest q, DateTime time) async {
    final id = _notifCounter++;
    q.reminderTime = time;
    q.notifId      = id;
    await NotificationService.instance.schedule(
      id: id,
      title: '⚠️ QUEST REMINDER',
      body: q.title,
      scheduledTime: time,
    );
    notifyListeners();
    await _save();
  }

  Future<void> removeReminder(Quest q) async {
    if (q.notifId != null) await NotificationService.instance.cancel(q.notifId!);
    q.reminderTime = null;
    q.notifId      = null;
    notifyListeners();
    await _save();
  }

  @override
  void dispose() {
    _levelUpController.close();
    super.dispose();
  }
}