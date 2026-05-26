import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/app_user.dart';
import '../models/trip.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/trip_service.dart';
import 'login_screen.dart';
import 'packing_list_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color bgColor = Color(0xFFF5EFEB);
  static const Color darkBlue = Color(0xFF2F4858);
  static const Color primaryColor = Color(0xFF4F8D9C);
  static const Color cardColor = Color(0xFFE8F3F7);

  AppUser? user;
  List<Trip> trips = [];
  Trip? selectedTrip;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    try {
      final loadedUser = await UserService().getProfile();
      final loadedTrips = await TripService().getTrips();

      loadedTrips.sort((a, b) {
        final aDate = DateTime.tryParse(a.createdAt ?? a.startDate);
        final bDate = DateTime.tryParse(b.createdAt ?? b.startDate);
        if (aDate == null || bDate == null) return 0;
        return bDate.compareTo(aDate);
      });

      setState(() {
        user = loadedUser;
        trips = loadedTrips;
        selectedTrip = loadedTrips.isNotEmpty ? loadedTrips.first : null;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load profile')),
      );
    }
  }

  Future<void> logout() async {
    await AuthService().logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  String _valueOrDash(String? value) {
    if (value == null || value.isEmpty) return '-';
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _topBar(),

                    const SizedBox(height: 20),

                    _profileHeader(),

                    const SizedBox(height: 28),

                    _infoCard(),

                    const SizedBox(height: 28),

                    _lastTripsSection(),

                    const SizedBox(height: 30),

                    Center(
                      child: TextButton.icon(
                        onPressed: logout,
                        icon: const Icon(Icons.logout_rounded),
                        label: Text(
                          'Logout',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _topBar() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: darkBlue,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        const Spacer(),
        Text(
          'Profile',
          style: GoogleFonts.poppins(
            color: darkBlue,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _profileHeader() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: cardColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 56,
              color: primaryColor,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            user?.username ?? 'Traveler',
            style: GoogleFonts.poppins(
              color: darkBlue,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            user?.email ?? '',
            style: GoogleFonts.poppins(
              color: darkBlue.withOpacity(0.65),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: darkBlue.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          _infoRow('Username', user?.username),
          _divider(),
          _infoRow('Email', user?.email),
          _divider(),
          _infoRow('Gender', user?.gender),
          _divider(),
          _infoRow(
            'Date of birth',
            user?.dateOfBirth,
          ),
          _divider(),
          _infoRow(
            'Age',
            user?.age?.toString(),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: darkBlue.withOpacity(0.65),
              fontSize: 13,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              _valueOrDash(value),
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                color: darkBlue,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(
      color: darkBlue.withOpacity(0.12),
      height: 1,
    );
  }

  Widget _lastTripsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your last trips',
          style: GoogleFonts.poppins(
            color: darkBlue,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 14),

        if (trips.isEmpty)
          Text(
            'No trips yet.',
            style: GoogleFonts.poppins(
              color: darkBlue,
              fontSize: 14,
            ),
          )
        else ...[
          _tripDropdown(),

          const SizedBox(height: 16),

          if (selectedTrip != null) _selectedTripCard(selectedTrip!),
        ],
      ],
    );
  }

  Widget _tripDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: darkBlue.withOpacity(0.12)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Trip>(
          value: selectedTrip,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items: trips
              .map(
                (trip) => DropdownMenuItem<Trip>(
                  value: trip,
                  child: Text(
                    trip.name,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: darkBlue,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (trip) {
            setState(() => selectedTrip = trip);
          },
        ),
      ),
    );
  }

  Widget _selectedTripCard(Trip trip) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PackingListScreen(
              trip: trip,
              readOnlyExistingTrip: true,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: darkBlue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.location_on_outlined,
              color: primaryColor,
              size: 30,
            ),

            const SizedBox(height: 10),

            Text(
              trip.name,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            _tripDetail('Destination', trip.destination),
            _tripDetail('Start date', trip.startDate),
            _tripDetail('Duration', '${trip.durationDays} days'),
            _tripDetail('Luggage', trip.luggageType),
            _tripDetail('Trip type', trip.tripType),

            const SizedBox(height: 12),

            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'View packing list →',
                style: GoogleFonts.poppins(
                  color: primaryColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tripDetail(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          Expanded(
            child: Text(
              _valueOrDash(value),
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}