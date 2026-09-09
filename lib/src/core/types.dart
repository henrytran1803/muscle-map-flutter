/// Muscle group identifiers matching the TypeScript MuscleGroup enum.
enum MuscleGroup {
  TRAPEZIUS_LEFT,
  TRAPEZIUS_RIGHT,
  DELTOID_LEFT,
  DELTOID_RIGHT,
  PECTORALIS_MAJOR_LEFT,
  PECTORALIS_MAJOR_RIGHT,
  BICEPS_LEFT,
  BICEPS_RIGHT,
  TRICEPS_LEFT,
  TRICEPS_RIGHT,
  FOREARM_LEFT,
  FOREARM_RIGHT,
  RECTUS_ABDOMINIS,
  OBLIQUES_LEFT,
  OBLIQUES_RIGHT,
  QUADRICEPS_LEFT,
  QUADRICEPS_RIGHT,
  HAMSTRING_LEFT,
  HAMSTRING_RIGHT,
  GASTROCNEMIUS_LEFT,
  GASTROCNEMIUS_RIGHT,
  GLUTEUS_LEFT,
  GLUTEUS_RIGHT,
}

/// Body sex for selecting the correct diagram.
enum MuscleMapSex { MALE, FEMALE }

/// Which view of the body to display.
enum MuscleMapView { FRONT, BACK }

/// Color model used to map values to colors.
enum MuscleColorModel {
  /// Discrete stepped color scale.
  LOAD,

  /// Weighted multi-criteria scale.
  FREQUENCY,

  /// Symmetry comparison between left/right.
  BALANCE,

  /// Risk-based heatmap.
  RECOVERY_RISK,
}

/// A single muscle group value (0–100).
class MuscleMapValue {
  final MuscleGroup group;
  final double value;

  const MuscleMapValue({required this.group, required this.value});
}

/// Per-surface overrides keyed by [MusclePartId] strings.
typedef PartValues = Map<String, double>;
