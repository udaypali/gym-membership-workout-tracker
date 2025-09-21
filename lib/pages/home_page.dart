import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/dracula_card.dart';
import '../widgets/gradient_button.dart';

class HomePage extends StatelessWidget {
  final String uid;
  final void Function(int index)? onJumpTo; // allow switching tabs
  const HomePage({super.key, required this.uid, this.onJumpTo});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;

    final workoutsCount =
        db.collection('workouts').snapshots().map((s) => s.docs.length);

    final mealsToday = db
        .collection('nutrition')
        .where('date',
            isGreaterThanOrEqualTo: DateTime(
                DateTime.now().year, DateTime.now().month, DateTime.now().day))
        .snapshots()
        .map((s) => s.docs.length);

    final progressCount =
        db.collection('progress').snapshots().map((s) => s.docs.length);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const DraculaCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome back!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 6),
              Text(
                "Gym Membership & Workout Plan Tracker",
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const DraculaCard(
          child: Row(
            children: [
              Icon(Icons.card_membership, color: AppTheme.accent),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Membership: Active • Plan: Premium\nRenew: Next Month",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: DraculaCard(
                child: StreamBuilder<int>(
                  stream: workoutsCount,
                  builder: (context, snapshot) {
                    final count = snapshot.data ?? 0;
                    return _statTile("Workouts", count, Icons.fitness_center);
                  },
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DraculaCard(
                child: StreamBuilder<int>(
                  stream: progressCount,
                  builder: (context, snapshot) {
                    final count = snapshot.data ?? 0;
                    return _statTile("Progress", count, Icons.show_chart,
                        suffix: "%");
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        DraculaCard(
          child: StreamBuilder<int>(
            stream: mealsToday,
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              return Row(
                children: [
                  const Icon(Icons.restaurant, color: Colors.orangeAccent),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Meals Today",
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        SizedBox(height: 2),
                        Text("Nutrition tracking",
                            style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                  Text("$count",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      )),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "Quick Navigation",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        GradientButton(
          label: "Workout",
          icon: Icons.fitness_center,
          onPressed: () => onJumpTo?.call(1),
        ),
        const SizedBox(height: 10),
        GradientButton(
          label: "Progress",
          icon: Icons.trending_up,
          onPressed: () => onJumpTo?.call(2),
        ),
      ],
    );
  }

  Widget _statTile(String label, int value, IconData icon, {String? suffix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.accent),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 4),
        Text(
          suffix == null ? value.toString() : "$value$suffix",
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}
