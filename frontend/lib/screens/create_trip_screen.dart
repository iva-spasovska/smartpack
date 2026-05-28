import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/trip.dart';
import '../services/location_service.dart';
import '../services/trip_service.dart';
import '../widgets/app_text_field.dart';
import '../widgets/primary_button.dart';
import 'packing_list_screen.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  static const Color bgColor = Color(0xFFF5EFEB);
  static const Color darkBlue = Color(0xFF2F4858);
  static const Color primaryColor = Color(0xFF4F8D9C);

  final destinationController = TextEditingController();
  final tripNameController = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;
  String? luggageType;
  String? tripType;

  bool isLoading = false;
  bool isLocating = false;

  final List<Map<String, String>> luggageOptions = [
    {'label': 'Backpack', 'value': 'backpack'},
    {'label': 'Small Suitcase (≤ 10kg)', 'value': 'small_suitcase'},
    {'label': 'Large Suitcase (> 10kg)', 'value': 'large_suitcase'},
  ];

  final List<Map<String, String>> tripTypeOptions = [
    {'label': 'City', 'value': 'city'},
    {'label': 'Beach', 'value': 'beach'},
    {'label': 'Mountain', 'value': 'mountain'},
    {'label': 'Business', 'value': 'business'},
  ];

  @override
  void dispose() {
    destinationController.dispose();
    tripNameController.dispose();
    super.dispose();
  }

  Future<void> pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      setState(() {
        startDate = picked;
        // reset end date if it's before the new start date
        if (endDate != null && endDate!.isBefore(picked)) {
          endDate = null;
        }
      });
    }
  }

  Future<void> pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate != null
          ? startDate!.add(const Duration(days: 1))
          : DateTime.now().add(const Duration(days: 1)),
      firstDate: startDate ?? DateTime.now(),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      setState(() => endDate = picked);
    }
  }

  String formatDateForBackend(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String formatDateForUi(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  Future<void> handlePackMe() async {
    if (destinationController.text.trim().isEmpty ||
        startDate == null ||
        endDate == null ||
        luggageType == null ||
        tripType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all trip details')),
      );
      return;
    }

    setState(() => isLoading = true);

    final destination = destinationController.text.trim();

    final trip = Trip(
      id: 0,
      name: tripNameController.text.trim().isEmpty
          ? '$destination trip'
          : tripNameController.text.trim(),
      destination: destination,
      startDate: formatDateForBackend(startDate!),
      endDate: formatDateForBackend(endDate!),
      durationDays: 0,
      luggageType: luggageType!,
      tripType: tripType!,
    );

    try {
      final createdTrip = await TripService().createTrip(trip);

      if (!mounted) return;

      setState(() => isLoading = false);

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PackingListScreen(
              trip: createdTrip,
              readOnlyExistingTrip: false
          ),
        ),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create trip')),
      );
    }
  }

  Future<void> fillCurrentLocation() async {
    setState(() => isLocating = true);

    try {
      final label = await LocationService().currentDestinationLabel();

      if (!mounted) return;

      destinationController.text = label;
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not get your current location')),
      );
    } finally {
      if (mounted) {
        setState(() => isLocating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: darkBlue,
                ),
                onPressed: () => Navigator.pop(context),
              ),

              const SizedBox(height: 12),

              Text(
                'Tell us about\nyour trip',
                style: GoogleFonts.poppins(
                  color: darkBlue,
                  fontSize: 28,
                  height: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'PackPal will create a smart packing list for you.',
                style: GoogleFonts.poppins(
                  color: primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 20),

              AppTextField(
                controller: destinationController,
                hint: 'Destination, e.g. Vienna',
              ),

              const SizedBox(height: 6),

              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: isLocating ? null : fillCurrentLocation,
                  icon: isLocating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location_rounded, size: 18),
                  label: Text(
                    isLocating ? 'Finding location...' : 'Use my location',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                  ),
                  style: TextButton.styleFrom(foregroundColor: primaryColor),
                ),
              ),

              const SizedBox(height: 6),

              AppTextField(
                controller: tripNameController,
                hint: 'Trip name (optional)',
              ),

              const SizedBox(height: 16),

              _datePickerField(
                hint: 'Departure date',
                date: startDate,
                onTap: pickStartDate,
              ),

              const SizedBox(height: 16),

              _datePickerField(
                hint: 'Return date',
                date: endDate,
                onTap: pickEndDate,
              ),

              const SizedBox(height: 16),

              _dropdownField(
                hint: 'Luggage type',
                value: luggageType,
                items: luggageOptions,
                onChanged: (value) {
                  setState(() => luggageType = value);
                },
              ),

              const SizedBox(height: 16),

              _dropdownField(
                hint: 'Trip type',
                value: tripType,
                items: tripTypeOptions,
                onChanged: (value) {
                  setState(() => tripType = value);
                },
              ),

              const SizedBox(height: 30),

              Center(
                child: PrimaryButton(
                  text: 'Pack me',
                  isLoading: isLoading,
                  width: 180,
                  backgroundColor: darkBlue,
                  onPressed: handlePackMe,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _datePickerField({
    required String hint,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: const Color(0xFFC7DDE8).withValues(alpha: 0.55),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                date == null ? hint : formatDateForUi(date),
                style: GoogleFonts.poppins(
                  color: date == null ? Colors.grey : darkBlue,
                  fontSize: 15,
                ),
              ),
            ),
            const Icon(Icons.calendar_month_rounded, color: darkBlue),
          ],
        ),
      ),
    );
  }

  Widget _dropdownField({
    required String hint,
    required String? value,
    required List<Map<String, String>> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFC7DDE8).withValues(alpha: 0.55),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 15),
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: darkBlue),
          items: items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item['value'],
                  child: Text(
                    item['label']!,
                    style: GoogleFonts.poppins(color: darkBlue),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
