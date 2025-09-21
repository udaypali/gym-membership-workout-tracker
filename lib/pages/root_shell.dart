import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';
import '../widgets/dracula_scaffold.dart';
import 'home_page.dart';
import 'workout_page.dart';
import 'progress_page.dart';
import 'nutrition_page.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  static _RootShellState? of(BuildContext context) =>
      context.findAncestorStateOfType<_RootShellState>();

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  void setTab(int i) => setState(() => _index = i);

  final _pages = const [
    HomePage(),
    WorkoutPage(),
    ProgressPage(),
    NutritionPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return DraculaScaffold(
      appBar: AppBar(
        title: const Text('Gym Tracker'),
      ),
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: setTab,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center), label: 'Workout'),
          BottomNavigationBarItem(
              icon: Icon(Icons.show_chart), label: 'Progress'),
          BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu), label: 'Nutrition'),
        ],
      ),
    );
  }
}
