import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/colors.dart';
import '../core/haptics.dart';
import '../models/quest.dart';
import '../providers/system_provider.dart';
import '../widgets/glow_box.dart';
import '../widgets/slide_route.dart';
import 'active_dungeon_screen.dart';
import 'skill_book_screen.dart';

class DungeonKeysScreen extends StatelessWidget {
  const DungeonKeysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<SystemProvider>();
    final list = prov.gymQuests;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          '// DUNGEON KEYS',
          style: TextStyle(
            color: AppColors.purple,
            letterSpacing: 4,
            fontSize: 16,
            fontFamily: 'monospace',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.book_outlined, color: Colors.grey),
            tooltip: 'Skill Book',
            onPressed: () {
              SystemFeedback.tap();
              Navigator.push(context, slideRoute(const SkillBookScreen()));
            },
          ),
        ],
      ),
      body: list.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.vpn_key_outlined,
                    color: Colors.grey[800],
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'NO DUNGEON KEYS',
                    style: TextStyle(
                      color: Colors.grey[700],
                      letterSpacing: 3,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (ctx, i) => _KeyCard(quest: list[i]),
            ),
    );
  }
}

class _KeyCard extends StatelessWidget {
  final Quest quest;
  const _KeyCard({required this.quest});

  @override
  Widget build(BuildContext context) {
    final done = quest.gymRoutine.where((t) => t.isFinished).length;
    final total = quest.gymRoutine.length;
    final isComplete = quest.isGymComplete;

    return GestureDetector(
      onTap: () {
        SystemFeedback.tap();
        Navigator.push(
          context,
          slideRoute(ActiveDungeonScreen(quest: quest)),
        );
      },
      onLongPress: () => _showDeleteDialog(context, quest),
      child: GlowBox(
        color: isComplete ? Colors.grey : AppColors.purple,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.vpn_key,
                  color: isComplete ? Colors.grey : AppColors.purple,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    quest.title,
                    style: TextStyle(
                      color: isComplete ? Colors.grey : Colors.white,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: total > 0 ? done / total : 0,
                      backgroundColor: AppColors.purpleDim,
                      color: isComplete ? Colors.grey : AppColors.purple,
                      minHeight: 3,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$done/$total',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: quest.gymRoutine.map((t) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: t.isFinished
                          ? AppColors.alpha(Colors.grey, 0.3)
                          : AppColors.alpha(AppColors.purple, 0.4),
                    ),
                    color: t.isFinished
                        ? AppColors.alpha(Colors.white, 0.02)
                        : AppColors.alpha(AppColors.purple, 0.06),
                  ),
                  child: Text(
                    t.name,
                    style: TextStyle(
                      color: t.isFinished ? Colors.grey : Colors.white,
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
    );
  }

  void _showDeleteDialog(BuildContext ctx, Quest q) {
    SystemFeedback.warning();
    showDialog<void>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text(
          'DELETE KEY?',
          style: TextStyle(
            color: AppColors.red,
            fontFamily: 'monospace',
            fontSize: 14,
            letterSpacing: 2,
          ),
        ),
        content: Text(
          'Eliminare "${q.title}"?',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              shape: const RoundedRectangleBorder(),
            ),
            onPressed: () {
              ctx.read<SystemProvider>().removeQuest(q);
              Navigator.pop(ctx);
            },
            child: const Text(
              'DELETE',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}