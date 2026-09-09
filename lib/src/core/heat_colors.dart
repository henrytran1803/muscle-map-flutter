import 'package:flutter/material.dart';
import 'types.dart';
import 'color_scales.dart';

/// Continuous color ramps for smooth heatmap fills.
class HeatColorStop {
  final double offset;
  final Color color;

  const HeatColorStop(this.offset, this.color);
}

double _clampScore(double v) => v.clamp(0.0, 100.0);

const Map<MuscleColorModel, List<HeatColorStop>> _heatScales = {
  MuscleColorModel.LOAD: [
    HeatColorStop(0.0, Color(0xFF1e293b)),
    HeatColorStop(0.12, Color(0xFF0ea5e9)),
    HeatColorStop(0.34, Color(0xFF22d3ee)),
    HeatColorStop(0.52, Color(0xFF22c55e)),
    HeatColorStop(0.68, Color(0xFFfacc15)),
    HeatColorStop(0.84, Color(0xFFf97316)),
    HeatColorStop(1.0, Color(0xFFef4444)),
  ],
  MuscleColorModel.FREQUENCY: [
    HeatColorStop(0.0, Color(0xFF1e293b)),
    HeatColorStop(0.18, Color(0xFF0ea5e9)),
    HeatColorStop(0.45, Color(0xFF22c55e)),
    HeatColorStop(0.72, Color(0xFFf97316)),
    HeatColorStop(1.0, Color(0xFFef4444)),
  ],
  MuscleColorModel.BALANCE: [
    HeatColorStop(0.0, Color(0xFF8b5cf6)),
    HeatColorStop(0.32, Color(0xFF38bdf8)),
    HeatColorStop(0.52, Color(0xFF22c55e)),
    HeatColorStop(0.74, Color(0xFFf97316)),
    HeatColorStop(1.0, Color(0xFFef4444)),
  ],
  MuscleColorModel.RECOVERY_RISK: [
    HeatColorStop(0.0, Color(0xFF22c55e)),
    HeatColorStop(0.4, Color(0xFFfacc15)),
    HeatColorStop(0.7, Color(0xFFf97316)),
    HeatColorStop(1.0, Color(0xFFef4444)),
  ],
};

/// Smoothly interpolated heatmap color for a 0–100 score.
Color getMuscleHeatColor(double score, {MuscleColorModel colorModel = MuscleColorModel.LOAD}) {
  final t = _clampScore(score) / 100.0;
  final stops = _heatScales[colorModel] ?? _heatScales[MuscleColorModel.LOAD]!;

  if (t <= stops.first.offset) return stops.first.color;
  if (t >= stops.last.offset) return stops.last.color;

  for (var i = 0; i < stops.length - 1; i++) {
    final current = stops[i];
    final next = stops[i + 1];
    if (t >= current.offset && t <= next.offset) {
      final span = next.offset - current.offset;
      final local = span > 0 ? (t - current.offset) / span : 0.0;
      return Color.lerp(current.color, next.color, local)!;
    }
  }

  return stops.last.color;
}

/// Monochrome color: blends [baseColor] → [color] by score.
Color getMonochromeColor(
  double score,
  Color color, {
  Color baseColor = const Color(0xFF6b7280),
}) {
  return Color.lerp(baseColor, color, _clampScore(score) / 100.0)!;
}

/// Gradient stops for a monochrome scale.
List<ColorStop> getMonochromeScaleStops(
  Color color, {
  Color baseColor = const Color(0xFF6b7280),
}) {
  return [
    ColorStop(0, baseColor),
    ColorStop(100, color),
  ];
}
