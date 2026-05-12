import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/colors.dart';
import '../models/hunter_rank.dart';

typedef MuscleMap = Map<String, MuscleTier>;

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

  void _onTap(String muscle) =>
      setState(() => _selected = _selected == muscle ? null : muscle);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _selected != null
              ? _MuscleTooltip(
                  key: ValueKey(_selected),
                  muscle: _selected!,
                  tier: widget.muscleMap[_selected] ?? MuscleTier.unranked,
                  volume: widget.muscleVolume[_selected] ?? 0,
                )
              : const SizedBox(height: 64),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BodyView(
              label: 'FRONT',
              svgString: _buildFrontSvg(widget.muscleMap, _selected),
              onTapMuscle: _onTap,
              tapAreas: _frontTapAreas,
            ),
            _BodyView(
              label: 'BACK',
              svgString: _buildBackSvg(widget.muscleMap, _selected),
              onTapMuscle: _onTap,
              tapAreas: _backTapAreas,
            ),
          ],
        ),
        const SizedBox(height: 16),
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
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              color: tier.color,
              backgroundColor: AppColors.alpha(tier.color, 0.15),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _fmt(volume),
                style: TextStyle(
                  color: AppColors.alpha(tier.color, 0.8),
                  fontFamily: 'monospace',
                  fontSize: 10,
                ),
              ),
              Text(
                next != null
                    ? '${_fmt(volToNext)} al tier ${next.label}'
                    : 'TITAN — MAX',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontFamily: 'monospace',
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M kg';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k kg';
    return '$v kg';
  }
}

// ── Vista corpo ────────────────────────────────────────────────────────────

class _BodyView extends StatelessWidget {
  final String label;
  final String svgString;
  final void Function(String) onTapMuscle;
  final Map<String, Rect> tapAreas;

  const _BodyView({
    required this.label,
    required this.svgString,
    required this.onTapMuscle,
    required this.tapAreas,
  });

