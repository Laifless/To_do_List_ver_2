import 'gym_task.dart';

enum QuestType { daily, gym, adventure }

class Quest {
  String id;
  String title;
  QuestType type;
  bool isDone;
  List<GymTask> gymRoutine;
  DateTime? reminderTime;
  int? notifId;

  Quest({
    required this.id,
    required this.title,
    required this.type,
    this.isDone = false,
    List<GymTask>? gymRoutine,
    this.reminderTime,
    this.notifId,
  }) : gymRoutine = gymRoutine ?? [];

  bool get isGymComplete =>
      gymRoutine.isNotEmpty && gymRoutine.every((t) => t.isFinished);

  bool get isCompleted => type == QuestType.gym ? isGymComplete : isDone;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'type': type.index,
    'isDone': isDone,
    'gymRoutine': gymRoutine.map((t) => t.toJson()).toList(),
    'reminderTime': reminderTime?.toIso8601String(),
    'notifId': notifId,
  };

  factory Quest.fromJson(Map<String, dynamic> j) => Quest(
    id: j['id'] as String,
    title: j['title'] as String,
    type: QuestType.values[j['type'] as int],
    isDone: j['isDone'] as bool,
    gymRoutine: (j['gymRoutine'] as List?)
            ?.map((t) => GymTask.fromJson(t as Map<String, dynamic>))
            .toList() ??
        [],
    reminderTime: j['reminderTime'] != null
        ? DateTime.parse(j['reminderTime'] as String)
        : null,
    notifId: j['notifId'] as int?,
  );
}