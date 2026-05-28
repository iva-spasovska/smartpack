import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/trip.dart';
import '../providers/trips_provider.dart';
import '../widgets/trip_card.dart';
import 'packing_list_screen.dart';

class TripsListScreen extends StatelessWidget {
  const TripsListScreen({super.key, required this.showPreviousTrips});

  final bool showPreviousTrips;

  static const Color bgColor = Color(0xFFF5EFEB);
  static const Color darkBlue = Color(0xFF2F4858);
  static const Color primaryColor = Color(0xFF4F8D9C);
  static const Color cardColor = Color(0xFFE8F3F7);

  Future<void> _openTrip(BuildContext context, Trip trip) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PackingListScreen(trip: trip, readOnlyExistingTrip: trip.hasEnded),
      ),
    );

    if (!context.mounted) return;
    await context.read<TripsProvider>().loadTrips();
  }

  @override
  Widget build(BuildContext context) {
    final tripsProvider = context.watch<TripsProvider>();
    final trips =
        tripsProvider.trips
            .where(
              (trip) => showPreviousTrips ? trip.hasEnded : trip.isUpcoming,
            )
            .toList()
          ..sort(
            showPreviousTrips
                ? _compareTripsByEndDate
                : _compareTripsByStartDate,
          );
    final title = showPreviousTrips ? 'Previous trips' : 'Upcoming trips';
    final emptyMessage = showPreviousTrips
        ? 'Trips will move here after their return date passes.'
        : 'No upcoming trips yet. Create a trip from the home screen.';

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: primaryColor,
          onRefresh: () => context.read<TripsProvider>().loadTrips(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    IconButton.filled(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                      ),
                      color: darkBlue,
                      style: IconButton.styleFrom(
                        backgroundColor: cardColor,
                        fixedSize: const Size(44, 44),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: darkBlue,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 44),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  '${trips.length} '
                  '${showPreviousTrips ? 'previous' : 'upcoming'} '
                  '${trips.length == 1 ? 'trip' : 'trips'}',
                  style: GoogleFonts.poppins(
                    color: primaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                if (trips.isEmpty)
                  _EmptyTripsListCard(message: emptyMessage)
                else
                  ...trips.map(
                    (trip) => TripCard(
                      trip: trip,
                      onTap: () => _openTrip(context, trip),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _compareTripsByStartDate(Trip a, Trip b) {
    final aDate = a.parsedStartDate;
    final bDate = b.parsedStartDate;
    if (aDate == null && bDate == null) return 0;
    if (aDate == null) return 1;
    if (bDate == null) return -1;
    return aDate.compareTo(bDate);
  }

  int _compareTripsByEndDate(Trip a, Trip b) {
    final aDate = a.parsedEndDate;
    final bDate = b.parsedEndDate;
    if (aDate == null && bDate == null) return 0;
    if (aDate == null) return 1;
    if (bDate == null) return -1;
    return bDate.compareTo(aDate);
  }
}

class _EmptyTripsListCard extends StatelessWidget {
  const _EmptyTripsListCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TripsListScreen.cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        message,
        style: GoogleFonts.poppins(
          color: TripsListScreen.darkBlue,
          fontSize: 13,
          height: 1.45,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