  @override
  Widget build(BuildContext context) {
    // Larghezza ridotta a 150dp e viewBox a 168x340 per avere
    // margine sufficiente su schermi ad alta densità come A72.
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
          height: 340,
          child: ClipRect(
            child: Stack(
              children: [
                SvgPicture.string(
                  svgString,
                  width: 150,
                  height: 340,
                  fit: BoxFit.contain,
                ),
                ...tapAreas.entries.map((e) => Positioned(
                      left: e.value.left,
                      top: e.value.top,
                      width: e.value.width,
                      height: e.value.height,
                      child: GestureDetector(
                        onTap: () => onTapMuscle(e.key),
                        child: Container(color: Colors.transparent),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Tap areas (normalizzate su viewBox 168×340) ────────────────────────────
// Il corpo è centrato a x=84. Le coordinate sono scalate di conseguenza.

const Map<String, Rect> _frontTapAreas = {
  'Petto':        Rect.fromLTWH(44, 52, 76, 38),
  'Spalle':       Rect.fromLTWH(28, 48, 22, 32),
  'Braccia':      Rect.fromLTWH(22, 76, 22, 52),
  'Addome':       Rect.fromLTWH(56, 88, 52, 70),
  'Quadricipiti': Rect.fromLTWH(40, 198, 84, 92),
  'Polpacci':     Rect.fromLTWH(40, 288, 84, 30),
};

const Map<String, Rect> _backTapAreas = {
  'Trapezi':      Rect.fromLTWH(54, 44, 60, 34),
  'Spalle':       Rect.fromLTWH(28, 48, 22, 34),
  'Schiena':      Rect.fromLTWH(34, 70, 100, 90),
  'Braccia':      Rect.fromLTWH(22, 76, 22, 52),
  'Glutei':       Rect.fromLTWH(38, 166, 92, 36),
  'Femorali':     Rect.fromLTWH(40, 198, 84, 90),
  'Polpacci':     Rect.fromLTWH(40, 286, 84, 30),
};

// ── SVG helpers ────────────────────────────────────────────────────────────

String _hex(Color c) =>
    '#${c.value.toRadixString(16).padLeft(8, '0').substring(2)}';

String _s(MuscleMap m, String muscle, String? sel) {
  final tier = m[muscle] ?? MuscleTier.unranked;
  final selected = sel == muscle;
  final fill = _hex(AppColors.alpha(tier.color, selected ? 0.70 : 0.42));
  final stroke = _hex(tier.color);
  final sw = selected ? '1.8' : '1.0';
  return 'fill:$fill;stroke:$stroke;stroke-width:$sw';
}

// viewBox: 168×340 — corpo centrato a cx=84 (+4 rispetto al vecchio 80).
// Le braccia arrivano a x=24 (sin) e x=144 (dx) → margine 24px per lato,
// abbondante anche su A72 ad alta densità.

String _buildFrontSvg(MuscleMap m, String? sel) => '''
<svg width="168" height="340" viewBox="0 0 168 340" xmlns="http://www.w3.org/2000/svg">
<rect width="168" height="340" fill="#04040F"/>
<ellipse cx="84" cy="22" rx="18" ry="20" fill="#0d0d1e" stroke="#1a1a3e" stroke-width="1"/>
<rect x="76" y="38" width="16" height="14" rx="3" fill="#0d0d1e" stroke="#1a1a3e" stroke-width="0.5"/>
<path d="M48,50 Q34,52 32,80 L32,160 Q32,168 40,170 L128,170 Q136,168 136,160 L136,80 Q134,52 120,50 Z" fill="#0d0d1e" stroke="#1a1a3e" stroke-width="0.5"/>
<path d="M40,168 Q40,195 54,200 L114,200 Q128,195 128,168 Z" fill="#0d0d1e" stroke="#1a1a3e" stroke-width="0.5"/>
<path d="M54,198 Q46,210 44,260 Q43,290 48,310 L70,310 Q74,290 72,260 Q70,210 64,198 Z" fill="#0d0d1e" stroke="#1a1a3e" stroke-width="0.5"/>
<path d="M114,198 Q122,210 124,260 Q125,290 120,310 L98,310 Q94,290 96,260 Q98,210 104,198 Z" fill="#0d0d1e" stroke="#1a1a3e" stroke-width="0.5"/>
<ellipse cx="59" cy="318" rx="14" ry="7" fill="#0d0d1e" stroke="#1a1a3e" stroke-width="0.5"/>
<ellipse cx="109" cy="318" rx="14" ry="7" fill="#0d0d1e" stroke="#1a1a3e" stroke-width="0.5"/>
<path d="M48,52 Q28,56 24,90 Q22,115 28,130 L40,130 Q42,115 42,90 Q44,64 48,58 Z" fill="#0d0d1e" stroke="#1a1a3e" stroke-width="0.5"/>
<path d="M120,52 Q140,56 144,90 Q146,115 140,130 L128,130 Q126,115 126,90 Q124,64 120,58 Z" fill="#0d0d1e" stroke="#1a1a3e" stroke-width="0.5"/>
<path d="M28,130 Q22,145 24,165 L36,165 Q38,145 40,130 Z" fill="#0d0d1e" stroke="#1a1a3e" stroke-width="0.5"/>
<path d="M140,130 Q146,145 144,165 L132,165 Q130,145 128,130 Z" fill="#0d0d1e" stroke="#1a1a3e" stroke-width="0.5"/>
<ellipse cx="30" cy="172" rx="8" ry="10" fill="#0d0d1e" stroke="#1a1a3e" stroke-width="0.5"/>
<ellipse cx="138" cy="172" rx="8" ry="10" fill="#0d0d1e" stroke="#1a1a3e" stroke-width="0.5"/>
<path style="${_s(m,'Spalle',sel)}" d="M48,50 Q34,50 32,65 Q34,76 44,78 Q50,70 52,56 Z"/>
<path style="${_s(m,'Spalle',sel)}" d="M120,50 Q134,50 136,65 Q134,76 124,78 Q118,70 116,56 Z"/>
<path style="${_s(m,'Petto',sel)}" d="M52,54 Q48,56 46,70 Q48,84 60,88 Q72,82 76,70 Q74,56 68,52 Z"/>
<path style="${_s(m,'Petto',sel)}" d="M116,54 Q120,56 122,70 Q120,84 108,88 Q96,82 92,70 Q94,56 100,52 Z"/>
<path style="${_s(m,'Braccia',sel)}" d="M32,78 Q26,84 24,100 Q24,116 30,124 Q38,120 40,104 Q42,88 40,78 Z"/>
<path style="${_s(m,'Braccia',sel)}" d="M136,78 Q142,84 144,100 Q144,116 138,124 Q130,120 128,104 Q126,88 128,78 Z"/>
<path style="${_s(m,'Addome',sel)}" d="M60,90 L108,90 L110,155 Q84,162 78,162 Q72,162 58,155 Z"/>
<line x1="84" y1="90" x2="84" y2="158" stroke="#04040F" stroke-width="1.5" stroke-dasharray="3,3"/>
<line x1="60" y1="108" x2="108" y2="108" stroke="#04040F" stroke-width="1" stroke-dasharray="2,3"/>
<line x1="60" y1="124" x2="108" y2="124" stroke="#04040F" stroke-width="1" stroke-dasharray="2,3"/>
<line x1="60" y1="140" x2="108" y2="140" stroke="#04040F" stroke-width="1" stroke-dasharray="2,3"/>
<path style="${_s(m,'Quadricipiti',sel)}" d="M54,200 Q46,215 44,255 Q44,278 50,290 L66,290 Q70,278 68,255 Q66,215 62,200 Z"/>
<path style="${_s(m,'Quadricipiti',sel)}" d="M114,200 Q122,215 124,255 Q124,278 118,290 L102,290 Q98,278 100,255 Q102,215 106,200 Z"/>
<path style="${_s(m,'Polpacci',sel)}" d="M48,292 Q44,302 45,314 L64,316 Q68,305 66,292 Z"/>
<path style="${_s(m,'Polpacci',sel)}" d="M120,292 Q124,302 123,314 L104,316 Q100,305 102,292 Z"/>
</svg>''';

String _buildBackSvg(MuscleMap m, String? sel) => '''
<svg width="168" height="340" viewBox="0 0 168 340" xmlns="http://www.w3.org/2000/svg">
<rect width="168" height="340" fill="#04040F"/>
<ellipse cx="84" cy="22" rx="18" ry="20" fill="#0d0d1e" stroke="#1a1a3e" stroke-width="1"/>
<rect x="76" y="38" width="16" height="14" rx="3" fill="#0d0d1e" stroke="#1a1a3e" stroke-width="0.5"/>
<path d="M48,50 Q34,52 32,80 L32,160 Q32,168 40,170 L128,170 Q136,168 136,160 L136,80 Q134,52 120,50 Z" fill="#0d0d1e" stroke="#1a1a3e" stroke-width="0.5"/>
<path d="M40,168 Q40,195 54,200 L114,200 Q128,195 128,168 Z" fill="#0d0d1e" stroke="#1a1a3e" stroke-width="0.5"/>
<path d="M54,198 Q46,210 44,260 Q43,290 48,310 L70,310 Q74,290 72,260 Q70,210 64,198 Z" fill="#0d0d1e" stroke="#1a1a3e" stroke-width="0.5"/>
<path d="M114,198 Q122,210 124,260 Q125,290 120,310 L98,310 Q94,290 96,260 Q98,210 104,198 Z" fill="#0d0d1e" stroke="#1a1a3e" stroke-width="0.5"/>
<ellipse cx="59" cy="318" rx="14" ry="7" fill="#0d0d1e" stroke="#1a1a3e" stroke-width="0.5"/>
<ellipse cx="109" cy="318" rx="14" ry="7" fill="#0d0d1e" stroke="#1a1a3e" stroke-width="0.5"/>
<path d="M48,52 Q28,56 24,90 Q22,115 28,130 L40,130 Q42,115 42,90 Q44,64 48,58 Z" fill="#0d0d1e" stroke="#1a1a3e" stroke-width="0.5"/>
<path d="M120,52 Q140,56 144,90 Q146,115 140,130 L128,130 Q126,115 126,90 Q124,64 120,58 Z" fill="#0d0d1e" stroke="#1a1a3e" stroke-width="0.5"/>
<path d="M28,130 Q22,145 24,165 L36,165 Q38,145 40,130 Z" fill="#0d0d1e" stroke="#1a1a3e" stroke-width="0.5"/>
<path d="M140,130 Q146,145 144,165 L132,165 Q130,145 128,130 Z" fill="#0d0d1e" stroke="#1a1a3e" stroke-width="0.5"/>
<ellipse cx="30" cy="172" rx="8" ry="10" fill="#0d0d1e" stroke="#1a1a3e" stroke-width="0.5"/>
<ellipse cx="138" cy="172" rx="8" ry="10" fill="#0d0d1e" stroke="#1a1a3e" stroke-width="0.5"/>
<path style="${_s(m,'Trapezi',sel)}" d="M64,48 Q84,44 104,48 Q114,56 112,70 Q84,76 76,76 Q56,70 56,56 Z"/>
<path style="${_s(m,'Spalle',sel)}" d="M48,50 Q34,50 32,66 Q34,78 44,80 Q52,72 54,56 Z"/>
<path style="${_s(m,'Spalle',sel)}" d="M120,50 Q134,50 136,66 Q134,78 124,80 Q116,72 114,56 Z"/>
<path style="${_s(m,'Schiena',sel)}" d="M56,72 Q40,82 36,110 Q36,140 44,158 L82,158 L82,88 Q70,82 56,72 Z"/>
<path style="${_s(m,'Schiena',sel)}" d="M112,72 Q128,82 132,110 Q132,140 124,158 L86,158 L86,88 Q98,82 112,72 Z"/>
<path style="${_s(m,'Braccia',sel)}" d="M32,78 Q26,86 24,104 Q24,118 30,126 Q38,122 40,106 Q42,90 40,80 Z"/>
<path style="${_s(m,'Braccia',sel)}" d="M136,78 Q142,86 144,104 Q144,118 138,126 Q130,122 128,106 Q126,90 128,80 Z"/>
<path style="${_s(m,'Glutei',sel)}" d="M40,168 Q40,192 54,200 L82,200 L82,168 Z"/>
<path style="${_s(m,'Glutei',sel)}" d="M128,168 Q128,192 114,200 L86,200 L86,168 Z"/>
<path style="${_s(m,'Femorali',sel)}" d="M54,200 Q46,216 44,255 Q44,274 50,286 L68,284 Q72,274 70,254 Q68,216 62,200 Z"/>
<path style="${_s(m,'Femorali',sel)}" d="M114,200 Q122,216 124,255 Q124,274 118,286 L100,284 Q96,274 98,254 Q100,216 106,200 Z"/>
<path style="${_s(m,'Polpacci',sel)}" d="M48,288 Q44,302 46,314 L66,314 Q68,302 66,288 Z"/>
<path style="${_s(m,'Polpacci',sel)}" d="M120,288 Q124,302 122,314 L102,314 Q100,302 102,288 Z"/>
</svg>''';

// ── Legenda ────────────────────────────────────────────────────────────────

class _TierLegend extends StatelessWidget {
  const _TierLegend();

  @override
  Widget build(BuildContext context) {
    final tiers = MuscleTier.values.where((t) => t != MuscleTier.unranked);
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 6,
      children: tiers
          .map(
            (t) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: t.color,
                    shape: BoxShape.circle,
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
            ),
          )
          .toList(),
    );
  }
}