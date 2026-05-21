import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/app_user.dart';
import '../models/trip.dart';
import '../services/user_service.dart';
import '../services/trip_service.dart';
import '../widgets/trip_card.dart';
import 'create_trip_screen.dart';
import 'packing_list_screen.dart';
import 'profile_screen.dart';

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

  AppUser? user;
  List<Trip> trips = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadHomeData();
  }

  Future<void> loadHomeData() async {
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
        trips = loadedTrips.take(3).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load home data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Image.asset(
                                'assets/logo.png',
                                height: 48,
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.person_outline_rounded,
                                  color: darkBlue,
                                  size: 28,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ProfileScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          Text(
                            'Welcome\n${user?.username ?? 'traveler'} 👋',
                            style: GoogleFonts.poppins(
                              color: darkBlue,
                              fontSize: 24,
                              height: 1.25,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 28),

                          Center(
                            child: Image.asset(
                              'assets/packing_home.png',
                              height: 145,
                              fit: BoxFit.contain,
                            ),
                          ),

                          const SizedBox(height: 24),

                          Center(
                            child: Text(
                              'Let me help you packing for\nyour next trip',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: darkBlue,
                                fontSize: 14,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          Center(
                            child: ElevatedButton(
                              onPressed: () async {
                                final created = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CreateTripScreen(),
                                  ),
                                );

                                if (created == true) {
                                  loadHomeData();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: darkBlue,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 38,
                                  vertical: 13,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                              ),
                              child: Text(
                                'Start\nPacking',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                  height: 1.1,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(28, 22, 28, 24),
                    decoration: const BoxDecoration(
                      color: lightBlue,
                      border: Border(
                        top: BorderSide(
                          color: darkBlue,
                          width: 0.8,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My trips',
                          style: GoogleFonts.poppins(
                            color: darkBlue,
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 16),

                        if (trips.isEmpty)
                          Text(
                            'No trips yet. Start packing your first trip!',
                            style: GoogleFonts.poppins(
                              color: darkBlue,
                              fontSize: 13,
                            ),
                          )
                        else
                          ...trips.map(
                            (trip) => TripCard(
                              trip: trip,
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
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}