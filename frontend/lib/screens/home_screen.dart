import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/trip.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/trips_provider.dart';
import '../widgets/app_logo.dart';
import '../widgets/trip_card.dart';
import 'create_trip_screen.dart';
import 'packing_list_screen.dart';
import 'profile_screen.dart';
import 'trips_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color bgColor = Color(0xFFF5EFEB);
  static const Color primaryColor = Color(0xFF4F8D9C);
  static const Color darkBlue = Color(0xFF2F4858);
  static const Color lightBlue = Color(0xFFE8F3F7);
  static const Color softMint = Color(0xFFC7DDE8);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => loadHomeData());
  }

  Future<void> loadHomeData() async {
    try {
      await Future.wait([
        context.read<ProfileProvider>().loadProfile(),
        context.read<TripsProvider>().loadTrips(),
      ]);
    } catch (e) {
      if (!mounted || !(ModalRoute.of(context)?.isCurrent ?? false)) return;

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load home data')),
      );
    }
  }

  Future<void> _openCreateTrip() async {
    final created = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateTripScreen()),
    );

    if (created == true) {
      loadHomeData();
    }
  }

  Future<void> _openProfile() async {
    final authProvider = context.read<AuthProvider>();

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );

    if (!mounted || !(await authProvider.isLoggedIn())) return;
    loadHomeData();
  }

  Future<void> _openTrip(Trip trip) async {
    final authProvider = context.read<AuthProvider>();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PackingListScreen(trip: trip, readOnlyExistingTrip: trip.hasEnded),
      ),
    );
    if (!mounted || !(await authProvider.isLoggedIn())) return;
    loadHomeData();
  }

  Future<void> _openPreviousTrips() async {
    final authProvider = context.read<AuthProvider>();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const TripsListScreen(showPreviousTrips: true),
      ),
    );
    if (!mounted || !(await authProvider.isLoggedIn())) return;
    loadHomeData();
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final tripsProvider = context.watch<TripsProvider>();
    final user = profileProvider.user;
    final upcomingTrips =
        tripsProvider.trips.where((trip) => trip.isUpcoming).toList()
          ..sort(_compareTripsByStartDate);
    final previousTripsCount = tripsProvider.trips
        .where((trip) => trip.hasEnded)
        .length;
    final isLoading = profileProvider.isLoading || tripsProvider.isLoading;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: isLoading && user == null
            ? const Center(
                child: CircularProgressIndicator(color: primaryColor),
              )
            : RefreshIndicator(
                color: primaryColor,
                onRefresh: loadHomeData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _HomeTopBar(onProfileTap: _openProfile),
                      const SizedBox(height: 24),
                      _WelcomeHeader(username: user?.username ?? 'traveler'),
                      const SizedBox(height: 22),
                      _PackingHeroCard(
                        tripsCount: upcomingTrips.length,
                        onStartPacking: _openCreateTrip,
                      ),
                      const SizedBox(height: 18),
                      _ProgressLine(tripsCount: upcomingTrips.length),
                      const SizedBox(height: 18),
                      _QuickActions(onCreateTrip: _openCreateTrip),
                      const SizedBox(height: 24),
                      _TripsSection(
                        trips: upcomingTrips,
                        previousTripsCount: previousTripsCount,
                        onTripTap: _openTrip,
                        onCreateTrip: _openCreateTrip,
                        onPreviousTrips: _openPreviousTrips,
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
}

class _HomeTopBar extends StatelessWidget {
  const _HomeTopBar({required this.onProfileTap});

  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const AppLogo(compact: true, showTagline: false),
        const Spacer(),
        IconButton.filled(
          onPressed: onProfileTap,
          icon: const Icon(Icons.person_outline_rounded),
          color: _HomeScreenState.darkBlue,
          style: IconButton.styleFrom(
            backgroundColor: _HomeScreenState.lightBlue,
            fixedSize: const Size(46, 46),
          ),
        ),
      ],
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({required this.username});

  final String username;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back,',
          style: GoogleFonts.poppins(
            color: _HomeScreenState.primaryColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          username,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            color: _HomeScreenState.darkBlue,
            fontSize: 30,
            height: 1.1,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PackingHeroCard extends StatelessWidget {
  const _PackingHeroCard({
    required this.tripsCount,
    required this.onStartPacking,
  });

  final int tripsCount;
  final VoidCallback onStartPacking;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 18, 18),
      decoration: BoxDecoration(
        color: _HomeScreenState.primaryColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: _HomeScreenState.darkBlue.withValues(alpha: 0.14),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tripsCount == 0
                      ? 'Ready for your first trip?'
                      : 'Plan the next suitcase',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 21,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Build a smart list by destination, weather, trip type, and luggage.',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.86),
                    fontSize: 12,
                    height: 1.45,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: onStartPacking,
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: Text(
                    'New trip',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _HomeScreenState.darkBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 126,
            height: 150,
            child: Image.asset(
              'assets/packing_home_white.png',
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine({required this.tripsCount});

  final int tripsCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricTile(
            icon: Icons.route_outlined,
            value: '$tripsCount',
            label: 'Upcoming',
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: _MetricTile(
            icon: Icons.checklist_rounded,
            value: 'Smart',
            label: 'Lists',
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: _MetricTile(
            icon: Icons.cloud_outlined,
            value: 'Live',
            label: 'Weather',
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 94,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _HomeScreenState.softMint),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: _HomeScreenState.primaryColor, size: 22),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: _HomeScreenState.darkBlue,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: _HomeScreenState.darkBlue.withValues(alpha: 0.62),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.onCreateTrip});

  final VoidCallback onCreateTrip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _HomeScreenState.lightBlue,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _ActionLine(
            icon: Icons.add_location_alt_outlined,
            title: 'Create a trip',
            subtitle: 'Tell PackPal where you are going next',
            onTap: onCreateTrip,
          ),
          const Divider(height: 22, color: _HomeScreenState.softMint),
          const _ActionLine(
            icon: Icons.auto_awesome_outlined,
            title: 'Personal recommendations',
            subtitle: 'Weather, days, trip style, and luggage in one list',
          ),
        ],
      ),
    );
  }
}

