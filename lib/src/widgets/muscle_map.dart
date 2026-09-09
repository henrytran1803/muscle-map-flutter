import 'package:flutter/material.dart';
import '../core/types.dart';
import '../core/muscle_meta.dart';
import '../assets/index.dart';
import 'body_figure.dart';
import 'muscle_map_legend.dart';
import 'muscle_group_tree.dart';

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

  /// When true, shows a tree selector below the body figure.
  final bool showTree;

  /// Color used to highlight the active muscle group on the body figure.
  /// Defaults to red-orange when [showTree] is true.
  final Color? highlightColor;

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
    this.showTree = false,
    this.highlightColor,
  });

  @override
  State<MuscleMap> createState() => _MuscleMapState();
}

class _MuscleMapState extends State<MuscleMap> {
  MuscleHit? _hoverHit;
  MuscleGroup? _treeSelectedGroup;

  MuscleGroup? get _activeGroup =>
      _treeSelectedGroup ?? _selectHit?.group ?? _hoverHit?.group;
  MuscleHit? get _selectHit => _hoverHit;

  MuscleMapValue? _resolveValue(MuscleGroup group) {
    return widget.values[group];
  }

  Color get _effectiveHighlightColor =>
      widget.highlightColor ?? const Color(0xFFF97316);

  @override
  Widget build(BuildContext context) {
    final diagram = getBodyDiagram(widget.sex, widget.view);
    final visibleGroups = getVisibleMuscleGroups(view: widget.view);

    final bodyFigure = BodyFigure(
      diagram: diagram,
      values: widget.values,
      partValues: widget.partValues,
      colorModel: widget.colorModel,
      monochromeColor: widget.monochromeColor,
      monochromeBaseColor: widget.monochromeBaseColor,
      visibleGroups: visibleGroups.toSet(),
      activeGroup: _activeGroup,
      activeColor: widget.showTree ? _effectiveHighlightColor : null,
      glow: widget.glow,
      width: widget.figureWidth,
      onHover: (hit) {
        setState(() => _hoverHit = hit);
      },
      onSelect: (hit) {
        if (widget.showTree) {
          setState(() => _treeSelectedGroup = hit.group);
        }
        widget.onSelectMuscle?.call(MuscleMapSelection(
          group: hit.group,
          value: _resolveValue(hit.group),
        ));
      },
    );

    if (widget.showTree) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          bodyFigure,
          if (widget.showLegend) ...[
            const SizedBox(height: 12),
            MuscleMapLegend(
              colorModel: widget.colorModel,
              monochromeColor: widget.monochromeColor,
              monochromeBaseColor: widget.monochromeBaseColor,
              minLabel: widget.legendMinLabel,
              maxLabel: widget.legendMaxLabel,
            ),
          ],
          const SizedBox(height: 16),
          MuscleGroupTree(
            selectedGroup: _treeSelectedGroup,
            view: widget.view,
            values: widget.values,
            accentColor: _effectiveHighlightColor,
            onSelectGroup: (group) {
              setState(() {
                _treeSelectedGroup =
                    _treeSelectedGroup == group ? null : group;
              });
              widget.onSelectMuscle?.call(MuscleMapSelection(
                group: group,
                value: _resolveValue(group),
              ));
            },
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        bodyFigure,
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
        if (_activeGroup != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _MuscleTooltip(
              group: _activeGroup!,
              value: _resolveValue(_activeGroup!),
            ),
          ),
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
