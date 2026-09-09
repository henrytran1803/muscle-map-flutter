export 'body_diagram.dart';
export 'surface_ids.dart';
export 'male_front.dart';
export 'male_back.dart';
export 'female_front.dart';
export 'female_back.dart';

import '../core/types.dart';
import 'body_diagram.dart';
import 'male_front.dart';
import 'male_back.dart';
import 'female_front.dart';
import 'female_back.dart';

/// Get the body diagram for the given sex and view.
BodyDiagram getBodyDiagram(MuscleMapSex sex, MuscleMapView view) {
  if (sex == MuscleMapSex.MALE) {
    return view == MuscleMapView.FRONT ? getMaleFront() : getMaleBack();
  } else {
    return view == MuscleMapView.FRONT ? getFemaleFront() : getFemaleBack();
  }
}
