[![pub package](https://img.shields.io/pub/v/muscle_map_flutter.svg)](https://pub.dev/packages/muscle_map_flutter)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](https://opensource.org/licenses/MIT)

# muscle_map_flutter

Muscle heatmap visualization widget for Flutter. Renders front/back body diagrams with colored muscle overlays using CustomPainter.

## Features

- Front and back body diagrams for male and female
- 4 color models: Load, Frequency, Balance, Recovery Risk
- Monochrome color scale (grey → brand color)
- Per-surface value overrides via `PartValues`
- Interactive hover/tap with muscle name + score tooltip
- Gradient legend bar
- Glow effects for active muscles
- CustomPainter-based rendering (zero external dependencies)

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  muscle_map_flutter:
    git:
      url: https://github.com/henrytran1803/muscle-map-flutter.git
```

## Usage

```dart
import 'package:muscle_map_flutter/muscle_map_flutter.dart';

// Basic usage
MuscleMap(
  values: {
    MuscleGroup.BICEPS_LEFT: MuscleMapValue(group: MuscleGroup.BICEPS_LEFT, value: 75),
    MuscleGroup.QUADRICEPS_RIGHT: MuscleMapValue(group: MuscleGroup.QUADRICEPS_RIGHT, value: 45),
  },
  sex: MuscleMapSex.MALE,
  view: MuscleMapView.FRONT,
  colorModel: MuscleColorModel.LOAD,
  figureWidth: 250,
  onSelectMuscle: (selection) {
    print('Selected: ${selection.group}, Score: ${selection.value?.value}');
  },
)
```

## API Reference

### MuscleMap

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `values` | `Map<MuscleGroup, MuscleMapValue>` | required | Score values for each muscle group (0–100) |
| `partValues` | `PartValues?` | `null` | Per-surface overrides keyed by surface ID |
| `sex` | `MuscleMapSex` | `MALE` | Body sex (`MALE` / `FEMALE`) |
| `view` | `MuscleMapView` | `FRONT` | Body view (`FRONT` / `BACK`) |
| `colorModel` | `MuscleColorModel` | `LOAD` | Color model for heatmap |
| `monochromeColor` | `Color?` | `null` | Override color model with single-color scale |
| `glow` | `bool` | `true` | Glow effect behind active muscles |
| `showLegend` | `bool` | `true` | Show gradient legend bar |
| `figureWidth` | `double` | `200` | Figure width in pixels |
| `onSelectMuscle` | `ValueChanged<MuscleMapSelection>?` | `null` | Tap callback |

### MuscleGroup enum (23 values)

Left/right bilateral muscles:
`TRAPEZIUS_LEFT/RIGHT`, `DELTOID_LEFT/RIGHT`, `PECTORALIS_MAJOR_LEFT/RIGHT`,
`BICEPS_LEFT/RIGHT`, `TRICEPS_LEFT/RIGHT`, `FOREARM_LEFT/RIGHT`,
`OBLIQUES_LEFT/RIGHT`, `QUADRICEPS_LEFT/RIGHT`, `HAMSTRING_LEFT/RIGHT`,
`GASTROCNEMIUS_LEFT/RIGHT`, `GLUTEUS_LEFT/RIGHT`

Center: `RECTUS_ABDOMINIS`

### Color Models

| Model | Description |
|-------|-------------|
| `LOAD` | Blue → Cyan → Green → Yellow → Orange → Red |
| `FREQUENCY` | Similar with different breakpoints |
| `BALANCE` | Violet → Sky → Green → Orange → Red |
| `RECOVERY_RISK` | Green → Yellow → Orange → Red |

### Per-surface overrides

```dart
MuscleMap(
  values: values,
  partValues: {
    'TRAPEZIUS_LEFT': 90,
    'BICEPS_RIGHT': 30,
  },
)
```

## Additional Widgets

```dart
// Standalone legend
MuscleMapLegend(
  colorModel: MuscleColorModel.LOAD,
  minLabel: 'Low',
  maxLabel: 'High',
)

// Low-level body figure
BodyFigure(
  diagram: getBodyDiagram(MuscleMapSex.MALE, MuscleMapView.FRONT),
  values: values,
  width: 200,
)
```

## License

MIT License. See [LICENSE](LICENSE) for details.
