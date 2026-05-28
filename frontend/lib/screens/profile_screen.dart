import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/trip.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/trips_provider.dart';
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
  static const Color softMint = Color(0xFFC7DDE8);

  Trip? selectedTrip;
  bool hasLoaded = false;
  final editUsernameController = TextEditingController();

  final List<Map<String, String>> genderOptions = const [
    {'label': 'Male', 'value': 'male'},
    {'label': 'Female', 'value': 'female'},
    {'label': 'Other', 'value': 'other'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => loadProfileData());
  }

  @override
  void dispose() {
    editUsernameController.dispose();
    super.dispose();
  }

  Future<void> loadProfileData() async {
    try {
      await Future.wait([
        context.read<ProfileProvider>().loadProfile(),
        context.read<TripsProvider>().loadTrips(),
      ]);

      if (!mounted) return;

      final loadedTrips = context.read<TripsProvider>().trips;
      setState(() {
        selectedTrip = loadedTrips.isNotEmpty ? loadedTrips.first : null;
        hasLoaded = true;
      });
    } catch (e) {
      setState(() => hasLoaded = true);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load profile')),
      );
    }
  }

  Future<void> logout() async {
    await context.read<AuthProvider>().logout();
    if (mounted) {
      context.read<ProfileProvider>().clearSessionData();
      context.read<TripsProvider>().clearSessionData();
    }

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

  String _formatOption(String? value) {
    final raw = _valueOrDash(value);
    if (raw == '-') return raw;

    return raw
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }

  DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  String? _formatDateForBackend(DateTime? date) {
    if (date == null) return null;
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateForDisplay(String? value) {
    final date = _parseDate(value);
    if (date == null) return '-';

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _openEditProfileSheet() async {
    final user = context.read<ProfileProvider>().user;
    editUsernameController.text = user?.username ?? '';
    String? selectedGender = user?.gender;
    DateTime? selectedDate = _parseDate(user?.dateOfBirth);
    bool isSaving = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> pickDate() async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime(2000),
                firstDate: DateTime(1950),
                lastDate: DateTime.now(),
              );

              if (picked != null) {
                setSheetState(() => selectedDate = picked);
              }
            }

            Future<void> saveProfile() async {
              final username = editUsernameController.text.trim();

              if (username.isEmpty) {
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(content: Text('Username cannot be empty')),
                );
                return;
              }

              setSheetState(() => isSaving = true);

              try {
                await this.context.read<ProfileProvider>().updateProfile(
                  username: username,
                  gender: selectedGender,
                  dateOfBirth: _formatDateForBackend(selectedDate),
                );

                if (!mounted) return;

                Navigator.of(this.context).pop();
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(content: Text('Profile updated')),
                );
              } catch (e) {
                if (!context.mounted) return;
                setSheetState(() => isSaving = false);

                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(content: Text('Failed to update profile')),
                );
              }
            }

            return SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: softMint,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Edit profile',
                      style: GoogleFonts.poppins(
                        color: darkBlue,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Update your account details. Email stays locked for login.',
                      style: GoogleFonts.poppins(
                        color: darkBlue.withValues(alpha: 0.62),
                        fontSize: 12,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _editTextField(
                      controller: editUsernameController,
                      label: 'Username',
                      icon: Icons.alternate_email_rounded,
                    ),
                    const SizedBox(height: 12),
                    _readOnlyProfileField('Email', user?.email),
                    const SizedBox(height: 12),
                    _editDropdownField(
                      hint: 'Gender',
                      value: selectedGender,
                      onChanged: (value) {
                        setSheetState(() => selectedGender = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    _editDateField(
                      dateLabel: selectedDate == null
                          ? 'Date of birth'
                          : _formatDateForDisplay(
                              _formatDateForBackend(selectedDate),
                            ),
                      onTap: pickDate,
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: isSaving ? null : saveProfile,
                        icon: isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.check_rounded),
                        label: Text(
                          isSaving ? 'Saving...' : 'Save changes',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final tripsProvider = context.watch<TripsProvider>();
    final isLoading = profileProvider.isLoading || tripsProvider.isLoading;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: isLoading && !hasLoaded
            ? const Center(
                child: CircularProgressIndicator(color: primaryColor),
              )
            : RefreshIndicator(
                color: primaryColor,
                onRefresh: loadProfileData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _topBar(),
                      const SizedBox(height: 16),
                      _profileHero(),
                      const SizedBox(height: 16),
                      _statsRow(),
                      const SizedBox(height: 18),
                      _infoCard(),
                      const SizedBox(height: 22),
                      _lastTripsSection(),
                      const SizedBox(height: 24),
                      _logoutButton(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _topBar() {
    return Row(
      children: [
        IconButton.filled(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          color: darkBlue,
          style: IconButton.styleFrom(
            backgroundColor: cardColor,
            fixedSize: const Size(44, 44),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        const Spacer(),
        Text(
          'Profile',
          style: GoogleFonts.poppins(
            color: darkBlue,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        IconButton.filled(
          icon: const Icon(Icons.edit_outlined, size: 20),
          color: darkBlue,
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.72),
            fixedSize: const Size(44, 44),
          ),
          onPressed: _openEditProfileSheet,
        ),
      ],
    );
  }

  Widget _profileHero() {
    final user = context.watch<ProfileProvider>().user;
    final username = user?.username ?? 'Traveler';
    final initial = username.isNotEmpty ? username[0].toUpperCase() : 'T';
    final profilePhotoUrl = user?.profilePhotoUrl;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: darkBlue,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: darkBlue.withValues(alpha: 0.14),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () async {
              try {
                await context.read<ProfileProvider>().takeProfilePhoto();
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Could not open camera')),
                );
              }
            },
            borderRadius: BorderRadius.circular(26),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(26),
                    image: profilePhotoUrl == null
                        ? null
                        : DecorationImage(
                            image: NetworkImage(profilePhotoUrl),
                            fit: BoxFit.cover,
                          ),
                  ),
                  child: profilePhotoUrl == null
                      ? Center(
                          child: Text(
                            initial,
                            style: GoogleFonts.poppins(
                              color: primaryColor,
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        )
                      : null,
                ),
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: darkBlue, width: 2),
                    ),
                    child: const Icon(
                      Icons.photo_camera_outlined,
                      color: Colors.white,
                      size: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 24,
                    height: 1.15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  user?.email ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsRow() {
    final user = context.watch<ProfileProvider>().user;
    final trips = context.watch<TripsProvider>().trips;

    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Icons.route_outlined,
            value: trips.length.toString(),
            label: 'Trips',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            icon: Icons.cake_outlined,
            value: user?.age?.toString() ?? '-',
            label: 'Age',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            icon: Icons.person_outline_rounded,
            value: _formatOption(user?.gender),
            label: 'Gender',
          ),
        ),
      ],
    );
  }

  Widget _infoCard() {
    final user = context.watch<ProfileProvider>().user;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account details',
            style: GoogleFonts.poppins(
              color: darkBlue,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _infoRow(Icons.alternate_email_rounded, 'Username', user?.username),
          _divider(),
          _infoRow(Icons.email_outlined, 'Email', user?.email),
          _divider(),
          _infoRow(
            Icons.person_outline_rounded,
            'Gender',
            _formatOption(user?.gender),
          ),
          _divider(),
          _infoRow(
            Icons.calendar_today_outlined,
            'Date of birth',
            _formatDateForDisplay(user?.dateOfBirth),
          ),
          _divider(),
          _infoRow(Icons.cake_outlined, 'Age', user?.age?.toString()),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primaryColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: darkBlue.withValues(alpha: 0.62),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _valueOrDash(value),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: darkBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _editTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: GoogleFonts.poppins(color: darkBlue, fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.8),
        prefixIcon: Icon(icon, color: primaryColor, size: 20),
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: darkBlue.withValues(alpha: 0.56),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: softMint),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: primaryColor, width: 1.4),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
      ),
    );
  }

  Widget _readOnlyProfileField(String label, String? value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: softMint),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: darkBlue.withValues(alpha: 0.56),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _valueOrDash(value),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: darkBlue,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.lock_outline_rounded,
            color: darkBlue.withValues(alpha: 0.38),
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(color: darkBlue.withValues(alpha: 0.1), height: 1);
  }

  Widget _lastTripsSection() {
    final trips = context.watch<TripsProvider>().trips;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Recent trips',
              style: GoogleFonts.poppins(
                color: darkBlue,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            if (trips.isNotEmpty)
              Text(
                '${trips.length} total',
                style: GoogleFonts.poppins(
                  color: primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (trips.isEmpty)
          _emptyTripsCard()
        else ...[
          _tripDropdown(),
          const SizedBox(height: 12),
          if (selectedTrip != null) _selectedTripCard(selectedTrip!),
        ],
      ],
    );
  }

  Widget _tripDropdown() {
    final trips = context.watch<TripsProvider>().trips;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: softMint),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Trip>(
          value: selectedTrip,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: darkBlue),
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
                      fontWeight: FontWeight.w600,
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
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PackingListScreen(
              trip: trip,
              readOnlyExistingTrip: trip.hasEnded,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: softMint),
          boxShadow: [
            BoxShadow(
              color: darkBlue.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.location_on_outlined,
                    color: primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: darkBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        trip.destination,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: darkBlue.withValues(alpha: 0.62),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: darkBlue,
                  size: 15,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _TripChip(
                  icon: Icons.calendar_today_outlined,
                  label: trip.startDate,
                ),
                _TripChip(
                  icon: Icons.schedule_rounded,
                  label: '${trip.durationDays} days',
                ),
                _TripChip(
                  icon: Icons.luggage_outlined,
                  label: _formatOption(trip.luggageType),
                ),
                _TripChip(
                  icon: Icons.business_center_outlined,
                  label: _formatOption(trip.tripType),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyTripsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.luggage_outlined, color: primaryColor, size: 34),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'No trips yet. Create your first one from the home screen.',
              style: GoogleFonts.poppins(
                color: darkBlue,
                fontSize: 12,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _editDropdownField({
    required String hint,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: softMint),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: GoogleFonts.poppins(
              color: darkBlue.withValues(alpha: 0.48),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: darkBlue),
          items: genderOptions
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item['value'],
                  child: Text(
                    item['label']!,
                    style: GoogleFonts.poppins(
                      color: darkBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _editDateField({
    required String dateLabel,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: softMint),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                dateLabel,
                style: GoogleFonts.poppins(
                  color: dateLabel == 'Date of birth'
                      ? darkBlue.withValues(alpha: 0.48)
                      : darkBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.calendar_today_outlined,
              color: darkBlue,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _logoutButton() {
    return SizedBox(
      height: 54,
      child: OutlinedButton.icon(
        onPressed: logout,
        icon: const Icon(Icons.logout_rounded),
        label: Text(
          'Logout',
          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: BorderSide(color: Colors.red.withValues(alpha: 0.42)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
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
      height: 88,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.66),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _ProfileScreenState.softMint),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: _ProfileScreenState.primaryColor, size: 22),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: _ProfileScreenState.darkBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: _ProfileScreenState.darkBlue.withValues(alpha: 0.62),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TripChip extends StatelessWidget {
  const _TripChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _ProfileScreenState.cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _ProfileScreenState.primaryColor, size: 15),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 132),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: _ProfileScreenState.darkBlue,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
