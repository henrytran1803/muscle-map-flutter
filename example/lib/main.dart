import 'package:flutter/material.dart';
import 'package:muscle_map_flutter/muscle_map_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MuscleMap Flutter Demo',
      theme: ThemeData.dark(useMaterial3: true),
      home: const MuscleMapDemo(),
    );
  }
}

class MuscleMapDemo extends StatefulWidget {
  const MuscleMapDemo({super.key});

  @override
  State<MuscleMapDemo> createState() => _MuscleMapDemoState();
}

class _MuscleMapDemoState extends State<MuscleMapDemo> {
  MuscleMapSex _sex = MuscleMapSex.MALE;
  MuscleMapView _view = MuscleMapView.FRONT;
  MuscleColorModel _colorModel = MuscleColorModel.LOAD;

  late Map<MuscleGroup, MuscleMapValue> _values;

  @override
  void initState() {
    super.initState();
    _values = _generateSampleValues();
  }

  Map<MuscleGroup, MuscleMapValue> _generateSampleValues() {
    final values = <MuscleGroup, MuscleMapValue>{};
    for (final group in MuscleGroup.values) {
      final score = (group.index * 17 + 23) % 101;
      values[group] = MuscleMapValue(group: group, value: score.toDouble());
    }
    return values;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MuscleMap Flutter Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Controls
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                SegmentedButton<MuscleMapSex>(
                  segments: const [
                    ButtonSegment(value: MuscleMapSex.MALE, label: Text('Male')),
                    ButtonSegment(value: MuscleMapSex.FEMALE, label: Text('Female')),
                  ],
                  selected: {_sex},
                  onSelectionChanged: (s) => setState(() => _sex = s.first),
                ),
                SegmentedButton<MuscleMapView>(
                  segments: const [
                    ButtonSegment(value: MuscleMapView.FRONT, label: Text('Front')),
                    ButtonSegment(value: MuscleMapView.BACK, label: Text('Back')),
                  ],
                  selected: {_view},
                  onSelectionChanged: (s) => setState(() => _view = s.first),
                ),
                SegmentedButton<MuscleColorModel>(
                  segments: const [
                    ButtonSegment(value: MuscleColorModel.LOAD, label: Text('Load')),
                    ButtonSegment(value: MuscleColorModel.FREQUENCY, label: Text('Freq')),
                    ButtonSegment(value: MuscleColorModel.BALANCE, label: Text('Balance')),
                    ButtonSegment(value: MuscleColorModel.RECOVERY_RISK, label: Text('Risk')),
                  ],
                  selected: {_colorModel},
                  onSelectionChanged: (s) => setState(() => _colorModel = s.first),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Muscle Map
            Expanded(
              child: Center(
                child: MuscleMap(
                  values: _values,
                  sex: _sex,
                  view: _view,
                  colorModel: _colorModel,
                  figureWidth: 250,
                  onSelectMuscle: (selection) {
                    debugPrint('Selected: ${selection.group}, value: ${selection.value?.value}');
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
