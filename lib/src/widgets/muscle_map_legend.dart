import 'package:flutter/material.dart';
import '../core/types.dart';
import '../core/color_scales.dart';
import '../core/heat_colors.dart';

/// Gradient legend bar for the muscle map.
class MuscleMapLegend extends StatelessWidget {
  final MuscleColorModel colorModel;
  final Color? monochromeColor;
  final Color? monochromeBaseColor;
  final String? minLabel;
  final String? maxLabel;
  final double height;

  const MuscleMapLegend({
    super.key,
    this.colorModel = MuscleColorModel.LOAD,
    this.monochromeColor,
    this.monochromeBaseColor,
    this.minLabel,
    this.maxLabel,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    final defaults = _defaultLabels[colorModel] ?? _defaultLabels[MuscleColorModel.LOAD]!;
    final min = minLabel ?? defaults['min']!;
    final max = maxLabel ?? defaults['max']!;

    List<ColorStop> stops;
    if (monochromeColor != null) {
      stops = getMonochromeScaleStops(
        monochromeColor!,
        baseColor: monochromeBaseColor ?? const Color(0xFF6b7280),
      );
    } else {
      stops = getColorScaleStops(colorModel);
    }

    return Row(
      children: [
        Text(min, style: const TextStyle(fontSize: 12, color: Color(0xFF94a3b8))),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: LinearGradient(
                colors: stops.map((s) => s.color).toList(),
                stops: stops.map((s) => s.value / 100).toList(),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(max, style: const TextStyle(fontSize: 12, color: Color(0xFF94a3b8))),
      ],
    );
  }

  static const Map<MuscleColorModel, Map<String, String>> _defaultLabels = {
    MuscleColorModel.LOAD: {'min': 'Low', 'max': 'High'},
    MuscleColorModel.FREQUENCY: {'min': 'Low', 'max': 'High'},
    MuscleColorModel.BALANCE: {'min': 'Imbalanced', 'max': 'Balanced'},
    MuscleColorModel.RECOVERY_RISK: {'min': 'Low Risk', 'max': 'High Risk'},
  };
}
