import '../core/types.dart';

/// Every addressable surface ID across all bundled bodies.
/// Use as `partValues` keys.
const List<String> musclePartIds = [
  'ABDUCTOR_LEFT',
  'ABDUCTOR_RIGHT',
  'ADDUCTOR_LEFT',
  'ADDUCTOR_RIGHT',
  'BICEPS_LEFT',
  'BICEPS_RIGHT',
  'CALVES_LEFT',
  'CALVES_RIGHT',
  'CHEST_LEFT',
  'CHEST_RIGHT',
  'CORE_LEFT',
  'CORE_RIGHT',
  'FOREARM_LEFT',
  'FOREARM_RIGHT',
  'GLUTEUS_LEFT',
  'GLUTEUS_RIGHT',
  'HAMSTRINGS_LEFT',
  'HAMSTRINGS_RIGHT',
  'LATISSIMUS_LEFT',
  'LATISSIMUS_RIGHT',
  'LOWER_BACK_LEFT',
  'LOWER_BACK_RIGHT',
  'OBLIQUE_LEFT',
  'OBLIQUE_RIGHT',
  'QUADRICEPS_LEFT',
  'QUADRICEPS_RIGHT',
  'RHOMBOID_LEFT',
  'RHOMBOID_RIGHT',
  'SHOULDER_FRONT_LEFT',
  'SHOULDER_FRONT_RIGHT',
  'SHOULDER_REAR_LEFT',
  'SHOULDER_REAR_RIGHT',
  'SHOULDER_SIDE_LEFT',
  'SHOULDER_SIDE_RIGHT',
  'TRAPEZIUS',
  'TRAPEZIUS_LEFT',
  'TRAPEZIUS_RIGHT',
  'TRICEPS_LEFT',
  'TRICEPS_RIGHT',
];

/// Which surface IDs belong to each muscle group.
const Map<MuscleGroup, List<String>> muscleGroupParts = {
  MuscleGroup.PECTORALIS_MAJOR_LEFT: ['CHEST_LEFT'],
  MuscleGroup.PECTORALIS_MAJOR_RIGHT: ['CHEST_RIGHT'],
  MuscleGroup.RECTUS_ABDOMINIS: ['CORE_LEFT', 'CORE_RIGHT'],
  MuscleGroup.OBLIQUES_LEFT: ['OBLIQUE_LEFT'],
  MuscleGroup.OBLIQUES_RIGHT: ['OBLIQUE_RIGHT'],
  MuscleGroup.TRAPEZIUS_LEFT: ['TRAPEZIUS_LEFT'],
  MuscleGroup.TRAPEZIUS_RIGHT: ['TRAPEZIUS_RIGHT'],
  MuscleGroup.DELTOID_LEFT: ['SHOULDER_FRONT_LEFT', 'SHOULDER_SIDE_LEFT', 'SHOULDER_REAR_LEFT'],
  MuscleGroup.DELTOID_RIGHT: ['SHOULDER_FRONT_RIGHT', 'SHOULDER_SIDE_RIGHT', 'SHOULDER_REAR_RIGHT'],
  MuscleGroup.BICEPS_LEFT: ['BICEPS_LEFT'],
  MuscleGroup.BICEPS_RIGHT: ['BICEPS_RIGHT'],
  MuscleGroup.TRICEPS_LEFT: ['TRICEPS_LEFT'],
  MuscleGroup.TRICEPS_RIGHT: ['TRICEPS_RIGHT'],
  MuscleGroup.FOREARM_LEFT: ['FOREARM_LEFT'],
  MuscleGroup.FOREARM_RIGHT: ['FOREARM_RIGHT'],
  MuscleGroup.GLUTEUS_LEFT: ['GLUTEUS_LEFT'],
  MuscleGroup.GLUTEUS_RIGHT: ['GLUTEUS_RIGHT'],
  MuscleGroup.QUADRICEPS_LEFT: ['QUADRICEPS_LEFT'],
  MuscleGroup.QUADRICEPS_RIGHT: ['QUADRICEPS_RIGHT'],
  MuscleGroup.HAMSTRING_LEFT: ['HAMSTRINGS_LEFT'],
  MuscleGroup.HAMSTRING_RIGHT: ['HAMSTRINGS_RIGHT'],
  MuscleGroup.GASTROCNEMIUS_LEFT: ['CALVES_LEFT'],
  MuscleGroup.GASTROCNEMIUS_RIGHT: ['CALVES_RIGHT'],
};

/// Get the muscle group that a surface ID belongs to.
MuscleGroup? getMuscleGroupForPart(String partId) {
  for (final entry in muscleGroupParts.entries) {
    if (entry.value.contains(partId)) return entry.key;
  }
  return null;
}
