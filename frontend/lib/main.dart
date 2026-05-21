import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';

void main() {
  runApp(const PackPalApp());
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
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const Color primaryColor = Color(0xFF4F97A8);
  static const Color backgroundColor = Color(0xFFF5EFEB);
  static const Color darkText = Color(0xFF2F4858);
  static const Color lightText = Color(0xFF7A8A99);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [

              const Spacer(),

              // LOGO
              Center(
                child: Image.asset(
                  'assets/Frame.png',
                  height: 270,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Pack smart. Travel easy.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: lightText,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.3,
                ),
              ),

              const Spacer(),

              // LOGIN BUTTON
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // REGISTER BUTTON
              SizedBox(
                width: double.infinity,
                height: 58,
                child: OutlinedButton(
                  onPressed: () {
                   Navigator.push(
                     context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                    },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: primaryColor,
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    'Register',
                    style: TextStyle(
                      fontSize: 18,
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}