import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/colors.dart';
import '../core/haptics.dart';
import '../models/exercise_blueprint.dart';
import '../models/gym_task.dart';
import '../models/quest.dart';
import '../providers/system_provider.dart';

class DungeonMakerScreen extends StatefulWidget {
  const DungeonMakerScreen({super.key});

  @override
  State<DungeonMakerScreen> createState() => _DungeonMakerScreenState();
}

class _DungeonMakerScreenState extends State<DungeonMakerScreen> {
  final _nameCtrl = TextEditingController();
  final List<GymTask> _selected = [];
  String _filter = 'Tutti';

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<SystemProvider>();
    final allEx = prov.exercises;
    final muscleGroups = [
      'Tutti',
      ...{for (final e in allEx) e.muscleGroup}.toList()..sort(),
    ];
    final visible = _filter == 'Tutti'
        ? allEx
        : allEx.where((e) => e.muscleGroup == _filter).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.purple),
        title: const Text(
          'CRAFT DUNGEON KEY',
          style: TextStyle(
            color: AppColors.purple,
            letterSpacing: 3,
            fontFamily: 'monospace',
            fontSize: 14,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _nameCtrl,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'monospace',
              ),
              decoration: const InputDecoration(
                hintText: 'Nome scheda (es. Chest Day)',
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: muscleGroups.length,
              itemBuilder: (ctx, i) {
                final g = muscleGroups[i];
                final sel = _filter == g;
                return GestureDetector(
                  onTap: () {
                    SystemFeedback.tap();
                    setState(() => _filter = g);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: sel ? AppColors.purple : AppColors.blueDim,
                      ),
                      color: sel
                          ? AppColors.alpha(AppColors.purple, 0.15)
                          : Colors.transparent,
                    ),
                    child: Text(
                      g,
                      style: TextStyle(
                        color: sel ? AppColors.purple : Colors.grey,
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: visible.length,
              itemBuilder: (ctx, i) {
                final ex = visible[i];
                final isSelected =
                    _selected.any((t) => t.exerciseId == ex.id);
                return ListTile(
                  leading: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            isSelected ? AppColors.purple : AppColors.blueDim,
                      ),
                      color: isSelected
                          ? AppColors.alpha(AppColors.purple, 0.2)
                          : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            size: 14,
                            color: AppColors.purple,
                          )
                        : null,
                  ),
                  title: Text(
                    ex.name,
                    style: TextStyle(
                      color: isSelected ? AppColors.purple : Colors.white,
                      fontFamily: 'monospace',
                    ),
                  ),
                  subtitle: Text(
                    ex.muscleGroup,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                  trailing: ex.isCustom
                      ? IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: AppColors.red,
                            size: 16,
                          ),
                          onPressed: () => prov.deleteCustomExercise(ex),
                        )
                      : null,
                  onTap: () => _toggleExercise(ex),
                );
              },
            ),
          ),
          if (_selected.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.blueDim)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SELEZIONATI: ${_selected.length}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontFamily: 'monospace',
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: _selected.map((t) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.alpha(AppColors.purple, 0.5),
                          ),
                          color: AppColors.alpha(AppColors.purple, 0.08),
                        ),
                        child: Text(
                          t.name,
                          style: const TextStyle(
                            color: AppColors.purple,
                            fontSize: 10,
                            fontFamily: 'monospace',
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(
                      Icons.add,
                      color: AppColors.blue,
                      size: 16,
                    ),
                    label: const Text(
                      'CUSTOM',
                      style: TextStyle(
                        color: AppColors.blue,
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.blueDim),
                      shape: const RoundedRectangleBorder(),
                    ),
                    onPressed: () => _addCustomExercise(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      shape: const RoundedRectangleBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _save,
                    child: const Text(
                      'CRAFT KEY',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toggleExercise(ExerciseBlueprint ex) {
    if (_selected.any((t) => t.exerciseId == ex.id)) {
      setState(() => _selected.removeWhere((t) => t.exerciseId == ex.id));
      return;
    }

    final setsCtrl = TextEditingController(text: '4');
    // Cattura il context del widget PRIMA di entrare nel builder del dialog.
    // Usare `ctx` (il context del builder) per setState sul padre non funziona
    // in modo affidabile — il widget padre è fuori dall'albero del dialog.
    final widgetContext = context;

    showDialog<int?>(
      context: widgetContext,
      builder: (ctx) => AlertDialog(
        title: Text(
          ex.name,
          style: const TextStyle(
            color: AppColors.purple,
            fontFamily: 'monospace',
            fontSize: 14,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Serie target:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: setsCtrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              autofocus: true,
              style: const TextStyle(
                color: AppColors.purple,
                fontSize: 28,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purple,
              shape: const RoundedRectangleBorder(),
            ),
            // Restituisce il numero di serie come risultato del dialog,
            // invece di chiamare setState dall'interno del builder.
            onPressed: () {
              final s = int.tryParse(setsCtrl.text) ?? 4;
              Navigator.pop(ctx, s);
            },
            child: const Text(
              'AGGIUNGI',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    ).then((sets) {
      setsCtrl.dispose();
      if (sets == null) return; // dialog chiuso senza conferma
      if (!mounted) return;
      setState(() {
        _selected.add(
          GymTask(
            id: 'task_${DateTime.now().millisecondsSinceEpoch}',
            exerciseId: ex.id,
            name: ex.name,
            targetMuscle: ex.muscleGroup,
            targetSets: sets,
          ),
        );
      });
    });
  }

  void _addCustomExercise(BuildContext context) {
    final nameCtrl = TextEditingController();
    final muscleCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text(
          'CUSTOM EXERCISE',
          style: TextStyle(
            color: AppColors.blue,
            fontFamily: 'monospace',
            fontSize: 13,
            letterSpacing: 2,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Nome esercizio'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: muscleCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Gruppo muscolare'),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              shape: const RoundedRectangleBorder(),
            ),
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && muscleCtrl.text.isNotEmpty) {
                context.read<SystemProvider>().addCustomExercise(
                      nameCtrl.text,
                      muscleCtrl.text,
                    );
                Navigator.pop(dialogCtx);
              }
            },
            child: const Text(
              'SAVE',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  void _save() {
    if (_nameCtrl.text.isEmpty || _selected.isEmpty) return;
    SystemFeedback.confirm();
    context.read<SystemProvider>().addQuest(
          Quest(
            id: 'gym_${DateTime.now().millisecondsSinceEpoch}',
            title: _nameCtrl.text,
            type: QuestType.gym,
            gymRoutine: _selected,
          ),
        );
    Navigator.pop(context);
  }
}