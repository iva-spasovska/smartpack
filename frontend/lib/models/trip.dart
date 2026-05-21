class Trip {
  final int id;
  final String name;
  final String destination;
  final String startDate;
  final String? endDate;
  final int durationDays;
  final String? luggageType;
  final String? tripType;
  final String? createdAt;

  Trip({
    required this.id,
    required this.name,
    required this.destination,
    required this.startDate,
    this.endDate,
    required this.durationDays,
    this.luggageType,
    this.tripType,
    this.createdAt,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] ?? 0,
      name: json['name'] ?? '${json['destination'] ?? 'Trip'} trip',
      destination: json['destination'] ?? '',
      startDate: json['start_date'] ?? json['departure_date'] ?? '',
      endDate: json['end_date'],
      durationDays: json['duration_days'] ?? json['duration'] ?? 1,
      luggageType: json['luggage_type'] ?? json['luggage'],
      tripType: json['trip_type'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'destination': destination,
      'start_date': startDate,
      'duration_days': durationDays,
      'luggage_type': luggageType,
      'trip_type': tripType,
    };
  }
}