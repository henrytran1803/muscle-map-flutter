import 'dart:math';
import 'package:flutter/material.dart';
import '../assets/body_diagram.dart';
import '../core/types.dart';
import '../core/heat_colors.dart';
import 'svg_path_parser.dart';

const Color _neutralBase = Color(0xFF33405a);
const Color _neutralEdge = Color(0xFF212c40);
const Color _muscleDim = Color(0xFF3a465e);
const Color _stroke = Color(0x99060a12);

class MuscleHit {
  final MuscleGroup group;
  final Offset center;

  const MuscleHit({required this.group, required this.center});
}

class BodyFigure extends StatefulWidget {
  final BodyDiagram diagram;
  final Map<MuscleGroup, MuscleMapValue> values;
  final PartValues? partValues;
  final MuscleColorModel colorModel;
  final Color? monochromeColor;
  final Color? monochromeBaseColor;
  final Set<MuscleGroup> visibleGroups;
  final MuscleGroup? activeGroup;

  /// Color for the active group stroke and fill highlight. Defaults to white.
  final Color? activeColor;

  final bool glow;
  final double width;
  final ValueChanged<MuscleHit?>? onHover;
  final ValueChanged<MuscleHit>? onSelect;

  const BodyFigure({
    super.key,
    required this.diagram,
    required this.values,
    this.partValues,
    this.colorModel = MuscleColorModel.LOAD,
    this.monochromeColor,
    this.monochromeBaseColor,
    this.visibleGroups = const {},
    this.activeGroup,
    this.activeColor,
    this.glow = true,
    this.width = 200,
    this.onHover,
    this.onSelect,
  });

  @override
  State<BodyFigure> createState() => _BodyFigureState();
}

class _BodyFigureState extends State<BodyFigure> {
  final Map<MuscleGroup, Path> _hitPaths = {};
  final Map<MuscleGroup, Offset> _muscleCenters = {};
  String? _lastDiagramId;
  double _lastWidth = 0;

  void _rebuildHitPaths(Size size) {
    _hitPaths.clear();
    _muscleCenters.clear();

    final diagram = widget.diagram;
    final vbParts = diagram.viewBox.split(RegExp(r'\s+'));
    final vbX = double.parse(vbParts[0]);
    final vbY = double.parse(vbParts[1]);
    final vbW = double.parse(vbParts[2]);
    final vbH = double.parse(vbParts[3]);

    final scaleX = size.width / vbW;
    final scaleY = size.height / vbH;
    final s = min(scaleX, scaleY);

    final offsetX = (size.width - vbW * s) / 2 - vbX * s;
    final offsetY = (size.height - vbH * s) / 2 - vbY * s;

    final matrix = Matrix4.identity();
    matrix.setEntry(0, 3, offsetX);
    matrix.setEntry(1, 3, offsetY);
    // ignore: deprecated_member_use
    matrix.scale(s);

    final mirrorMatrix = Matrix4.identity();
    mirrorMatrix.setEntry(0, 3, offsetX + 2 * diagram.centerX * s);
    mirrorMatrix.setEntry(1, 3, offsetY);
    // ignore: deprecated_member_use
    mirrorMatrix.scale(-s, s);

    for (final muscle in diagram.muscles) {
      final path = SvgPathParser.parse(muscle.d);

      final leftPath = path.transform(matrix.storage);
      final existing = _hitPaths[muscle.group];
      if (existing != null) {
        final merged = Path.combine(PathOperation.union, existing, leftPath);
        _hitPaths[muscle.group] = merged;
        _muscleCenters[muscle.group] = merged.getBounds().center;
      } else {
        _hitPaths[muscle.group] = leftPath;
        _muscleCenters[muscle.group] = leftPath.getBounds().center;
      }

      if (muscle.side != BodySide.CENTER) {
        final rightPath = path.transform(mirrorMatrix.storage);
        final current = _hitPaths[muscle.group];
        if (current != null) {
          final merged = Path.combine(PathOperation.union, current, rightPath);
          _hitPaths[muscle.group] = merged;
          _muscleCenters[muscle.group] = merged.getBounds().center;
        }
      }
    }
  }

