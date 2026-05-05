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

/// Stato globale dell'app.
///
/// Cambiamenti rispetto al vecchio provider:
/// - Sistema XP basato su LevelSystem (niente più `playerLevel` calcolato a vista).
/// - Stream `levelUpEvents` per triggerare l'animazione di level-up dalla UI.
/// - Notifiche programmate correttamente (zonedSchedule).
/// - Save/load più robusti con try/catch.
class SystemProvider extends ChangeNotifier {
  // ---------- State ----------
  List<Quest> _quests = [];
  List<ExerciseBlueprint> _exercises = [];
  int _totalVolume = 0;
  int _notifCounter = 100;
  bool _isLoading = true;
  int _lastKnownLevel = 1;

  /// Stream di eventi level-up: emette il NUOVO livello quando si sale.
  final StreamController<int> _levelUpController =
      StreamController<int>.broadcast();
  Stream<int> get levelUpEvents => _levelUpController.stream;

  // ---------- Getters ----------
  bool get isLoading => _isLoading;
  List<Quest> get quests => List.unmodifiable(_quests);
  List<ExerciseBlueprint> get exercises => List.unmodifiable(_exercises);
  int get totalVolume => _totalVolume;

  List<Quest> get dailyQuests =>
      _quests.where((q) => q.type == QuestType.daily).toList();
  List<Quest> get gymQuests =>
      _quests.where((q) => q.type == QuestType.gym).toList();
  List<Quest> get advQuests =>
      _quests.where((q) => q.type == QuestType.adventure).toList();

  int get completedQuestCount => _quests.where((q) => q.isCompleted).length;
  int get clearedDungeonCount => gymQuests.where((q) => q.isGymComplete).length;

  int get totalXp => LevelSystem.xpFor(
        completedQuests: completedQuestCount - clearedDungeonCount,
        clearedDungeons: clearedDungeonCount,
        totalVolume: _totalVolume,
      );

  int get playerLevel => LevelSystem.levelFromXp(totalXp);
  HunterRank get rank => HunterRank.fromLevel(playerLevel);
  double get levelProgress => LevelSystem.progressInLevel(totalXp);

  // ---------- Persistence ----------
  Future<void> loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Esercizi: merge fra default e custom salvati.
      final defaults = ExerciseBlueprint.defaults();
      final exJson = prefs.getString('exercises');
      if (exJson != null) {
        final List decoded = jsonDecode(exJson) as List;
        _exercises = decoded
            .map((e) => ExerciseBlueprint.fromJson(e as Map<String, dynamic>))
            .toList();
        for (final d in defaults) {
          if (!_exercises.any((e) => e.id == d.id)) {
            _exercises.insert(0, d);
          }
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

      _totalVolume = prefs.getInt('totalVolume') ?? 0;
      _notifCounter = prefs.getInt('notifCounter') ?? 100;
      _lastKnownLevel = playerLevel;
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
        'quests',
        jsonEncode(_quests.map((q) => q.toJson()).toList()),
      );
      await prefs.setString(
        'exercises',
        jsonEncode(_exercises.map((e) => e.toJson()).toList()),
      );
      await prefs.setInt('totalVolume', _totalVolume);
      await prefs.setInt('notifCounter', _notifCounter);
    } catch (e) {
      debugPrint('save error: $e');
    }
  }

  /// Verifica se è avvenuto un level-up e ne emette l'evento.
  void _checkLevelUp() {
    final current = playerLevel;
    if (current > _lastKnownLevel) {
      _levelUpController.add(current);
      _lastKnownLevel = current;
    } else {
      _lastKnownLevel = current; // per i casi in cui scende (reset, etc.)
    }
  }

  // ---------- Quest actions ----------
  Future<void> addQuest(Quest q) async {
    _quests.add(q);
    notifyListeners();
    await _save();
  }

  Future<void> removeQuest(Quest q) async {
    if (q.notifId != null) {
      await NotificationService.instance.cancel(q.notifId!);
    }
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

  // ---------- Gym actions ----------
  Future<void> logSet(GymTask task, double weight, int reps) async {
    final wasComplete = task.isFinished;
    task.lastWeight = weight;
    task.lastReps = reps;
    task.completedSets += 1;
    task.history.add(SetLog(date: DateTime.now(), weight: weight, reps: reps));
    _totalVolume += (weight * reps).round();
    notifyListeners();
    if (!wasComplete) _checkLevelUp();
    await _save();
  }

  Future<void> resetGymSession(Quest quest) async {
    for (final t in quest.gymRoutine) {
      t.completedSets = 0;
    }
    notifyListeners();
    await _save();
  }

  // ---------- Custom exercises ----------
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

  // ---------- Notifications ----------
  Future<void> scheduleQuestReminder(Quest q, DateTime time) async {
    final id = _notifCounter++;
    q.reminderTime = time;
    q.notifId = id;
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
    if (q.notifId != null) {
      await NotificationService.instance.cancel(q.notifId!);
    }
    q.reminderTime = null;
    q.notifId = null;
    notifyListeners();
    await _save();
  }

  @override
  void dispose() {
    _levelUpController.close();
    super.dispose();
  }
}