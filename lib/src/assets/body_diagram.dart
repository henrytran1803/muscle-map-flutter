import '../core/types.dart';

/// Which side of the body a path belongs to.
enum BodySide { LEFT, RIGHT, CENTER }

/// A colorable muscle region.
///
/// Authored once for the LEFT side (or CENTER for midline groups);
/// the RIGHT side is mirrored at render time across centerX.
class MusclePath {
  final MuscleGroup group;
  final BodySide side;
  final String d;
  final String? id;

  const MusclePath({
    required this.group,
    required this.side,
    required this.d,
    this.id,
  });
}

/// Part of the neutral body silhouette (head, neck, torso, limbs, feet).
///
/// Never colored by data — provides the dark body shape behind the muscles.
class OutlinePath {
  final String id;
  final BodySide side;
  final String d;

  const OutlinePath({
    required this.id,
    required this.side,
    required this.d,
  });
}

/// A complete body diagram with outline and muscle paths.
class BodyDiagram {
  final String id;
  final MuscleMapSex sex;
  final MuscleMapView view;
  final String viewBox;
  final double centerX;
  final List<OutlinePath> outline;
  final List<MusclePath> muscles;

  const BodyDiagram({
    required this.id,
    required this.sex,
    required this.view,
    required this.viewBox,
    required this.centerX,
    required this.outline,
    required this.muscles,
  });
}
