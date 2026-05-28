class WeatherSnapshot {
  final int id;
  final double? temperature;
  final int? humidity;
  final double? windSpeed;
  final String? condition;
  final String? description;
  final String? apiSource;
  final DateTime? fetchedAt;
  final bool isRainy;
  final bool isSunny;
  final bool isSnowy;
  final bool isWindy;

  WeatherSnapshot({
    required this.id,
    this.temperature,
    this.humidity,
    this.windSpeed,
    this.condition,
    this.description,
    this.apiSource,
    this.fetchedAt,
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
      humidity: _toInt(json['humidity']),
      windSpeed: _toDouble(json['wind_speed'] ?? json['windSpeed']),
      condition: json['condition'] ?? json['main'],
      description: json['description'] ?? json['weather_description'],
      apiSource: json['api_source'],
      fetchedAt: _toDateTime(json['fetched_at']),
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

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value.toString());
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
