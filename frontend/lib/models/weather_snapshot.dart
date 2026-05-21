class WeatherSnapshot {
  final int id;
  final double? temperature;
  final String? condition;
  final String? description;
  final bool isRainy;
  final bool isSunny;
  final bool isSnowy;
  final bool isWindy;

  WeatherSnapshot({
    required this.id,
    this.temperature,
    this.condition,
    this.description,
    required this.isRainy,
    required this.isSunny,
    required this.isSnowy,
    required this.isWindy,
  });

  factory WeatherSnapshot.fromJson(Map<String, dynamic> json) {
    return WeatherSnapshot(
      id: json['id'] ?? 0,
      temperature: _toDouble(
        json['temperature'] ?? json['temp'] ?? json['temperature_celsius'],
      ),
      condition: json['condition'] ?? json['main'],
      description: json['description'] ?? json['weather_description'],
      isRainy: json['is_rainy'] ?? false,
      isSunny: json['is_sunny'] ?? false,
      isSnowy: json['is_snowy'] ?? false,
      isWindy: json['is_windy'] ?? false,
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return double.tryParse(value.toString());
  }
}