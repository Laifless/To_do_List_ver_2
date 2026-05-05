import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/colors.dart';
import '../core/haptics.dart';
import '../models/quest.dart';
import '../providers/system_provider.dart';
import '../widgets/section_header.dart';

class QuestLogScreen extends StatelessWidget {
  const QuestLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<SystemProvider>();
    final dailies = prov.dailyQuests;
    final adventures = prov.advQuests;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          '// QUEST LOG',
          style: TextStyle(
            color: AppColors.gold,
            letterSpacing: 4,
            fontSize: 16,
            fontFamily: 'monospace',
          ),
        ),
        actions: [
          if (dailies.any((q) => q.isDone))
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.grey),
              tooltip: 'Reset daily',
              onPressed: () {
                SystemFeedback.tap();
                prov.resetDailies();
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (dailies.isNotEmpty) ...[
            SectionHeader(
              'DAILY QUESTS',
              AppColors.gold,
              count: '${dailies.where((q) => q.isDone).length}/${dailies.length}',
            ),
            ...dailies.map((q) => _QuestCard(quest: q, color: AppColors.gold)),
            const SizedBox(height: 20),
          ],
          if (adventures.isNotEmpty) ...[
            SectionHeader(
              'ADVENTURE LOG',
              AppColors.green,
              count:
                  '${adventures.where((q) => q.isDone).length}/${adventures.length}',
            ),
            ...adventures.map(
              (q) => _QuestCard(quest: q, color: AppColors.green),
            ),
          ],
          if (dailies.isEmpty && adventures.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 100),
              child: Column(
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    color: Colors.grey[800],
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'NO ACTIVE QUESTS',
                    style: TextStyle(
                      color: Colors.grey[700],
                      letterSpacing: 3,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _QuestCard extends StatelessWidget {
  final Quest quest;
  final Color color;
  const _QuestCard({required this.quest, required this.color});

  @override
  Widget build(BuildContext context) {
    final prov = context.read<SystemProvider>();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: quest.isDone
              ? AppColors.alpha(Colors.grey, 0.2)
              : AppColors.alpha(color, 0.4),
        ),
        color: quest.isDone
            ? AppColors.alpha(Colors.white, 0.02)
            : AppColors.alpha(color, 0.04),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: GestureDetector(
          onTap: () {
            SystemFeedback.confirm();
            prov.toggleDaily(quest);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              border: Border.all(color: quest.isDone ? Colors.grey : color),
              color: quest.isDone
                  ? AppColors.alpha(Colors.grey, 0.2)
                  : Colors.transparent,
            ),
            child: quest.isDone
                ? const Icon(Icons.check, size: 14, color: Colors.grey)
                : null,
          ),
        ),
        title: Text(
          quest.title,
          style: TextStyle(
            color: quest.isDone ? Colors.grey : Colors.white,
            decoration: quest.isDone ? TextDecoration.lineThrough : null,
            fontFamily: 'monospace',
          ),
        ),
        subtitle: quest.reminderTime != null
            ? Row(
                children: [
                  Icon(
                    Icons.alarm,
                    size: 12,
                    color: AppColors.alpha(color, 0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _fmtTime(quest.reminderTime!),
                    style: TextStyle(
                      color: AppColors.alpha(color, 0.7),
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (quest.reminderTime != null)
              IconButton(
                icon: Icon(
                  Icons.notifications_off_outlined,
                  color: Colors.grey[600],
                  size: 18,
                ),
                onPressed: () => prov.removeReminder(quest),
              ),
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.red, size: 18),
              onPressed: () {
                SystemFeedback.warning();
                prov.removeQuest(quest);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _fmtTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}