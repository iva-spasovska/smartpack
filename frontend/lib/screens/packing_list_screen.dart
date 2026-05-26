import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/trip.dart';
import '../models/packing_item.dart';
import '../models/weather_snapshot.dart';
import '../services/weather_service.dart';
import '../services/recommendation_service.dart';
import '../services/packing_list_service.dart';
import '../widgets/packing_category_section.dart';

class PackingListScreen extends StatefulWidget {
  final Trip trip;
  final bool readOnlyExistingTrip;

  const PackingListScreen({
    super.key,
    required this.trip,
    required this.readOnlyExistingTrip,
  });

  @override
  State<PackingListScreen> createState() => _PackingListScreenState();
}

class _PackingListScreenState extends State<PackingListScreen> {
  static const Color bgColor = Color(0xFFF5EFEB);
  static const Color darkBlue = Color(0xFF2F4858);
  static const Color primaryColor = Color(0xFF4F8D9C);
  static const Color cardColor = Color(0xFFE8F3F7);

  bool isLoading = true;
  bool isSaving = false;

  WeatherSnapshot? weather;
  List<PackingItem> items = [];

  @override
  void initState() {
    super.initState();
    loadPackingData();
  }

  Future<void> loadPackingData() async {
    try {
      final loadedWeather =
          await WeatherService().getWeatherForTrip(widget.trip.id);

      final savedList =
          await PackingListService().getUserPackingList(widget.trip.id);

      if (savedList != null && savedList.items.isNotEmpty) {
        setState(() {
          weather = loadedWeather;
          items = savedList.items;
          isLoading = false;
        });
        return;
      }

      final recommendation =
          await RecommendationService().getRecommendationForTrip(widget.trip.id);

      setState(() {
        weather = loadedWeather;
        items = recommendation?.recommendedItems ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load packing list')),
      );
    }
  }

  Future<void> savePackingList() async {
    setState(() => isSaving = true);

    try {
      await PackingListService().saveUserPackingList(
        tripId: widget.trip.id,
        items: items,
      );

      if (!mounted) return;

      setState(() => isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Packing list saved')),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save packing list')),
      );
    }
  }

  Map<String, List<PackingItem>> groupItemsByCategory() {
    final Map<String, List<PackingItem>> grouped = {};

    for (final item in items) {
      grouped.putIfAbsent(item.category, () => []);
      grouped[item.category]!.add(item);
    }

    return grouped;
  }

  String formatCategoryTitle(String category) {
    return category
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }

  String weatherTitle() {
    if (weather == null) return 'Weather unavailable';

    if (weather!.description != null && weather!.description!.isNotEmpty) {
      return weather!.description!;
    }

    if (weather!.condition != null && weather!.condition!.isNotEmpty) {
      return weather!.condition!;
    }

    if (weather!.isRainy) return 'Rainy weather';
    if (weather!.isSunny) return 'Sunny weather';
    if (weather!.isSnowy) return 'Snowy weather';
    if (weather!.isWindy) return 'Windy weather';

    return 'Weather forecast';
  }

  IconData weatherIcon() {
    if (weather == null) return Icons.cloud_off_rounded;
    if (weather!.isRainy) return Icons.water_drop_outlined;
    if (weather!.isSunny) return Icons.wb_sunny_outlined;
    if (weather!.isSnowy) return Icons.ac_unit_rounded;
    if (weather!.isWindy) return Icons.air_rounded;
    return Icons.cloud_outlined;
  }

  void toggleChecked(PackingItem item) {
    setState(() {
      item.isChecked = !item.isChecked;
    });
  }

  void increment(PackingItem item) {
    setState(() {
      item.quantity++;
    });
  }

  void decrement(PackingItem item) {
    if (item.quantity <= 1) return;

    setState(() {
      item.quantity--;
    });
  }

  @override
  Widget build(BuildContext context) {
    final groupedItems = groupItemsByCategory();

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _header(),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 26,
                        vertical: 18,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _weatherCard(),

                          const SizedBox(height: 26),

                          if (items.isEmpty)
                            Center(
                              child: Text(
                                'No packing recommendations found.',
                                style: GoogleFonts.poppins(
                                  color: darkBlue,
                                  fontSize: 14,
                                ),
                              ),
                            )
                          else
                            ...groupedItems.entries.map(
                              (entry) => PackingCategorySection(
                                title: formatCategoryTitle(entry.key),
                                items: entry.value,
                                onChecked: toggleChecked,
                                onIncrement: increment,
                                onDecrement: decrement,
                              ),
                            ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  _bottomSaveBar(),
                ],
              ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: darkBlue,
            ),
            onPressed: () => Navigator.pop(context, true),
          ),

          const SizedBox(width: 4),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.trip.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: darkBlue,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${widget.trip.destination} • ${widget.trip.durationDays} days',
                  style: GoogleFonts.poppins(
                    color: primaryColor,
                    fontSize: 12,
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

  Widget _weatherCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: darkBlue.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(
            weatherIcon(),
            size: 48,
            color: primaryColor,
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weatherTitle(),
                  style: GoogleFonts.poppins(
                    color: darkBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  weather?.temperature == null
                      ? 'Temperature unavailable'
                      : '${weather!.temperature!.toStringAsFixed(1)}°C',
                  style: GoogleFonts.poppins(
                    color: darkBlue,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'For ${widget.trip.destination}',
                  style: GoogleFonts.poppins(
                    color: darkBlue.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomSaveBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(26, 12, 26, 22),
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: isSaving ? null : savePackingList,
          style: ElevatedButton.styleFrom(
            backgroundColor: darkBlue,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: isSaving
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'Save packing list',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}