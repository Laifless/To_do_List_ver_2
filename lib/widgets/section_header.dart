import 'package:flutter/material.dart';
import '../core/colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  final String? count;

  const SectionHeader(this.title, this.color, {this.count, super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Container(
          width: 3,
          height: 16,
          color: color,
          margin: const EdgeInsets.only(right: 10),
        ),
        Text(
          title,
          style: TextStyle(
            color: color,
            letterSpacing: 2,
            fontFamily: 'monospace',
            fontSize: 12,
          ),
        ),
        const Spacer(),
        if (count != null)
          Text(
            count!,
            style: const TextStyle(
              color: Colors.grey,
              fontFamily: 'monospace',
              fontSize: 12,
            ),
          ),
      ],
    ),
  );
}