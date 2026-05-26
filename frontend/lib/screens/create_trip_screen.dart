import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/trip.dart';
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
  int durationDays = 1;
  String? luggageType;
  String? tripType;

  bool isLoading = false;

  final List<String> luggageOptions = [
    'Backpack',
    'Carry-on',
    'Suitcase',
    'Large suitcase',
  ];

  final List<String> tripTypeOptions = [
    'Business',
    'Vacation',
    'Beach',
    'Adventure',
    'City break',
    'Winter',
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
      setState(() => startDate = picked);
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
      durationDays: durationDays,
      luggageType: luggageType,
      tripType: tripType,
    );

    try {
      final createdTrip = await TripService().createTrip(trip);

      if (!mounted) return;

      setState(() => isLoading = false);

      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PackingListScreen(
            trip: createdTrip,
            readOnlyExistingTrip: false,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create trip')),
      );
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

              const SizedBox(height: 32),

              AppTextField(
                controller: destinationController,
                hint: 'Destination, e.g. Vienna',
              ),

              const SizedBox(height: 16),

              AppTextField(
                controller: tripNameController,
                hint: 'Trip name optional',
              ),

              const SizedBox(height: 16),

              _datePickerField(),

              const SizedBox(height: 16),

              _durationSelector(),

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

              const SizedBox(height: 40),

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

  Widget _datePickerField() {
    return GestureDetector(
      onTap: pickStartDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                startDate == null
                    ? 'Departure date'
                    : formatDateForUi(startDate!),
                style: GoogleFonts.poppins(
                  color: startDate == null ? Colors.grey : darkBlue,
                  fontSize: 15,
                ),
              ),
            ),
            const Icon(
              Icons.calendar_month_rounded,
              color: darkBlue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _durationSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Duration',
              style: GoogleFonts.poppins(
                color: darkBlue,
                fontSize: 15,
              ),
            ),
          ),
          IconButton(
            onPressed: durationDays > 1
                ? () {
                    setState(() => durationDays--);
                  }
                : null,
            icon: const Icon(Icons.remove_circle_outline),
          ),
          Text(
            '$durationDays days',
            style: GoogleFonts.poppins(
              color: darkBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() => durationDays++);
            },
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    );
  }

  Widget _dropdownField({
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(28),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: GoogleFonts.poppins(
              color: Colors.grey,
              fontSize: 15,
            ),
          ),
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: darkBlue,
          ),
          items: items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item.toLowerCase().replaceAll(' ', '_'),
                  child: Text(
                    item,
                    style: GoogleFonts.poppins(
                      color: darkBlue,
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
}