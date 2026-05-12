import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../models/hunter_rank.dart';

/// Mappa muscolo → tier, calcolata dal provider.
typedef MuscleMap = Map<String, MuscleTier>;

/// Muscle graph interattivo.
/// Mostra la silhouette anteriore e posteriore del corpo umano.
/// Ogni muscolo viene colorato in base al suo MuscleTier.
/// Toccando un muscolo appare un tooltip con tier e volume.
class MuscleGraph extends StatefulWidget {
  final MuscleMap muscleMap;
  final Map<String, int> muscleVolume;

  const MuscleGraph({
    super.key,
    required this.muscleMap,
    required this.muscleVolume,
  });

  @override
  State<MuscleGraph> createState() => _MuscleGraphState();
}

class _MuscleGraphState extends State<MuscleGraph> {
  String? _selected;

  void _onTap(String muscle) {
    setState(() => _selected = _selected == muscle ? null : muscle);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tooltip muscolo selezionato
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _selected != null
              ? _MuscleTooltip(
                  key: ValueKey(_selected),
                  muscle: _selected!,
                  tier: widget.muscleMap[_selected] ?? MuscleTier.unranked,
                  volume: widget.muscleVolume[_selected] ?? 0,
                )
              : const SizedBox(height: 56),
        ),
        const SizedBox(height: 12),
        // Le due viste: anteriore e posteriore
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BodyView(
              label: 'FRONT',
              muscleMap: widget.muscleMap,
              selected: _selected,
              onTap: _onTap,
              isFront: true,
            ),
            _BodyView(
              label: 'BACK',
              muscleMap: widget.muscleMap,
              selected: _selected,
              onTap: _onTap,
              isFront: false,
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Legenda tier
        const _TierLegend(),
      ],
    );
  }
}

// ── Tooltip ────────────────────────────────────────────────────────────────

class _MuscleTooltip extends StatelessWidget {
  final String muscle;
  final MuscleTier tier;
  final int volume;

  const _MuscleTooltip({
    super.key,
    required this.muscle,
    required this.tier,
    required this.volume,
  });

  @override
  Widget build(BuildContext context) {
    final next = tier.next;
    final progress = tier.progressFrom(volume);
    final volToNext = next != null ? next.minVolume - volume : 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: tier.color),
        color: AppColors.alpha(tier.color, 0.07),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                muscle.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 1,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(color: tier.color),
                  color: AppColors.alpha(tier.color, 0.12),
                ),
                child: Text(
                  tier.label,
                  style: TextStyle(
                    color: tier.color,
                    fontFamily: 'monospace',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: progress,
                    color: tier.color,
                    backgroundColor: AppColors.alpha(tier.color, 0.15),
                    minHeight: 4,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                next != null
                    ? '${_fmt(volume)} / ${_fmt(next.minVolume)} kg'
                    : 'MAX',
                style: TextStyle(
                  color: AppColors.alpha(tier.color, 0.8),
                  fontFamily: 'monospace',
                  fontSize: 10,
                ),
              ),
            ],
          ),
          if (next != null && volToNext > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${_fmt(volToNext)} kg al prossimo tier: ${next.label}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontFamily: 'monospace',
                  fontSize: 10,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _fmt(int v) =>
      v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}k' : '$v';
}

// ── Vista corpo (anteriore / posteriore) ──────────────────────────────────

class _BodyView extends StatelessWidget {
  final String label;
  final MuscleMap muscleMap;
  final String? selected;
  final void Function(String) onTap;
  final bool isFront;

