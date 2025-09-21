import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout.dart';
import '../models/progress_record.dart';
import '../models/meal.dart';

class FirestoreService {
  final FirebaseFirestore _db;
  final String uid;
  FirestoreService(this._db, this.uid);

  CollectionReference<Map<String, dynamic>> _col(String name) =>
      _db.collection(name);

  // Workouts
  Stream<List<Workout>> streamWorkouts() {
    return _col('workouts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Workout.fromMap(d.id, _convert(d.data())))
            .toList());
  }

  Future<void> addWorkout(Workout w) {
    return _col('workouts').add(w.toMap());
  }

  Future<void> updateWorkout(Workout w) {
    return _col('workouts').doc(w.id).update(w.toMap());
  }

  Future<void> deleteWorkout(String id) {
    return _col('workouts').doc(id).delete();
  }

  // Progress
  Stream<List<ProgressRecord>> streamProgress() {
    return _col('progress').orderBy('date').snapshots().map((snap) => snap.docs
        .map((d) => ProgressRecord.fromMap(d.id, _convert(d.data())))
        .toList());
  }

  Future<void> addProgress(ProgressRecord p) {
    return _col('progress').add(p.toMap());
  }

  Future<void> updateProgress(ProgressRecord p) {
    return _col('progress').doc(p.id).update(p.toMap());
  }

  Future<void> deleteProgress(String id) {
    return _col('progress').doc(id).delete();
  }

  // Nutrition
  Stream<List<Meal>> streamMeals() {
    return _col('nutrition').orderBy('date', descending: true).snapshots().map(
        (snap) => snap.docs
            .map((d) => Meal.fromMap(d.id, _convert(d.data())))
            .toList());
  }

  Future<void> addMeal(Meal m) {
    return _col('nutrition').add(m.toMap());
  }

  Future<void> updateMeal(Meal m) {
    return _col('nutrition').doc(m.id).update(m.toMap());
  }

  Future<void> deleteMeal(String id) {
    return _col('nutrition').doc(id).delete();
  }

  // Firestore Timestamp -> DateTime
  Map<String, dynamic> _convert(Map<String, dynamic> data) {
    final out = <String, dynamic>{};
    data.forEach((key, value) {
      if (value is Timestamp) {
        out[key] = value.toDate();
      } else {
        out[key] = value;
      }
    });
    return out;
  }
}
