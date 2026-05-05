import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/colors.dart';
import '../providers/system_provider.dart';
import '../widgets/section_header.dart';

class SkillBookScreen extends StatelessWidget {
  const SkillBookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final exercises = context.watch<SystemProvider>().exercises;
    final groups = exercises.map((e) => e.muscleGroup).toSet().toList()
      ..sort();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.blue),
        title: const Text(
          '// SKILL BOOK',
          style: TextStyle(
            color: AppColors.blue,
            fontFamily: 'monospace',
            letterSpacing: 4,
            fontSize: 14,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: groups.map((group) {
          final exs = exercises.where((e) => e.muscleGroup == group).toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                group.toUpperCase(),
                AppColors.blue,
                count: '${exs.length}',
              ),
              ...exs.map(
                (ex) => Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.blueDim),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 3,
                        height: 16,
                        color: ex.isCustom ? AppColors.green : AppColors.blue,
                        margin: const EdgeInsets.only(right: 10),
                      ),
                      Expanded(
                        child: Text(
                          ex.name,
                          style: TextStyle(
                            color: ex.isCustom
                                ? AppColors.green
                                : Colors.white,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      if (ex.isCustom)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.alpha(AppColors.green, 0.4),
                            ),
                          ),
                          child: const Text(
                            'CUSTOM',
                            style: TextStyle(
                              color: AppColors.green,
                              fontSize: 9,
                              fontFamily: 'monospace',
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        }).toList(),
      ),
    );
  }
}