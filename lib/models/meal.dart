class Meal {
  final String id;
  final String name;
  final int calories;
  final DateTime date;

  Meal({
    required this.id,
    required this.name,
    required this.calories,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'calories': calories,
        'date': date.toUtc(),
      };

  static Meal fromMap(String id, Map<String, dynamic> map) => Meal(
        id: id,
        name: map['name'] ?? 'Meal',
        calories: (map['calories'] as num?)?.toInt() ?? 0,
        date: (map['date'] as DateTime?) ??
            DateTime.tryParse(map['date']?.toString() ?? '') ??
            DateTime.now().toUtc(),
      );
}
