import 'package:flutter/material.dart';
import '../core/types.dart';
import '../core/muscle_meta.dart';
import '../assets/index.dart';
import 'body_figure.dart';
import 'muscle_map_legend.dart';

/// Main muscle map widget showing front/back body diagrams with colored overlays.
class MuscleMap extends StatefulWidget {
  final Map<MuscleGroup, MuscleMapValue> values;
  final PartValues? partValues;
  final MuscleMapSex sex;
  final MuscleMapView view;
  final MuscleColorModel colorModel;
  final Color? monochromeColor;
  final Color? monochromeBaseColor;
  final bool glow;
  final bool showLegend;
  final double figureWidth;
  final String? legendMinLabel;
  final String? legendMaxLabel;
  final ValueChanged<MuscleMapSelection>? onSelectMuscle;

  const MuscleMap({
    super.key,
    required this.values,
    this.partValues,
    this.sex = MuscleMapSex.MALE,
    this.view = MuscleMapView.FRONT,
    this.colorModel = MuscleColorModel.LOAD,
    this.monochromeColor,
    this.monochromeBaseColor,
    this.glow = true,
    this.showLegend = true,
    this.figureWidth = 200,
    this.legendMinLabel,
    this.legendMaxLabel,
    this.onSelectMuscle,
  });

  @override
  State<MuscleMap> createState() => _MuscleMapState();
}

class _MuscleMapState extends State<MuscleMap> {
  MuscleGroup? _hoveredGroup;
  MuscleGroup? _selectedGroup;

  @override
  Widget build(BuildContext context) {
    final diagram = getBodyDiagram(widget.sex, widget.view);
    final visibleGroups = getVisibleMuscleGroups(view: widget.view);
    final activeGroup = _selectedGroup ?? _hoveredGroup;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BodyFigure(
              diagram: diagram,
              values: widget.values,
              partValues: widget.partValues,
              colorModel: widget.colorModel,
              monochromeColor: widget.monochromeColor,
              monochromeBaseColor: widget.monochromeBaseColor,
              visibleGroups: visibleGroups.toSet(),
              activeGroup: activeGroup,
              glow: widget.glow,
              width: widget.figureWidth,
              onHover: (group) => setState(() => _hoveredGroup = group),
              onSelect: (group) {
                setState(() {
                  _selectedGroup = _selectedGroup == group ? null : group;
                });
                widget.onSelectMuscle?.call(MuscleMapSelection(
                  group: group,
                  value: widget.values[group],
                ));
              },
            ),
          ],
        ),
        if (widget.showLegend) ...[
          const SizedBox(height: 18),
          MuscleMapLegend(
            colorModel: widget.colorModel,
            monochromeColor: widget.monochromeColor,
            monochromeBaseColor: widget.monochromeBaseColor,
            minLabel: widget.legendMinLabel,
            maxLabel: widget.legendMaxLabel,
          ),
        ],
      ],
    );
  }
}

/// Selection event from the muscle map.
class MuscleMapSelection {
  final MuscleGroup group;
  final MuscleMapValue? value;

  const MuscleMapSelection({required this.group, this.value});
}
