import 'package:flutter/material.dart';
import 'types.dart';

/// Color stop: value threshold → color.
class ColorStop {
  final double value;
  final Color color;

  const ColorStop(this.value, this.color);
}

/// Stepped color scale definition per color model.
const Map<MuscleColorModel, List<ColorStop>> _colorScales = {
  MuscleColorModel.LOAD: [
    ColorStop(0, Color(0xFF3B82F6)),   // blue
    ColorStop(30, Color(0xFF22C55E)),  // green
    ColorStop(60, Color(0xFFF59E0B)),  // amber
    ColorStop(80, Color(0xFFF97316)),  // orange
    ColorStop(100, Color(0xFFEF4444)), // red
  ],
  MuscleColorModel.FREQUENCY: [
    ColorStop(0, Color(0xFF3B82F6)),
    ColorStop(20, Color(0xFF22C55E)),
    ColorStop(40, Color(0xFF84CC16)),
    ColorStop(60, Color(0xFFF59E0B)),
    ColorStop(80, Color(0xFFF97316)),
    ColorStop(100, Color(0xFFEF4444)),
  ],
  MuscleColorModel.RECOVERY_RISK: [
    ColorStop(0, Color(0xFF22C55E)),
    ColorStop(50, Color(0xFFF59E0B)),
    ColorStop(100, Color(0xFFEF4444)),
  ],
};

/// Balance model uses fixed colors for imbalance vs balanced.
Color getBalanceColor(double value) {
  if (value < 30) return const Color(0xFFEF4444); // imbalanced
  if (value < 60) return const Color(0xFFF59E0B); // moderate
  return const Color(0xFF22C55E); // balanced
}

/// Interpolate between two colors by factor [t] (0–1).
Color _lerpColor(Color a, Color b, double t) {
  return Color.lerp(a, b, t)!;
}

/// Get the color for a muscle value using the given color model.
Color getMuscleColor({
  required MuscleColorModel colorModel,
  required double value,
}) {
  if (colorModel == MuscleColorModel.BALANCE) {
    return getBalanceColor(value);
  }

  final stops = _colorScales[colorModel];
  if (stops == null || stops.isEmpty) return const Color(0xFF64748B);

  if (value <= stops.first.value) return stops.first.color;
  if (value >= stops.last.value) return stops.last.color;

  for (var i = 0; i < stops.length - 1; i++) {
    final a = stops[i];
    final b = stops[i + 1];
    if (value >= a.value && value <= b.value) {
      final t = (value - a.value) / (b.value - a.value);
      return _lerpColor(a.color, b.color, t);
    }
  }

  return stops.last.color;
}

/// Get gradient stops for a legend bar (0–100 range).
List<ColorStop> getColorScaleStops(MuscleColorModel colorModel) {
  if (colorModel == MuscleColorModel.BALANCE) {
    return const [
      ColorStop(0, Color(0xFFEF4444)),
      ColorStop(50, Color(0xFFF59E0B)),
      ColorStop(100, Color(0xFF22C55E)),
    ];
  }
  return _colorScales[colorModel] ?? _colorScales[MuscleColorModel.LOAD]!;
}
