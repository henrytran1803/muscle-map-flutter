import 'package:flutter/material.dart';
import '../core/types.dart';
import '../core/muscle_meta.dart';

/// A tree-style selector for muscle groups, organized by body region.
///
/// Bilateral muscles (LEFT/RIGHT) are grouped under one name.
/// Tapping highlights both sides on the body figure.
class MuscleGroupTree extends StatefulWidget {
  final MuscleGroup? selectedGroup;
  final MuscleMapView view;
  final ValueChanged<MuscleGroup> onSelectGroup;
  final Color accentColor;
  final Map<MuscleGroup, MuscleMapValue>? values;

  const MuscleGroupTree({
    super.key,
    this.selectedGroup,
    required this.view,
    required this.onSelectGroup,
    this.accentColor = const Color(0xFFEF4444),
    this.values,
  });

  @override
  State<MuscleGroupTree> createState() => _MuscleGroupTreeState();
}

class _MuscleGroupTreeState extends State<MuscleGroupTree> {
  final Set<String> _expandedRegions = {'shoulder', 'chest', 'arm', 'core', 'leg', 'glute'};

  @override
  Widget build(BuildContext context) {
    final regions = _buildRegionNodes();
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: regions.map(_buildRegionTile).toList(),
    );
  }

  List<_RegionNode> _buildRegionNodes() {
    // Group muscles by region, then by base name (strip _LEFT/_RIGHT)
    final Map<String, Map<String, List<MuscleGroupMeta>>> regionMuscles = {};
    for (final meta in muscleGroupMeta) {
      if (!meta.visibleByDefault) continue;
      if (meta.regions.contains('glute') && widget.view == MuscleMapView.FRONT) continue;

      final baseName = meta.name;
      for (final region in meta.regions) {
        regionMuscles.putIfAbsent(region, () => {});
        regionMuscles[region]!.putIfAbsent(baseName, () => []).add(meta);
      }
    }

    final regionOrder = ['shoulder', 'chest', 'arm', 'core', 'leg', 'glute'];
    final nodes = <_RegionNode>[];
    for (final region in regionOrder) {
      final byName = regionMuscles[region];
      if (byName == null || byName.isEmpty) continue;
      final items = byName.entries.map((e) => _MuscleItem(
        name: e.key,
        groups: e.value,
      )).toList();
      nodes.add(_RegionNode(region: region, items: items));
    }
    return nodes;
  }

  Widget _buildRegionTile(_RegionNode node) {
    final isExpanded = _expandedRegions.contains(node.region);
    final regionName = node.region[0].toUpperCase() + node.region.substring(1);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              if (isExpanded) {
                _expandedRegions.remove(node.region);
              } else {
                _expandedRegions.add(node.region);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_down_rounded
                      : Icons.chevron_right_rounded,
                  size: 18,
                  color: const Color(0xFF6B7280),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    regionName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${node.items.length}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isExpanded) ...node.items.map(_buildMuscleItem),
      ],
    );
  }

  Widget _buildMuscleItem(_MuscleItem item) {
    final isSelected = item.groups.any((g) => g.group == widget.selectedGroup);
    final score = widget.values?[item.groups.first.group]?.value;

    return GestureDetector(
      onTap: () => widget.onSelectGroup(item.groups.first.group),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(left: 16, right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? widget.accentColor.withAlpha(15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: isSelected
              ? Border.all(color: widget.accentColor.withAlpha(50), width: 1)
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: isSelected ? widget.accentColor : const Color(0xFFD1D5DB),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? widget.accentColor
                      : const Color(0xFF374151),
                ),
              ),
            ),
            if (score != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? widget.accentColor.withAlpha(20)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${score.round()}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? widget.accentColor
                        : const Color(0xFF6B7280),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RegionNode {
  final String region;
  final List<_MuscleItem> items;

  const _RegionNode({required this.region, required this.items});
}

class _MuscleItem {
  final String name;
  final List<MuscleGroupMeta> groups;

  const _MuscleItem({required this.name, required this.groups});
}
