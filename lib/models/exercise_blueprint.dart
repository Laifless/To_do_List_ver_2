class ExerciseBlueprint {
  final String id;
  String name;
  String muscleGroup;
  bool isCustom;

  ExerciseBlueprint({
    required this.id,
    required this.name,
    required this.muscleGroup,
    this.isCustom = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'muscleGroup': muscleGroup,
    'isCustom': isCustom,
  };

  factory ExerciseBlueprint.fromJson(Map<String, dynamic> j) =>
      ExerciseBlueprint(
        id: j['id'] as String,
        name: j['name'] as String,
        muscleGroup: j['muscleGroup'] as String,
        isCustom: j['isCustom'] as bool? ?? false,
      );

  /// Esercizi di default precaricati.
  static List<ExerciseBlueprint> defaults() => [
    ExerciseBlueprint(id: 'ex1', name: 'Panca Piana', muscleGroup: 'Petto'),
    ExerciseBlueprint(id: 'ex2', name: 'Panca Inclinata', muscleGroup: 'Petto'),
    ExerciseBlueprint(id: 'ex3', name: 'Croci Manubri', muscleGroup: 'Petto'),
    ExerciseBlueprint(id: 'ex4', name: 'Squat', muscleGroup: 'Gambe'),
    ExerciseBlueprint(id: 'ex5', name: 'Leg Press', muscleGroup: 'Gambe'),
    ExerciseBlueprint(id: 'ex6', name: 'Affondi', muscleGroup: 'Gambe'),
    ExerciseBlueprint(id: 'ex7', name: 'Stacchi Terra', muscleGroup: 'Schiena'),
    ExerciseBlueprint(id: 'ex8', name: 'Lat Machine', muscleGroup: 'Schiena'),
    ExerciseBlueprint(id: 'ex9', name: 'Rematore', muscleGroup: 'Schiena'),
    ExerciseBlueprint(id: 'ex10', name: 'Military Press', muscleGroup: 'Spalle'),
    ExerciseBlueprint(id: 'ex11', name: 'Alzate Laterali', muscleGroup: 'Spalle'),
    ExerciseBlueprint(id: 'ex12', name: 'Curl Bicipiti', muscleGroup: 'Braccia'),
    ExerciseBlueprint(id: 'ex13', name: 'Curl Martello', muscleGroup: 'Braccia'),
    ExerciseBlueprint(id: 'ex14', name: 'Pushdown', muscleGroup: 'Braccia'),
    ExerciseBlueprint(id: 'ex15', name: 'Tricipiti Corpo', muscleGroup: 'Braccia'),
    ExerciseBlueprint(id: 'ex16', name: 'Crunch', muscleGroup: 'Core'),
    ExerciseBlueprint(id: 'ex17', name: 'Plank', muscleGroup: 'Core'),
  ];
}