class _ActionLine extends StatelessWidget {
  const _ActionLine({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: _HomeScreenState.primaryColor, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: _HomeScreenState.darkBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: _HomeScreenState.darkBlue.withValues(alpha: 0.64),
                  fontSize: 11,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (onTap != null)
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: _HomeScreenState.darkBlue,
            size: 16,
          ),
      ],
    );

    if (onTap == null) return content;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: content,
      ),
    );
  }
}

class _TripsSection extends StatelessWidget {
  const _TripsSection({
    required this.trips,
    required this.previousTripsCount,
    required this.onTripTap,
    required this.onCreateTrip,
    required this.onPreviousTrips,
  });

  final List<Trip> trips;
  final int previousTripsCount;
  final ValueChanged<Trip> onTripTap;
  final VoidCallback onCreateTrip;
  final VoidCallback onPreviousTrips;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Upcoming trips',
              style: GoogleFonts.poppins(
                color: _HomeScreenState.darkBlue,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: previousTripsCount == 0 ? null : onPreviousTrips,
              child: Text(
                'Previous',
                style: GoogleFonts.poppins(
                  color: previousTripsCount == 0
                      ? _HomeScreenState.darkBlue.withValues(alpha: 0.36)
                      : _HomeScreenState.primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (trips.isEmpty)
          _EmptyTripsCard(onCreateTrip: onCreateTrip)
        else
          ...trips.map(
            (trip) => TripCard(trip: trip, onTap: () => onTripTap(trip)),
          ),
      ],
    );
  }
}

class _EmptyTripsCard extends StatelessWidget {
  const _EmptyTripsCard({required this.onCreateTrip});

  final VoidCallback onCreateTrip;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _HomeScreenState.softMint),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.luggage_outlined,
            color: _HomeScreenState.primaryColor,
            size: 32,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'No trips yet. Start with one destination and PackPal will shape the list.',
              style: GoogleFonts.poppins(
                color: _HomeScreenState.darkBlue,
                fontSize: 12,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            onPressed: onCreateTrip,
            icon: const Icon(Icons.add_rounded),
            color: Colors.white,
            style: IconButton.styleFrom(
              backgroundColor: _HomeScreenState.darkBlue,
            ),
          ),
        ],
      ),
    );
  }
}
