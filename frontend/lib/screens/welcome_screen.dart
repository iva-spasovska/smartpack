import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/app_logo.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const Color cream = Color(0xFFF5EFEB);
  static const Color teal = Color(0xFF4F8D9C);
  static const Color deepTeal = Color(0xFF2F4858);
  static const Color paleBlue = Color(0xFFE8F3F7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxHeight < 720;

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _TopBar(isCompact: isCompact),
                      SizedBox(height: isCompact ? 12 : 20),
                      _HeroPanel(isCompact: isCompact),
                      SizedBox(height: isCompact ? 12 : 16),
                      const _FeatureRow(),
                      SizedBox(height: isCompact ? 14 : 18),
                      _AuthActions(
                        onLogin: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        ),
                        onRegister: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppLogo(compact: isCompact),
        const Spacer(),
      ],
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(22, isCompact ? 22 : 28, 22, 24),
      decoration: BoxDecoration(
        color: WelcomeScreen.teal,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: WelcomeScreen.deepTeal.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'PackPal',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: isCompact ? 34 : 42,
              fontWeight: FontWeight.w700,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Plan every trip with a packing list that feels ready before you are.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.88),
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: isCompact ? 14 : 18),
          Container(
            width: double.infinity,
            constraints: BoxConstraints(maxHeight: isCompact ? 210 : 250),
            decoration: BoxDecoration(
              color: WelcomeScreen.cream,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Positioned(
                  left: 16,
                  top: 16,
                  child: _MiniBadge(
                    icon: Icons.cloud_outlined,
                    label: 'Weather aware',
                  ),
                ),
                const Positioned(
                  right: 16,
                  bottom: 16,
                  child: _MiniBadge(
                    icon: Icons.checklist_rounded,
                    label: 'Trip ready',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Image.asset(
                    'assets/packing_home.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: WelcomeScreen.teal),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: WelcomeScreen.deepTeal,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _FeatureTile(icon: Icons.luggage_rounded, label: 'Lists'),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _FeatureTile(icon: Icons.place_outlined, label: 'Trips'),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _FeatureTile(icon: Icons.wb_sunny_outlined, label: 'Forecast'),
        ),
      ],
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      decoration: BoxDecoration(
        color: WelcomeScreen.paleBlue,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: WelcomeScreen.deepTeal, size: 24),
          const SizedBox(height: 7),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: WelcomeScreen.deepTeal,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthActions extends StatelessWidget {
  const _AuthActions({required this.onLogin, required this.onRegister});

  final VoidCallback onLogin;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 56,
          child: ElevatedButton.icon(
            onPressed: onLogin,
            icon: const Icon(Icons.login_rounded, size: 21),
            label: Text(
              'Log in',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: WelcomeScreen.deepTeal,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 56,
          child: OutlinedButton.icon(
            onPressed: onRegister,
            icon: const Icon(Icons.person_add_alt_1_rounded, size: 21),
            label: Text(
              'Create account',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: WelcomeScreen.deepTeal,
              side: const BorderSide(color: WelcomeScreen.teal, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