  const _BodyView({
    required this.label,
    required this.muscleMap,
    required this.selected,
    required this.onTap,
    required this.isFront,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontFamily: 'monospace',
            fontSize: 10,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 150,
          height: 300,
          child: CustomPaint(
            painter: _BodyPainter(
              isFront: isFront,
              muscleMap: muscleMap,
              selected: selected,
            ),
            child: _TapLayer(
              isFront: isFront,
              onTap: onTap,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Tap layer: zone invisibili cliccabili sopra il CustomPaint ─────────────

class _TapLayer extends StatelessWidget {
  final bool isFront;
  final void Function(String) onTap;

  const _TapLayer({required this.isFront, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Le aree sono definite come % della dimensione del widget (150×300).
    final areas = isFront ? _frontAreas : _backAreas;
    return Stack(
      children: areas.entries.map((e) {
        final r = e.value;
        return Positioned(
          left: r.left * 150,
          top: r.top * 300,
          width: r.width * 150,
          height: r.height * 300,
          child: GestureDetector(
            onTap: () => onTap(e.key),
            child: Container(color: Colors.transparent),
          ),
        );
      }).toList(),
    );
  }

  // Zone anteriori (coordinate normalizzate 0.0–1.0)
  static const Map<String, Rect> _frontAreas = {
    'Petto':      Rect.fromLTWH(0.25, 0.18, 0.50, 0.14),
    'Spalle':     Rect.fromLTWH(0.08, 0.14, 0.20, 0.12),
    'Braccia':    Rect.fromLTWH(0.04, 0.26, 0.16, 0.18),
    'Addome':     Rect.fromLTWH(0.28, 0.33, 0.44, 0.16),
    'Quadricipiti': Rect.fromLTWH(0.20, 0.56, 0.25, 0.20),
    'Polpacci':   Rect.fromLTWH(0.22, 0.78, 0.20, 0.14),
  };

  // Zone posteriori
  static const Map<String, Rect> _backAreas = {
    'Schiena':    Rect.fromLTWH(0.22, 0.16, 0.56, 0.22),
    'Glutei':     Rect.fromLTWH(0.22, 0.44, 0.56, 0.12),
    'Femorali':   Rect.fromLTWH(0.22, 0.57, 0.56, 0.18),
    'Trapezi':    Rect.fromLTWH(0.28, 0.10, 0.44, 0.08),
    'Tricipiti':  Rect.fromLTWH(0.04, 0.24, 0.14, 0.18),
    'Core':       Rect.fromLTWH(0.28, 0.38, 0.44, 0.08),
  };
}

// ── CustomPainter: disegna la silhouette e colora i muscoli ───────────────

class _BodyPainter extends CustomPainter {
  final bool isFront;
  final MuscleMap muscleMap;
  final String? selected;

  _BodyPainter({
    required this.isFront,
    required this.muscleMap,
    required this.selected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Sfondo corpo (silhouette base)
    final basePaint = Paint()
      ..color = const Color(0xFF0A0A1E)
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = const Color(0xFF1A1A3E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Disegna la silhouette base
    _drawSilhouette(canvas, w, h, basePaint, outlinePaint);

    // Disegna i muscoli colorati
    final areas = isFront ? _TapLayer._frontAreas : _TapLayer._backAreas;
    for (final entry in areas.entries) {
      final muscle = entry.key;
      final rect = entry.value;
      final tier = muscleMap[muscle] ?? MuscleTier.unranked;
      final isSelected = selected == muscle;

      final musclePaint = Paint()
        ..color = AppColors.alpha(
          tier.color,
          tier == MuscleTier.unranked ? 0.06 : (isSelected ? 0.75 : 0.45),
        )
        ..style = PaintingStyle.fill;

      final borderPaint = Paint()
        ..color = AppColors.alpha(
          tier.color,
          isSelected ? 1.0 : (tier == MuscleTier.unranked ? 0.1 : 0.5),
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 2.0 : 0.8;

      final scaledRect = Rect.fromLTWH(
        rect.left * w,
        rect.top * h,
        rect.width * w,
        rect.height * h,
      );

      // Forma arrotondata per ogni gruppo
      final rr = RRect.fromRectAndRadius(
          scaledRect, const Radius.circular(6));

      canvas.drawRRect(rr, musclePaint);
      canvas.drawRRect(rr, borderPaint);

      // Glow se selezionato
      if (isSelected && tier != MuscleTier.unranked) {
        final glowPaint = Paint()
          ..color = AppColors.alpha(tier.color, 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawRRect(rr, glowPaint);
      }
    }
  }

  void _drawSilhouette(
      Canvas canvas, double w, double h, Paint fill, Paint outline) {
    // Testa
    final headCenter = Offset(w * 0.5, h * 0.065);
    canvas.drawCircle(headCenter, w * 0.11, fill);
    canvas.drawCircle(headCenter, w * 0.11, outline);

    // Collo
    final neck = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.42, h * 0.11, w * 0.16, h * 0.05),
      const Radius.circular(3),
    );
    canvas.drawRRect(neck, fill);
    canvas.drawRRect(neck, outline);

    // Torso
    final torso = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.20, h * 0.14, w * 0.60, h * 0.36),
      const Radius.circular(8),
    );
    canvas.drawRRect(torso, fill);
    canvas.drawRRect(torso, outline);

    if (isFront) {
      // Braccia anteriori
      _drawLimb(canvas, Rect.fromLTWH(w * 0.04, h * 0.14, w * 0.14, h * 0.32),
          fill, outline);
      _drawLimb(canvas, Rect.fromLTWH(w * 0.82, h * 0.14, w * 0.14, h * 0.32),
          fill, outline);
      // Mani
      canvas.drawCircle(Offset(w * 0.11, h * 0.49), w * 0.07, fill);
      canvas.drawCircle(Offset(w * 0.89, h * 0.49), w * 0.07, fill);
    } else {
      // Braccia posteriori
      _drawLimb(canvas, Rect.fromLTWH(w * 0.04, h * 0.14, w * 0.14, h * 0.32),
          fill, outline);
      _drawLimb(canvas, Rect.fromLTWH(w * 0.82, h * 0.14, w * 0.14, h * 0.32),
          fill, outline);
      canvas.drawCircle(Offset(w * 0.11, h * 0.49), w * 0.07, fill);
      canvas.drawCircle(Offset(w * 0.89, h * 0.49), w * 0.07, fill);
    }

    // Bacino
    final pelvis = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.22, h * 0.49, w * 0.56, h * 0.08),
      const Radius.circular(6),
    );
    canvas.drawRRect(pelvis, fill);
    canvas.drawRRect(pelvis, outline);

    // Gambe
    _drawLimb(canvas, Rect.fromLTWH(w * 0.22, h * 0.55, w * 0.24, h * 0.30),
        fill, outline);
    _drawLimb(canvas, Rect.fromLTWH(w * 0.54, h * 0.55, w * 0.24, h * 0.30),
        fill, outline);

    // Piedi
    final footL = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.18, h * 0.90, w * 0.28, h * 0.06),
      const Radius.circular(4),
    );
    final footR = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.54, h * 0.90, w * 0.28, h * 0.06),
      const Radius.circular(4),
    );
    canvas.drawRRect(footL, fill);
    canvas.drawRRect(footL, outline);
    canvas.drawRRect(footR, fill);
    canvas.drawRRect(footR, outline);
  }

  void _drawLimb(Canvas canvas, Rect rect, Paint fill, Paint outline) {
    final rr = RRect.fromRectAndRadius(rect, const Radius.circular(8));
    canvas.drawRRect(rr, fill);
    canvas.drawRRect(rr, outline);
  }

  @override
  bool shouldRepaint(covariant _BodyPainter old) =>
      old.muscleMap != muscleMap ||
      old.selected != selected ||
      old.isFront != isFront;
}

// ── Legenda tier ───────────────────────────────────────────────────────────

class _TierLegend extends StatelessWidget {
  const _TierLegend();

  @override
  Widget build(BuildContext context) {
    final tiers = MuscleTier.values.where((t) => t != MuscleTier.unranked);
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 6,
      children: tiers.map((t) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: t.color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.alpha(t.color, 0.5),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Text(
              t.label,
              style: TextStyle(
                color: AppColors.alpha(t.color, 0.8),
                fontFamily: 'monospace',
                fontSize: 9,
                letterSpacing: 1,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
