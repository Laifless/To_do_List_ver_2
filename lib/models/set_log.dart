class SetLog {
  final DateTime date;
  final double weight;
  final int reps;

  SetLog({required this.date, required this.weight, required this.reps});

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'weight': weight,
    'reps': reps,
  };

  factory SetLog.fromJson(Map<String, dynamic> j) => SetLog(
    date: DateTime.parse(j['date'] as String),
    weight: (j['weight'] as num).toDouble(),
    reps: j['reps'] as int,
  );
}