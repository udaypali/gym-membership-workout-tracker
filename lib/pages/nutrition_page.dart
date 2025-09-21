import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../services/firestore_service.dart';
import '../widgets/dracula_card.dart';

class NutritionPage extends StatefulWidget {
  final String uid;
  const NutritionPage({super.key, required this.uid});

  @override
  State<NutritionPage> createState() => _NutritionPageState();
}

class _NutritionPageState extends State<NutritionPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _calCtrl = TextEditingController();
  late final FirestoreService service;

  @override
  void initState() {
    super.initState();
    service = FirestoreService(FirebaseFirestore.instance, widget.uid);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _calCtrl.dispose();
    super.dispose();
  }

  Future<void> _addMeal() async {
    if (!_formKey.currentState!.validate()) return;
    final meal = Meal(
      id: '_',
      name: _nameCtrl.text.trim(),
      calories: int.parse(_calCtrl.text),
      date: DateTime.now(),
    );
    await service.addMeal(meal);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Meal added')));
      _nameCtrl.clear();
      _calCtrl.clear();
    }
  }

  void _editMeal(Meal m) {
    final name = TextEditingController(text: m.name);
    final cal = TextEditingController(text: m.calories.toString());
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Meal"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: cal, decoration: const InputDecoration(labelText: "Calories (kcal)"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: ()=> Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final updated = Meal(
                id: m.id,
                name: name.text.trim().isEmpty ? m.name : name.text.trim(),
                calories: int.tryParse(cal.text) ?? m.calories,
                date: m.date,
              );
              await service.updateMeal(updated);
              if (mounted) Navigator.pop(context);
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Meal updated')));
            },
            child: const Text("Save"),
          ),
          IconButton(
            onPressed: () async {
              await service.deleteMeal(m.id);
              if (mounted) Navigator.pop(context);
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Meal deleted')));
            },
            icon: const Icon(Icons.delete, color: Colors.redAccent),
          ),
        ],
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
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: "Meal name"),
                  validator: (v) => (v == null || v.trim().isEmpty) ? "Required" : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _calCtrl,
                  decoration: const InputDecoration(labelText: "Calories (kcal)"),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      (int.tryParse(v ?? '') ?? -1) < 0 ? "Invalid" : null,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _addMeal,
                    icon: const Icon(Icons.add),
                    label: const Text("Add Meal"),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text("Meals", style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        StreamBuilder<List<Meal>>(
          stream: service.streamMeals(),
          builder: (context, snap) {
            final items = snap.data ?? [];
            if (items.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("No meals logged yet."),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final m = items[i];
                return DraculaCard(
                  onTap: () => _editMeal(m),
                  child: Row(
                    children: [
                      const Icon(Icons.restaurant, color: Colors.orangeAccent),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "${m.name} • ${m.calories} kcal",
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _editMeal(m),
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
