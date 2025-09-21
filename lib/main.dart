// Entry + Firebase init + BottomNavigation
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'widgets/gradient_background.dart';
import 'pages/home_page.dart';
import 'pages/workout_page.dart';
import 'pages/progress_page.dart';
import 'pages/nutrition_page.dart';

// Replace with your generated options from FlutterFire
// import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Try initialize with generated options if available
    // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "your_api_key",
        appId: "your_app_id",
        messagingSenderId: "your_sender_id",
        projectId: "your_proj_id",
        authDomain: "your_auth_domain",
        storageBucket: "your_bucket",
      ),
    );
  } catch (e) {
    // Fallback (web requires options normally)
    if (kIsWeb) {
      debugPrint("Firebase init error on web: $e");
      rethrow;
    }
  }

  // Anonymous auth to get a uid for subcollections
  if (FirebaseAuth.instance.currentUser == null) {
    await FirebaseAuth.instance.signInAnonymously();
  }

  // Small safety to ensure Firestore is usable
  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: true);

  runApp(const GymApp());
}

class GymApp extends StatefulWidget {
  const GymApp({super.key});

  @override
  State<GymApp> createState() => _GymAppState();
}

class _GymAppState extends State<GymApp> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? 'unknown';

    final pages = [
      HomePage(uid: uid),
      WorkoutPage(uid: uid),
      ProgressPage(uid: uid),
      NutritionPage(uid: uid),
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: GradientBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(title: const Text("Gym Tracker")),
          body: pages[_index],
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: AppTheme.surface.withOpacity(0.6),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              child: BottomNavigationBar(
                currentIndex: _index,
                onTap: (i) => setState(() => _index = i),
                items: const [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.home), label: "Home"),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.fitness_center), label: "Workout"),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.trending_up), label: "Progress"),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.restaurant), label: "Nutrition"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