  MuscleHit? _hitTest(Offset localPosition) {
    final groups = widget.diagram.muscles.map((m) => m.group).toSet().toList();
    for (var i = groups.length - 1; i >= 0; i--) {
      final group = groups[i];
      final path = _hitPaths[group];
      if (path != null && path.contains(localPosition)) {
        if (widget.visibleGroups.isEmpty || widget.visibleGroups.contains(group)) {
          return MuscleHit(
            group: group,
            center: _muscleCenters[group] ?? localPosition,
          );
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final vbParts = widget.diagram.viewBox.split(RegExp(r'\s+'));
    final vbW = double.parse(vbParts[2]);
    final vbH = double.parse(vbParts[3]);
    final aspectRatio = vbW / vbH;

    return LayoutBuilder(
      builder: (context, constraints) {
        final h = widget.width / aspectRatio;
        final size = Size(widget.width, h);

        // Rebuild hit paths when diagram or size changes
        if (widget.diagram.id != _lastDiagramId || widget.width != _lastWidth) {
          _lastDiagramId = widget.diagram.id;
          _lastWidth = widget.width;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _rebuildHitPaths(size);
            }
          });
        }

        return SizedBox(
          width: widget.width,
          height: h,
          child: GestureDetector(
            onTapDown: _handleTap,
            onPanUpdate: _handlePan,
            child: MouseRegion(
              onHover: _handleMouse,
              onExit: (_) => widget.onHover?.call(null),
              child: CustomPaint(
                painter: _BodyFigurePainter(
                  diagram: widget.diagram,
                  values: widget.values,
                  partValues: widget.partValues,
                  colorModel: widget.colorModel,
                  monochromeColor: widget.monochromeColor,
                  monochromeBaseColor: widget.monochromeBaseColor,
                  visibleGroups: widget.visibleGroups,
                  activeGroup: widget.activeGroup,
                  activeColor: widget.activeColor,
                  glow: widget.glow,
                ),
                size: size,
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleTap(TapDownDetails details) {
    final hit = _hitTest(details.localPosition);
    if (hit != null) widget.onSelect?.call(hit);
  }

  void _handlePan(DragUpdateDetails details) {
    final hit = _hitTest(details.localPosition);
    widget.onHover?.call(hit);
  }

  void _handleMouse(PointerEvent details) {
    final hit = _hitTest(details.localPosition);
    widget.onHover?.call(hit);
  }
}

class _BodyFigurePainter extends CustomPainter {
  final BodyDiagram diagram;
  final Map<MuscleGroup, MuscleMapValue> values;
  final PartValues? partValues;
  final MuscleColorModel colorModel;
  final Color? monochromeColor;
  final Color? monochromeBaseColor;
  final Set<MuscleGroup> visibleGroups;
  final MuscleGroup? activeGroup;
  final Color? activeColor;
  final bool glow;

  _BodyFigurePainter({
    required this.diagram,
    required this.values,
    this.partValues,
    required this.colorModel,
    this.monochromeColor,
    this.monochromeBaseColor,
    required this.visibleGroups,
    this.activeGroup,
    this.activeColor,
    required this.glow,
  });

  Color _colorForScore(double score) {
    if (monochromeColor != null) {
      return getMonochromeColor(
        score,
        monochromeColor!,
        baseColor: monochromeBaseColor ?? const Color(0xFF6b7280),
      );
    }
    return getMuscleHeatColor(score, colorModel: colorModel);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final vbParts = diagram.viewBox.split(RegExp(r'\s+'));
    final vbX = double.parse(vbParts[0]);
    final vbY = double.parse(vbParts[1]);
    final vbW = double.parse(vbParts[2]);
    final vbH = double.parse(vbParts[3]);

    final scaleX = size.width / vbW;
    final scaleY = size.height / vbH;
    final s = min(scaleX, scaleY);

    final offsetX = (size.width - vbW * s) / 2 - vbX * s;
    final offsetY = (size.height - vbH * s) / 2 - vbY * s;

    final matrix = Matrix4.identity();
    matrix.setEntry(0, 3, offsetX);
    matrix.setEntry(1, 3, offsetY);
    // ignore: deprecated_member_use
    matrix.scale(s);

    final mirrorMatrix = Matrix4.identity();
    mirrorMatrix.setEntry(0, 3, offsetX + 2 * diagram.centerX * s);
    mirrorMatrix.setEntry(1, 3, offsetY);
    // ignore: deprecated_member_use
    mirrorMatrix.scale(-s, s);

    // 1. Draw neutral silhouette
    final basePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [_neutralBase, _neutralEdge],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    for (final part in diagram.outline) {
      final path = SvgPathParser.parse(part.d);
      canvas.save();
      canvas.transform(matrix.storage);
      canvas.drawPath(path, basePaint);
      canvas.restore();
    }

    // 2. Build muscle render list
    final muscles = <_RenderMuscle>[];
    for (final muscle in diagram.muscles) {
      if (muscle.side == BodySide.CENTER) {
        muscles.add(_RenderMuscle(
          group: muscle.group,
          partId: muscle.id,
          pathData: muscle.d,
          mirrored: false,
        ));
      } else {
        final rightId = muscle.id?.replaceAll('_LEFT', '_RIGHT');
        muscles.add(_RenderMuscle(
          group: muscle.group,
          partId: muscle.id,
          pathData: muscle.d,
          mirrored: false,
        ));
        muscles.add(_RenderMuscle(
          group: muscle.group,
          partId: rightId,
          pathData: muscle.d,
          mirrored: true,
        ));
      }
    }

    // 3. Resolve colors
    final resolved = muscles.map((m) {
      final visible = visibleGroups.isEmpty || visibleGroups.contains(m.group);
      final value = (m.partId != null && partValues != null)
          ? partValues![m.partId!]
          : null;
      final groupValue = values[m.group]?.value ?? value ?? 0.0;
      final color = visible && groupValue > 0 ? _colorForScore(groupValue) : null;
      return _ResolvedMuscle(
        group: m.group,
        pathData: m.pathData,
        mirrored: m.mirrored,
        visible: visible,
        color: color,
        value: groupValue,
      );
    }).toList();

    // 4. Draw glow halo
    if (glow) {
      final glowPaint = Paint()
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
        ..blendMode = BlendMode.screen;

      for (final m in resolved) {
        if (m.color == null) continue;
        final path = SvgPathParser.parse(m.pathData);
        final tm = m.mirrored ? mirrorMatrix : matrix;
        canvas.save();
        canvas.transform(tm.storage);
        glowPaint.color = m.color!.withValues(alpha: 0.3 + min(m.value, 100) / 100 * 0.6);
        canvas.drawPath(path, glowPaint);
        canvas.restore();
      }
    }

    // 5. Draw muscles
    for (final m in resolved) {
      final path = SvgPathParser.parse(m.pathData);
      final isActive = activeGroup == m.group;

      final paint = Paint()..style = PaintingStyle.fill;

      if (m.color != null) {
        paint.shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _shadeColor(m.color!, 0.22),
            m.color!,
            _shadeColor(m.color!, -0.28),
          ],
          stops: const [0.0, 0.55, 1.1],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      } else {
        paint.color = _muscleDim;
      }

      canvas.save();
      canvas.transform(m.mirrored ? mirrorMatrix.storage : matrix.storage);
      canvas.drawPath(path, paint);

      final strokePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = isActive ? 1.6 : 0.8
        ..color = isActive
            ? (activeColor ?? const Color(0xFFF1F5F9))
            : _stroke;
      canvas.drawPath(path, strokePaint);
      canvas.restore();
    }
  }

  Color _shadeColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  @override
  bool shouldRepaint(_BodyFigurePainter oldDelegate) =>
      oldDelegate.diagram != diagram ||
      oldDelegate.values != values ||
      oldDelegate.partValues != partValues ||
      oldDelegate.colorModel != colorModel ||
      oldDelegate.monochromeColor != monochromeColor ||
      oldDelegate.activeGroup != activeGroup ||
      oldDelegate.activeColor != activeColor ||
      oldDelegate.glow != glow;
}

class _RenderMuscle {
  final MuscleGroup group;
  final String? partId;
  final String pathData;
  final bool mirrored;

  const _RenderMuscle({
    required this.group,
    this.partId,
    required this.pathData,
    required this.mirrored,
  });
}

class _ResolvedMuscle {
  final MuscleGroup group;
  final String pathData;
  final bool mirrored;
  final bool visible;
  final Color? color;
  final double value;

  const _ResolvedMuscle({
    required this.group,
    required this.pathData,
    required this.mirrored,
    required this.visible,
    this.color,
    required this.value,
  });
}
