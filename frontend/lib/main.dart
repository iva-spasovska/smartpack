import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/trips_provider.dart';
import 'screens/welcome_screen.dart';
import 'services/auth_service.dart';
import 'services/trip_service.dart';
import 'services/user_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              AuthProvider(authService: AuthService())..checkSession(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(userService: UserService()),
        ),
        ChangeNotifierProvider(
          create: (_) => TripsProvider(tripService: TripService()),
        ),
      ],
      child: const PackPalApp(),
    ),
  );
}

class PackPalApp extends StatelessWidget {
  const PackPalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PackPal',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F8D9C)),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}
