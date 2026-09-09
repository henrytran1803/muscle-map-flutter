# muscle-map-flutter

Muscle heatmap visualization widget for Flutter. Renders front/back body diagrams with colored muscle overlays using CustomPainter.

## Features

- Front and back body diagrams for male and female
- Multiple color models: Load, Frequency, Balance, Recovery Risk
- Per-surface value overrides via `PartValues`
- Gradient legend bar
- CustomPainter-based rendering (no external SVG dependencies)
- Glow effects for active muscles

## Usage

```dart
import 'package:muscle_map_flutter/muscle_map_flutter.dart';

MuscleMap(
  values: {
    MuscleGroup.BICEPS_LEFT: MuscleMapValue(group: MuscleGroup.BICEPS_LEFT, value: 75),
    MuscleGroup.QUADRICEPS_RIGHT: MuscleMapValue(group: MuscleGroup.QUADRICEPS_RIGHT, value: 45),
  },
  sex: MuscleMapSex.MALE,
  view: MuscleMapView.FRONT,
  colorModel: MuscleColorModel.LOAD,
  figureWidth: 250,
)
```

## Getting Started

Add to your `pubspec.yaml`:

```yaml
dependencies:
  muscle_map_flutter:
    git:
      url: https://github.com/henrytran1803/muscle-map-flutter.git
```
