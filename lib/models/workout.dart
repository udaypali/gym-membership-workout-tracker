class Workout {
  final String id;
  final String type;
  final int sets;
  final int reps;
  final String? notes;
  final DateTime createdAt;

  Workout({
    required this.id,
    required this.type,
    required this.sets,
    required this.reps,
    required this.createdAt,
    this.notes,
  });

  Map<String, dynamic> toMap() => {
        'type': type,
        'sets': sets,
        'reps': reps,
        'notes': notes,
        'createdAt': createdAt.toUtc(),
      };

  static Workout fromMap(String id, Map<String, dynamic> map) => Workout(
        id: id,
        type: map['type'] ?? 'Custom',
        sets: (map['sets'] ?? 0) as int,
        reps: (map['reps'] ?? 0) as int,
        notes: map['notes'],
        createdAt: (map['createdAt'] as DateTime?) ??
            DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
            DateTime.now().toUtc(),
      );
}
