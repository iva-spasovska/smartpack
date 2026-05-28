import 'package:flutter/foundation.dart';

import '../models/trip.dart';
import '../services/trip_service.dart';

class TripsProvider extends ChangeNotifier {
  TripsProvider({required TripService tripService})
    : _tripService = tripService;

  final TripService _tripService;

  List<Trip> _trips = [];
  bool _isLoading = false;
  String? _error;

  List<Trip> get trips => List.unmodifiable(_trips);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTrips() async {
    _setLoading(true);
    _error = null;

    try {
      final loadedTrips = await _tripService.getTrips();
      loadedTrips.sort(_compareTripsByCreatedDate);
      _trips = loadedTrips;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load trips';
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void clearSessionData() {
    _trips = [];
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  int _compareTripsByCreatedDate(Trip a, Trip b) {
    final aDate = DateTime.tryParse(a.createdAt ?? a.startDate);
    final bDate = DateTime.tryParse(b.createdAt ?? b.startDate);
    if (aDate == null || bDate == null) return 0;
    return bDate.compareTo(aDate);
  }
}
