import 'types.dart';

/// Metadata for a muscle group.
class MuscleGroupMeta {
  final MuscleGroup group;
  final String name;
  final List<String> regions;
  final bool bilateral;
  final bool visibleByDefault;

  const MuscleGroupMeta({
    required this.group,
    required this.name,
    required this.regions,
    this.bilateral = false,
    this.visibleByDefault = true,
  });
}

/// All muscle group metadata.
const List<MuscleGroupMeta> muscleGroupMeta = [
  MuscleGroupMeta(group: MuscleGroup.TRAPEZIUS_LEFT, name: 'Trapezius', regions: ['shoulder'], bilateral: true),
  MuscleGroupMeta(group: MuscleGroup.TRAPEZIUS_RIGHT, name: 'Trapezius', regions: ['shoulder'], bilateral: true),
  MuscleGroupMeta(group: MuscleGroup.DELTOID_LEFT, name: 'Deltoid', regions: ['shoulder'], bilateral: true),
  MuscleGroupMeta(group: MuscleGroup.DELTOID_RIGHT, name: 'Deltoid', regions: ['shoulder'], bilateral: true),
  MuscleGroupMeta(group: MuscleGroup.PECTORALIS_MAJOR_LEFT, name: 'Pectoralis Major', regions: ['chest'], bilateral: true),
  MuscleGroupMeta(group: MuscleGroup.PECTORALIS_MAJOR_RIGHT, name: 'Pectoralis Major', regions: ['chest'], bilateral: true),
  MuscleGroupMeta(group: MuscleGroup.BICEPS_LEFT, name: 'Biceps', regions: ['arm'], bilateral: true),
  MuscleGroupMeta(group: MuscleGroup.BICEPS_RIGHT, name: 'Biceps', regions: ['arm'], bilateral: true),
  MuscleGroupMeta(group: MuscleGroup.TRICEPS_LEFT, name: 'Triceps', regions: ['arm'], bilateral: true),
  MuscleGroupMeta(group: MuscleGroup.TRICEPS_RIGHT, name: 'Triceps', regions: ['arm'], bilateral: true),
  MuscleGroupMeta(group: MuscleGroup.FOREARM_LEFT, name: 'Forearm', regions: ['arm'], bilateral: true),
  MuscleGroupMeta(group: MuscleGroup.FOREARM_RIGHT, name: 'Forearm', regions: ['arm'], bilateral: true),
  MuscleGroupMeta(group: MuscleGroup.RECTUS_ABDOMINIS, name: 'Rectus Abdominis', regions: ['core']),
  MuscleGroupMeta(group: MuscleGroup.OBLIQUES_LEFT, name: 'Obliques', regions: ['core'], bilateral: true),
  MuscleGroupMeta(group: MuscleGroup.OBLIQUES_RIGHT, name: 'Obliques', regions: ['core'], bilateral: true),
  MuscleGroupMeta(group: MuscleGroup.QUADRICEPS_LEFT, name: 'Quadriceps', regions: ['leg'], bilateral: true),
  MuscleGroupMeta(group: MuscleGroup.QUADRICEPS_RIGHT, name: 'Quadriceps', regions: ['leg'], bilateral: true),
  MuscleGroupMeta(group: MuscleGroup.HAMSTRING_LEFT, name: 'Hamstring', regions: ['leg'], bilateral: true),
  MuscleGroupMeta(group: MuscleGroup.HAMSTRING_RIGHT, name: 'Hamstring', regions: ['leg'], bilateral: true),
  MuscleGroupMeta(group: MuscleGroup.GASTROCNEMIUS_LEFT, name: 'Gastrocnemius', regions: ['leg'], bilateral: true),
  MuscleGroupMeta(group: MuscleGroup.GASTROCNEMIUS_RIGHT, name: 'Gastrocnemius', regions: ['leg'], bilateral: true),
  MuscleGroupMeta(group: MuscleGroup.GLUTEUS_LEFT, name: 'Gluteus', regions: ['glute'], bilateral: true),
  MuscleGroupMeta(group: MuscleGroup.GLUTEUS_RIGHT, name: 'Gluteus', regions: ['glute'], bilateral: true),
];

/// Get meta for a specific muscle group.
MuscleGroupMeta? getMuscleGroupMeta(MuscleGroup group) {
  try {
    return muscleGroupMeta.firstWhere((m) => m.group == group);
  } catch (_) {
    return null;
  }
}

/// Human-readable name for a muscle group.
String humanizeMuscleGroup(MuscleGroup group) {
  return getMuscleGroupMeta(group)?.name ?? group.name;
}

/// Get muscle groups visible for the given view and optional region filter.
List<MuscleGroup> getVisibleMuscleGroups({
  required MuscleMapView view,
  String? region,
}) {
  final isFront = view == MuscleMapView.FRONT;
  return muscleGroupMeta
      .where((m) => m.visibleByDefault)
      .where((m) {
        // Filter by region if provided
        if (region != null && !m.regions.contains(region)) return false;
        // Front view hides glutes
        if (isFront && m.regions.contains('glute')) return false;
        return true;
      })
      .map((m) => m.group)
      .toList();
}

/// Get muscles in a specific region.
List<MuscleGroup> getMusclesInRegion(String region) {
  return muscleGroupMeta
      .where((m) => m.regions.contains(region))
      .map((m) => m.group)
      .toList();
}

/// Default legend labels.
const Map<String, String> defaultLegendLabels = {
  'low': 'Low',
  'mid': 'Medium',
  'high': 'High',
};
