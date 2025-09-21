import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../services/firestore_service.dart';
import '../widgets/dracula_card.dart';
import '../theme/app_theme.dart';

class WorkoutPage extends StatefulWidget {
  final String uid;
  const WorkoutPage({super.key, required this.uid});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _types = const [
    'Chest',
    'Back',
    'Legs',
    'Arms',
    'Shoulders',
    'Core',
    'Cardio',
    'Custom'
  ];

  String _type = 'Chest';
  final _setsCtrl = TextEditingController(text: '3');
  final _repsCtrl = TextEditingController(text: '10');
  final _notesCtrl = TextEditingController();

  late final FirestoreService service;

  @override
  void initState() {
    super.initState();
    service = FirestoreService(FirebaseFirestore.instance, widget.uid);
  }

  @override
  void dispose() {
    _setsCtrl.dispose();
    _repsCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _addWorkout() async {
    if (!_formKey.currentState!.validate()) return;
    final w = Workout(
      id: '_',
      type: _type,
      sets: int.parse(_setsCtrl.text),
      reps: int.parse(_repsCtrl.text),
      notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
      createdAt: DateTime.now(),
    );
    await service.addWorkout(w);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workout added')),
      );
      _notesCtrl.clear();
    }
  }

  void _editWorkoutDialog(Workout w) {
    final sets = TextEditingController(text: w.sets.toString());
    final reps = TextEditingController(text: w.reps.toString());
    final notes = TextEditingController(text: w.notes ?? '');
    String type = w.type;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Edit Workout",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: type,
              items: _types
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => type = v ?? type,
              decoration: const InputDecoration(labelText: "Type"),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: sets,
              decoration: const InputDecoration(labelText: "Sets"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: reps,
              decoration: const InputDecoration(labelText: "Reps"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: notes,
              decoration: const InputDecoration(labelText: "Notes (optional)"),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final updated = Workout(
                        id: w.id,
                        type: type,
                        sets: int.tryParse(sets.text) ?? w.sets,
                        reps: int.tryParse(reps.text) ?? w.reps,
                        notes: notes.text.isEmpty ? null : notes.text,
                        createdAt: w.createdAt,
                      );
                      await service.updateWorkout(updated);
                      if (mounted) Navigator.pop(context);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Workout updated')),
                        );
                      }
                    },
                    icon: const Icon(Icons.save),
                    label: const Text("Save"),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () async {
                    await service.deleteWorkout(w.id);
                    if (mounted) Navigator.pop(context);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Workout deleted')),
                      );
                    }
                  },
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                )
              ],
            )
          ],
        ),
      ),
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
                DropdownButtonFormField<String>(
                  value: _type,
                  items: _types
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setState(() => _type = v ?? _type),
                  decoration: const InputDecoration(labelText: "Workout Type"),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _setsCtrl,
                        decoration: const InputDecoration(labelText: "Sets"),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            (int.tryParse(v ?? '') ?? -1) <= 0 ? "Invalid" : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _repsCtrl,
                        decoration: const InputDecoration(labelText: "Reps"),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            (int.tryParse(v ?? '') ?? -1) <= 0 ? "Invalid" : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _notesCtrl,
                  decoration:
                      const InputDecoration(labelText: "Notes (optional)"),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _addWorkout,
                    icon: const Icon(Icons.add),
                    label: const Text("Add Workout"),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text("Your Workouts",
            style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        StreamBuilder<List<Workout>>(
          stream: service.streamWorkouts(),
          builder: (context, snap) {
            final items = snap.data ?? [];
            if (items.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("No workouts yet. Add your first!"),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final w = items[i];
                return DraculaCard(
                  onTap: () => _editWorkoutDialog(w),
                  child: Row(
                    children: [
                      const Icon(Icons.fitness_center, color: AppTheme.accent),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${w.type} • ${w.sets} x ${w.reps}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                            if (w.notes != null)
                              Text(
                                w.notes!,
                                style: const TextStyle(color: Colors.white70),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _editWorkoutDialog(w),
                        icon: const Icon(Icons.edit, color: Colors.white70),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
