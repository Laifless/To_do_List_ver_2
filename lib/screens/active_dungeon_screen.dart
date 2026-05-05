import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/colors.dart';
import '../core/haptics.dart';
import '../models/gym_task.dart';
import '../models/quest.dart';
import '../providers/system_provider.dart';
import '../widgets/glow_box.dart';
import '../widgets/slide_route.dart';
import 'exercise_history_screen.dart';

class ActiveDungeonScreen extends StatelessWidget {
  final Quest quest;
  const ActiveDungeonScreen({super.key, required this.quest});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.purple),
        title: Text(
          quest.title,
          style: const TextStyle(
            color: AppColors.purple,
            fontFamily: 'monospace',
            letterSpacing: 2,
            fontSize: 14,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.grey),
            tooltip: 'Reset sessione',
            onPressed: () =>
                context.read<SystemProvider>().resetGymSession(quest),
          ),
        ],
      ),
      body: Consumer<SystemProvider>(
        builder: (ctx, prov, _) {
          final done = quest.gymRoutine.where((t) => t.isFinished).length;
          final total = quest.gymRoutine.length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header progress
              GlowBox(
                color: AppColors.purple,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'DUNGEON PROGRESS',
                          style: TextStyle(
                            color: Colors.grey,
                            fontFamily: 'monospace',
                            fontSize: 11,
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          '$done / $total',
                          style: const TextStyle(
                            color: AppColors.purple,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: total > 0 ? done / total : 0,
                        backgroundColor: AppColors.purpleDim,
                        color: AppColors.purple,
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              ),

              // Esercizi
              ...quest.gymRoutine.map(
                (task) => _ExerciseCard(task: task, quest: quest),
              ),

              if (quest.isGymComplete)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: GlowBox(
                    color: AppColors.green,
                    padding: const EdgeInsets.all(20),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.emoji_events,
                          color: AppColors.green,
                          size: 32,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'DUNGEON CLEARED!',
                          style: TextStyle(
                            color: AppColors.green,
                            letterSpacing: 4,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Ottimo lavoro, Hunter.',
                          style: TextStyle(
                            color: Colors.grey,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final GymTask task;
  final Quest quest;
  const _ExerciseCard({required this.task, required this.quest});

  @override
  Widget build(BuildContext context) {
    return GlowBox(
      color: task.isFinished ? Colors.grey : AppColors.purple,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          // Header esercizio
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.name,
                        style: TextStyle(
                          color: task.isFinished ? Colors.grey : Colors.white,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        task.targetMuscle,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: List.generate(
                    task.targetSets,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.only(left: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i < task.completedSets
                            ? AppColors.purple
                            : Colors.transparent,
                        border: Border.all(
                          color: i < task.completedSets
                              ? AppColors.purple
                              : AppColors.blueDim,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${task.completedSets}/${task.targetSets}',
                  style: const TextStyle(
                    color: AppColors.purple,
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Footer info + bottoni
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.blueDim, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                if (task.lastWeight > 0)
                  Expanded(
                    child: Text(
                      '${task.lastWeight}kg × ${task.lastReps} reps',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                  )
                else
                  const Expanded(
                    child: Text(
                      'Nessun set registrato',
                      style: TextStyle(
                        color: Color(0xFF333355),
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                  ),
                if (task.history.isNotEmpty)
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      slideRoute(ExerciseHistoryScreen(task: task)),
                    ),
                    child: const Text(
                      'STORICO',
                      style: TextStyle(
                        color: AppColors.blue,
                        fontFamily: 'monospace',
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                if (!task.isFinished)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      shape: const RoundedRectangleBorder(),
                    ),
                    onPressed: () => _showLogDialog(context, task),
                    child: const Text(
                      'LOG SET',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'monospace',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (task.isFinished)
                  const Icon(
                    Icons.check_circle,
                    color: Colors.grey,
                    size: 20,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogDialog(BuildContext context, GymTask task) {
    SystemFeedback.tap();
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _LogSetDialog(task: task),
    );
  }
}

/// Dialog per loggare un set. Estratto come StatefulWidget per gestire
/// il timer in modo pulito (il vecchio codice usava StatefulBuilder con
/// Timer.periodic dentro il builder → memory leak garantito).
class _LogSetDialog extends StatefulWidget {
  final GymTask task;
  const _LogSetDialog({required this.task});

  @override
  State<_LogSetDialog> createState() => _LogSetDialogState();
}

class _LogSetDialogState extends State<_LogSetDialog> {
  late final TextEditingController _wCtrl;
  late final TextEditingController _rCtrl;
  Timer? _timer;
  int _countdown = 0;
  int _totalCountdown = 90;

  @override
  void initState() {
    super.initState();
    _wCtrl = TextEditingController(
      text: widget.task.lastWeight > 0 ? '${widget.task.lastWeight}' : '',
    );
    _rCtrl = TextEditingController(
      text: widget.task.lastReps > 0 ? '${widget.task.lastReps}' : '',
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _wCtrl.dispose();
    _rCtrl.dispose();
    super.dispose();
  }

  void _startTimer(int seconds) {
    _timer?.cancel();
    setState(() {
      _countdown = seconds;
      _totalCountdown = seconds;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_countdown <= 1) {
        t.cancel();
        SystemFeedback.timerEnd();
        setState(() => _countdown = 0);
      } else {
        setState(() => _countdown--);
      }
    });
  }

  void _confirm() {
    final w = double.tryParse(_wCtrl.text.replaceAll(',', '.')) ?? 0;
    final r = int.tryParse(_rCtrl.text) ?? 0;
    if (w < 0 || r <= 0) return;
    _timer?.cancel();
    SystemFeedback.confirm();
    context.read<SystemProvider>().logSet(widget.task, w, r);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SET ${task.completedSets + 1}',
            style: const TextStyle(
              color: AppColors.purple,
              fontFamily: 'monospace',
              letterSpacing: 2,
            ),
          ),
          Text(
            task.name,
            style: const TextStyle(
              color: Colors.grey,
              fontFamily: 'monospace',
              fontSize: 12,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (task.maxWeight > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.alpha(AppColors.gold, 0.3),
                  ),
                  color: AppColors.alpha(AppColors.gold, 0.05),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      color: AppColors.gold,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Record: ${task.maxWeight}kg',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _wCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'monospace',
                  ),
                  decoration: const InputDecoration(labelText: 'KG'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _rCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'monospace',
                  ),
                  decoration: const InputDecoration(labelText: 'REPS'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Timer recupero
          if (_countdown > 0)
            Column(
              children: [
                Text(
                  'RECUPERO: ${_countdown}s',
                  style: TextStyle(
                    color:
                        _countdown <= 10 ? AppColors.red : AppColors.blue,
                    fontFamily: 'monospace',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: _countdown / _totalCountdown,
                    color: _countdown <= 10
                        ? AppColors.red
                        : AppColors.blue,
                    backgroundColor: AppColors.blueDim,
                    minHeight: 3,
                  ),
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _TimerBtn(label: '60s', onTap: () => _startTimer(60)),
                const SizedBox(width: 8),
                _TimerBtn(label: '90s', onTap: () => _startTimer(90)),
                const SizedBox(width: 8),
                _TimerBtn(label: '120s', onTap: () => _startTimer(120)),
              ],
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            _timer?.cancel();
            Navigator.pop(context);
          },
          child: const Text(
            'CANCEL',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.purple,
            shape: const RoundedRectangleBorder(),
          ),
          onPressed: _confirm,
          child: const Text(
            'DONE',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }
}

class _TimerBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _TimerBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.blueDim),
        color: AppColors.alpha(AppColors.blue, 0.05),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.blue,
          fontFamily: 'monospace',
          fontSize: 11,
        ),
      ),
    ),
  );
}