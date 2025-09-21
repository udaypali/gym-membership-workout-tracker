import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/progress_record.dart';
import '../services/firestore_service.dart';
import '../widgets/dracula_card.dart';

class ProgressPage extends StatefulWidget {
  final String uid;
  const ProgressPage({super.key, required this.uid});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  final _formKey = GlobalKey<FormState>();
  final _weightCtrl = TextEditingController();
  final _calCtrl = TextEditingController();
  final _exCtrl = TextEditingController(text: '0');
  late final FirestoreService service;

  @override
  void initState() {
    super.initState();
    service = FirestoreService(FirebaseFirestore.instance, widget.uid);
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _calCtrl.dispose();
    _exCtrl.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    if (!_formKey.currentState!.validate()) return;
    final rec = ProgressRecord(
      id: '_',
      weight: double.parse(_weightCtrl.text),
      calories: int.parse(_calCtrl.text),
      exercises: int.parse(_exCtrl.text),
      date: DateTime.now(),
    );
    await service.addProgress(rec);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Progress added')));
      _weightCtrl.clear();
      _calCtrl.clear();
      _exCtrl.text = '0';
    }
  }

  void _editDialog(ProgressRecord p) {
    final w = TextEditingController(text: p.weight.toStringAsFixed(1));
    final c = TextEditingController(text: p.calories.toString());
    final e = TextEditingController(text: p.exercises.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Progress"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: w, decoration: const InputDecoration(labelText: "Weight (kg)"), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
            TextField(controller: c, decoration: const InputDecoration(labelText: "Calories (kcal)"), keyboardType: TextInputType.number),
            TextField(controller: e, decoration: const InputDecoration(labelText: "Exercises (count)"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
            TextButton(onPressed: ()=> Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                final updated = ProgressRecord(
                  id: p.id,
                  weight: double.tryParse(w.text) ?? p.weight,
                  calories: int.tryParse(c.text) ?? p.calories,
                  exercises: int.tryParse(e.text) ?? p.exercises,
                  date: p.date,
                );
                await service.updateProgress(updated);
                if (mounted) Navigator.pop(context);
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Progress updated')));
              },
              child: const Text("Save"),
            ),
            IconButton(
              onPressed: () async {
                await service.deleteProgress(p.id);
                if (mounted) Navigator.pop(context);
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Progress deleted')));
              },
              icon: const Icon(Icons.delete, color: Colors.redAccent),
            ),
        ],
      ),
    );
  }

  Widget _charts(List<ProgressRecord> data) {
    if (data.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text("Add some progress to see charts."),
      );
    }
    // Sort by date
    final sorted = [...data]..sort((a, b) => a.date.compareTo(b.date));
    final spots = <FlSpot>[];
    for (var i = 0; i < sorted.length; i++) {
      spots.add(FlSpot(i.toDouble(), sorted[i].weight));
    }
    final bars = List.generate(sorted.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: sorted[i].calories.toDouble(),
            width: 10,
          )
        ],
      );
    });

    return Column(
      children: [
        const SizedBox(height: 8),
        const Text("Weight (kg)", style: TextStyle(fontWeight: FontWeight.w700)),
        SizedBox(
          height: 180,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  isCurved: true,
                  color: Colors.purpleAccent,
                  barWidth: 3,
                  spots: spots,
                  dotData: const FlDotData(show: false),
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text("Calories (kcal)", style: TextStyle(fontWeight: FontWeight.w700)),
        SizedBox(
          height: 180,
          child: BarChart(
            BarChartData(
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: bars,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DraculaCard(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _weightCtrl,
                        decoration:
                            const InputDecoration(labelText: "Weight (kg)"),
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        validator: (v) =>
                            (double.tryParse(v ?? '') ?? -1) <= 0 ? "Invalid" : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _calCtrl,
                        decoration:
                            const InputDecoration(labelText: "Calories (kcal)"),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            (int.tryParse(v ?? '') ?? -1) < 0 ? "Invalid" : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _exCtrl,
                  decoration:
                      const InputDecoration(labelText: "Exercises (count)"),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      (int.tryParse(v ?? '') ?? -1) < 0 ? "Invalid" : null,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _add,
                    icon: const Icon(Icons.add),
                    label: const Text("Add Progress"),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        StreamBuilder<List<ProgressRecord>>(
          stream: service.streamProgress(),
          builder: (context, snap) {
            final items = snap.data ?? [];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DraculaCard(child: _charts(items)),
                const SizedBox(height: 8),
                const Text("History",
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final p = items[i];
                    return DraculaCard(
                      onTap: () => _editDialog(p),
                      child: Row(
                        children: [
                          const Icon(Icons.show_chart, color: Colors.tealAccent),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "${p.weight.toStringAsFixed(1)} kg • ${p.calories} kcal • ${p.exercises} ex",
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _editDialog(p),
                            icon: const Icon(Icons.edit, color: Colors.white70),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
