import 'dart:math';
import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../models/gym_task.dart';
import '../models/set_log.dart';
import '../widgets/glow_box.dart';

class ExerciseHistoryScreen extends StatelessWidget {
  final GymTask task;
  const ExerciseHistoryScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final history = task.recentHistory.reversed.toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.blue),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.name,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'monospace',
                fontSize: 14,
              ),
            ),
            const Text(
              'STORICO SET',
              style: TextStyle(
                color: Colors.grey,
                fontFamily: 'monospace',
                fontSize: 10,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (task.history.isNotEmpty)
            GlowBox(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PESO (kg)',
                    style: TextStyle(
                      color: Colors.grey,
                      fontFamily: 'monospace',
                      fontSize: 10,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 80,
                    child: _MiniChart(history: task.recentHistory),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'RECORD',
                            style: TextStyle(
                              color: AppColors.gold,
                              fontFamily: 'monospace',
                              fontSize: 10,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            '${task.maxWeight}kg',
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontFamily: 'monospace',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'TOTALE SET',
                            style: TextStyle(
                              color: Colors.grey,
                              fontFamily: 'monospace',
                              fontSize: 10,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            '${task.history.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'monospace',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: history.length,
              itemBuilder: (ctx, i) {
                final s = history[i];
                final isRecord = s.weight == task.maxWeight;
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isRecord
                          ? AppColors.alpha(AppColors.gold, 0.4)
                          : AppColors.blueDim,
                    ),
                    color: isRecord
                        ? AppColors.alpha(AppColors.gold, 0.04)
                        : Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      if (isRecord)
                        const Icon(
                          Icons.emoji_events,
                          color: AppColors.gold,
                          size: 14,
                        ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${s.weight}kg × ${s.reps} reps',
                          style: TextStyle(
                            color:
                                isRecord ? AppColors.gold : Colors.white,
                            fontFamily: 'monospace',
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Text(
                        _fmtDate(s.date),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontFamily: 'monospace',
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day}/${d.month} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

class _MiniChart extends StatelessWidget {
  final List<SetLog> history;
  const _MiniChart({required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) return const SizedBox();
    return CustomPaint(
      painter: _ChartPainter(history: history),
      size: const Size(double.infinity, 80),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<SetLog> history;
  _ChartPainter({required this.history});

  @override
  void paint(Canvas canvas, Size size) {
    if (history.length < 2) return;

    final weights = history.map((s) => s.weight).toList();
    final minW = weights.reduce(min);
    final maxW = weights.reduce(max);
    final range = maxW - minW == 0 ? 1.0 : maxW - minW;

    final paint = Paint()
      ..color = AppColors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = AppColors.alpha(AppColors.blue, 0.3)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final dotPaint = Paint()..color = AppColors.blue;

    final path = Path();
    for (int i = 0; i < history.length; i++) {
      final x = (i / (history.length - 1)) * size.width;
      final y = size.height - ((weights[i] - minW) / range) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);

    for (int i = 0; i < history.length; i++) {
      final x = (i / (history.length - 1)) * size.width;
      final y = size.height - ((weights[i] - minW) / range) * size.height;
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter old) =>
      old.history != history;
}