class ProgressRecord {
  final String id;
  final double weight; // kg
  final int calories; // kcal
  final int exercises; // count
  final DateTime date;

  ProgressRecord({
    required this.id,
    required this.weight,
    required this.calories,
    required this.exercises,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'weight': weight,
        'calories': calories,
        'exercises': exercises,
        'date': date.toUtc(),
      };

  static ProgressRecord fromMap(String id, Map<String, dynamic> map) =>
      ProgressRecord(
        id: id,
        weight: (map['weight'] as num?)?.toDouble() ?? 0,
        calories: (map['calories'] as num?)?.toInt() ?? 0,
        exercises: (map['exercises'] as num?)?.toInt() ?? 0,
        date: (map['date'] as DateTime?) ??
            DateTime.tryParse(map['date']?.toString() ?? '') ??
            DateTime.now().toUtc(),
      );
}
