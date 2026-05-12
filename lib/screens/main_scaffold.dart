import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/colors.dart';
import '../core/haptics.dart';
import '../models/hunter_rank.dart';
import '../models/quest.dart';
import '../providers/system_provider.dart';
import '../widgets/glow_fab.dart';
import '../widgets/level_up_overlay.dart';
import '../widgets/slide_route.dart';
import 'dungeon_keys_screen.dart';
import 'dungeon_maker_screen.dart';
import 'quest_log_screen.dart';
import 'status_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _index = 0;
  StreamSubscription<int>? _levelUpSub;
  HunterRank? _lastRank;

  @override
  void initState() {
    super.initState();
    // MainScaffold viene costruito SOLO dopo che AppRoot ha verificato
    // isLoading == false, quindi qui il provider è già pronto.
    final prov = context.read<SystemProvider>();
    _lastRank = prov.rank;
    _levelUpSub = prov.levelUpEvents.listen(_handleLevelUp);
  }

  void _handleLevelUp(int newLevel) {
    if (!mounted) return;
    final prov = context.read<SystemProvider>();
    final newRank = prov.rank;
    final rankChanged = newRank != _lastRank;
    _lastRank = newRank;
    LevelUpOverlay.show(
      context,
      newLevel: newLevel,
      newRank: rankChanged ? newRank : null,
    );
  }

  @override
  void dispose() {
    _levelUpSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          QuestLogScreen(),
          DungeonKeysScreen(),
          StatusScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.blueDim, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: AppColors.surfaceAlt,
          selectedItemColor: AppColors.blue,
          unselectedItemColor: Colors.grey[700],
          currentIndex: _index,
          onTap: (i) {
            SystemFeedback.tap();
            setState(() => _index = i);
          },
          selectedLabelStyle: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 10,
            letterSpacing: 1,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 10,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_outlined),
              activeIcon: Icon(Icons.list_alt),
              label: 'QUESTS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center_outlined),
              activeIcon: Icon(Icons.fitness_center),
              label: 'DUNGEON',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'STATUS',
            ),
          ],
        ),
      ),
      floatingActionButton: _index != 2
          ? GlowFAB(onPressed: () => _showAddMenu(context))
          : null,
    );
  }

  void _showAddMenu(BuildContext context) {
    SystemFeedback.confirm();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: AppColors.blueDim),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '// SELECT QUEST TYPE',
              style: TextStyle(
                color: AppColors.blue,
                letterSpacing: 3,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _TypeButton(
                  icon: Icons.calendar_today,
                  label: 'DAILY',
                  color: AppColors.gold,
                  onTap: () {
                    Navigator.pop(context);
                    _addSimpleQuest(context, QuestType.daily);
                  },
                ),
                _TypeButton(
                  icon: Icons.fitness_center,
                  label: 'GYM',
                  color: AppColors.purple,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      slideRoute(const DungeonMakerScreen()),
                    );
                  },
                ),
                _TypeButton(
                  icon: Icons.map_outlined,
                  label: 'ADVENTURE',
                  color: AppColors.green,
                  onTap: () {
                    Navigator.pop(context);
                    _addSimpleQuest(context, QuestType.adventure);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _addSimpleQuest(BuildContext context, QuestType type) {
    final ctrl = TextEditingController();
    final color = type == QuestType.daily ? AppColors.gold : AppColors.green;
    final typeName = type == QuestType.daily ? 'DAILY' : 'ADVENTURE';
    DateTime? reminderTime;

    showDialog<void>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(
            'NEW $typeName QUEST',
            style: TextStyle(
              color: color,
              letterSpacing: 2,
              fontFamily: 'monospace',
              fontSize: 14,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: ctrl,
                style: const TextStyle(color: Colors.white),
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: "Descrivi l'obiettivo...",
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  final t = await showTimePicker(
                    context: ctx,
                    initialTime: TimeOfDay.now(),
                  );
                  if (t != null) {
                    final now = DateTime.now();
                    var dt = DateTime(
                      now.year,
                      now.month,
                      now.day,
                      t.hour,
                      t.minute,
                    );
                    if (dt.isBefore(now)) {
                      dt = dt.add(const Duration(days: 1));
                    }
                    setDialogState(() => reminderTime = dt);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: reminderTime != null ? color : AppColors.blueDim,
                    ),
                    color: reminderTime != null
                        ? AppColors.alpha(color, 0.08)
                        : Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.notifications_outlined,
                        color: reminderTime != null ? color : Colors.grey,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        reminderTime != null
                            ? 'Reminder: ${_fmtTime(reminderTime!)}'
                            : 'Aggiungi reminder',
                        style: TextStyle(
                          color: reminderTime != null ? color : Colors.grey,
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text(
                'CANCEL',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                shape: const RoundedRectangleBorder(),
              ),
              onPressed: () async {
                if (ctrl.text.trim().isEmpty) return;
                final prov = context.read<SystemProvider>();
                final q = Quest(
                  id: 'q_${DateTime.now().millisecondsSinceEpoch}',
                  title: ctrl.text.trim(),
                  type: type,
                );
                await prov.addQuest(q);
                if (reminderTime != null) {
                  await prov.scheduleQuestReminder(q, reminderTime!);
                }
                if (dialogCtx.mounted) Navigator.pop(dialogCtx);
              },
              child: const Text(
                'ACCEPT',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

class _TypeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _TypeButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
            color: AppColors.alpha(color, 0.08),
            boxShadow: [
              BoxShadow(
                color: AppColors.alpha(color, 0.3),
                blurRadius: 15,
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 26),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            letterSpacing: 2,
            fontFamily: 'monospace',
          ),
        ),
      ],
    ),
  );
}
