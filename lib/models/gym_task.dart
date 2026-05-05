import 'dart:math';
import 'set_log.dart';

class GymTask {
  String id;
  String exerciseId;
  String name;
  String targetMuscle;
  int targetSets;
  int completedSets;
  double lastWeight;
  int lastReps;
  List<SetLog> history;

  GymTask({
    required this.id,
    required this.exerciseId,
    required this.name,
    required this.targetMuscle,
    this.targetSets = 3,
    this.completedSets = 0,
    this.lastWeight = 0,
    this.lastReps = 0,
    List<SetLog>? history,
  }) : history = history ?? [];

  bool get isFinished => completedSets >= targetSets;

  double get maxWeight =>
      history.isEmpty ? 0 : history.map((s) => s.weight).reduce(max);

  /// Ultimi 20 set per il grafico mini.
  List<SetLog> get recentHistory =>
      history.length > 20 ? history.sublist(history.length - 20) : history;

  Map<String, dynamic> toJson() => {
    'id': id,
    'exerciseId': exerciseId,
    'name': name,
    'targetMuscle': targetMuscle,
    'targetSets': targetSets,
    'completedSets': completedSets,
    'lastWeight': lastWeight,
    'lastReps': lastReps,
    'history': history.map((s) => s.toJson()).toList(),
  };

  factory GymTask.fromJson(Map<String, dynamic> j) => GymTask(
    id: j['id'] as String,
    exerciseId: j['exerciseId'] as String? ?? '',
    name: j['name'] as String,
    targetMuscle: j['targetMuscle'] as String,
    targetSets: j['targetSets'] as int,
    completedSets: j['completedSets'] as int,
    lastWeight: (j['lastWeight'] as num).toDouble(),
    lastReps: j['lastReps'] as int,
    history: (j['history'] as List?)
            ?.map((s) => SetLog.fromJson(s as Map<String, dynamic>))
            .toList() ??
        [],
  );
}