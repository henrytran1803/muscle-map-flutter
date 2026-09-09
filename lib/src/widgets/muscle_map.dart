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
  Offset _tooltipPosition = Offset.zero;
  final GlobalKey _figureKey = GlobalKey();

  MuscleGroup? get _activeGroup => _selectedGroup ?? _hoveredGroup;

  MuscleMapValue? _resolveValue(MuscleGroup group) {
    return widget.values[group];
  }

  @override
  Widget build(BuildContext context) {
    final diagram = getBodyDiagram(widget.sex, widget.view);
    final visibleGroups = getVisibleMuscleGroups(view: widget.view);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            // Body figure
            BodyFigure(
              key: _figureKey,
              diagram: diagram,
              values: widget.values,
              partValues: widget.partValues,
              colorModel: widget.colorModel,
              monochromeColor: widget.monochromeColor,
              monochromeBaseColor: widget.monochromeBaseColor,
              visibleGroups: visibleGroups.toSet(),
              activeGroup: _activeGroup,
              glow: widget.glow,
              width: widget.figureWidth,
              onHover: (group) {
                setState(() => _hoveredGroup = group);
              },
              onSelect: (group) {
                setState(() {
                  _selectedGroup = _selectedGroup == group ? null : group;
                });
                final value = _resolveValue(group);
                widget.onSelectMuscle?.call(MuscleMapSelection(
                  group: group,
                  value: value,
                ));
              },
            ),

            // Tooltip overlay
            if (_activeGroup != null)
              Positioned(
                left: _tooltipPosition.dx,
                top: _tooltipPosition.dy,
                child: _MuscleTooltip(
                  group: _activeGroup!,
                  value: _resolveValue(_activeGroup!),
                ),
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

/// Tooltip showing muscle group name and score.
class _MuscleTooltip extends StatelessWidget {
  final MuscleGroup group;
  final MuscleMapValue? value;

  const _MuscleTooltip({required this.group, this.value});

  @override
  Widget build(BuildContext context) {
    final name = humanizeMuscleGroup(group);
    final score = value?.value;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      constraints: const BoxConstraints(minWidth: 92),
      decoration: BoxDecoration(
        color: const Color(0xF20A0E16),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x2E94A3B8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x80000000),
            blurRadius: 34,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.02,
              color: Color(0xFFF8FAFC),
            ),
          ),
          if (score != null) ...[
            const SizedBox(height: 4),
            Text(
              'Score: ${score.round()}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFCBD5E1),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Selection event from the muscle map.
class MuscleMapSelection {
  final MuscleGroup group;
  final MuscleMapValue? value;

  const MuscleMapSelection({required this.group, this.value});
}
