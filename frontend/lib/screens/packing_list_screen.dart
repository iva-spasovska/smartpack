import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/packing_item.dart';
import '../models/trip.dart';
import '../models/weather_snapshot.dart';
import '../services/packing_list_service.dart';
import '../services/recommendation_service.dart';
import '../services/trip_service.dart';
import '../services/weather_service.dart';
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
  static const Color softMint = Color(0xFFC7DDE8);

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
      final loadedWeather = await WeatherService().getWeatherForTrip(
        widget.trip.id,
      );

      final savedList = await PackingListService().getUserPackingList(
        widget.trip.id,
      );

      if (savedList != null && savedList.items.isNotEmpty) {
        setState(() {
          weather = loadedWeather;
          items = savedList.items;
          isLoading = false;
        });
        return;
      }

      final recommendation = await RecommendationService()
          .getRecommendationForTrip(widget.trip.id);

      setState(() {
        weather = loadedWeather;
        items = recommendation?.recommendedItems ?? [];
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load packing data')),
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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Packing list saved')));
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() => isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save packing list')),
      );
    }
  }

  Future<void> deleteTrip() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          'Delete trip?',
          style: GoogleFonts.poppins(
            color: darkBlue,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'This will permanently delete "${widget.trip.name}" and its packing list.',
          style: GoogleFonts.poppins(
            color: darkBlue,
            fontSize: 13,
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: primaryColor),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await TripService().deleteTrip(widget.trip.id);

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to delete trip')));
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

  int get checkedCount => items.where((item) => item.isChecked).length;

  bool get isPreviewOnly => widget.trip.hasEnded;

  double get progressValue {
    if (items.isEmpty) return 0;
    return checkedCount / items.length;
  }

  @override
  Widget build(BuildContext context) {
    final groupedItems = groupItemsByCategory();

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: primaryColor),
              )
            : Column(
                children: [
                  _topBar(),
                  Expanded(
                    child: RefreshIndicator(
                      color: primaryColor,
                      onRefresh: loadPackingData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _tripHero(),
                            const SizedBox(height: 16),
                            _weatherCard(),
                            const SizedBox(height: 16),
                            _progressCard(),
                            const SizedBox(height: 22),
                            if (items.isEmpty)
                              const _EmptyPackingCard()
                            else
                              ...groupedItems.entries.map(
                                (entry) => PackingCategorySection(
                                  title: formatCategoryTitle(entry.key),
                                  items: entry.value,
                                  isReadOnly: isPreviewOnly,
                                  onChecked: toggleChecked,
                                  onIncrement: increment,
                                  onDecrement: decrement,
                                ),
                              ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _bottomSaveBar(),
                ],
              ),
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 14, 8),
      child: Row(
        children: [
          IconButton.filled(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            color: darkBlue,
            style: IconButton.styleFrom(
              backgroundColor: cardColor,
              fixedSize: const Size(44, 44),
            ),
            onPressed: () => Navigator.pop(context, true),
          ),
          const Spacer(),
          if (!isPreviewOnly)
            IconButton.filled(
              icon: const Icon(Icons.delete_outline_rounded),
              color: Colors.red,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.72),
                fixedSize: const Size(44, 44),
              ),
              onPressed: deleteTrip,
            ),
          if (isPreviewOnly) const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _tripHero() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: darkBlue,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: darkBlue.withValues(alpha: 0.16),
            blurRadius: 22,
            offset: const Offset(0, 12),
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
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.luggage_outlined, color: softMint),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.trip.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 23,
                    height: 1.15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeroChip(
                icon: Icons.place_outlined,
                label: widget.trip.destination,
              ),
              _HeroChip(
                icon: Icons.calendar_today_outlined,
                label: '${widget.trip.durationDays} days',
              ),
              _HeroChip(
                icon: Icons.business_center_outlined,
                label: _formatOption(widget.trip.tripType),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _weatherCard() {
    final temperature = weather?.temperature;
    final humidity = weather?.humidity;
    final windSpeed = weather?.windSpeed;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(weatherIcon(), size: 30, color: primaryColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weatherTitle(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: darkBlue,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  weather == null
                      ? 'Could not load weather for ${widget.trip.destination}'
                      : 'Current weather for ${widget.trip.destination}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: darkBlue.withValues(alpha: 0.62),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (humidity != null)
                      _WeatherMetric(
                        icon: Icons.water_drop_outlined,
                        label: '$humidity%',
                      ),
                    if (windSpeed != null)
                      _WeatherMetric(
                        icon: Icons.air_rounded,
                        label: '${windSpeed.toStringAsFixed(1)} m/s',
                      ),
                    if (weather?.fetchedAt != null)
                      _WeatherMetric(
                        icon: Icons.update_rounded,
                        label: _formatFetchedAt(weather!.fetchedAt!),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            temperature == null ? '--' : '${temperature.toStringAsFixed(1)} C',
            style: GoogleFonts.poppins(
              color: darkBlue,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  String _formatFetchedAt(DateTime fetchedAt) {
    final local = fetchedAt.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _progressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: softMint),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                isPreviewOnly ? 'Packed preview' : 'Packing progress',
                style: GoogleFonts.poppins(
                  color: darkBlue,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '$checkedCount/${items.length}',
                style: GoogleFonts.poppins(
                  color: primaryColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: 9,
              backgroundColor: cardColor,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomSaveBar() {
    if (isPreviewOnly) {
      return Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 22),
        decoration: BoxDecoration(
          color: bgColor,
          boxShadow: [
            BoxShadow(
              color: darkBlue.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Container(
          width: double.infinity,
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: softMint),
          ),
          child: Text(
            'Preview only',
            style: GoogleFonts.poppins(
              color: darkBlue,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 22),
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: darkBlue.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          onPressed: isSaving ? null : savePackingList,
          icon: isSaving
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.check_rounded),
          label: Text(
            isSaving ? 'Saving...' : 'Save packing list',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
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
    );
  }

  String _formatOption(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _PackingListScreenState.softMint, size: 16),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: Colors.white,
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

class _WeatherMetric extends StatelessWidget {
  const _WeatherMetric({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _PackingListScreenState.primaryColor, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: _PackingListScreenState.darkBlue,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPackingCard extends StatelessWidget {
  const _EmptyPackingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _PackingListScreenState.cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            color: _PackingListScreenState.primaryColor,
            size: 42,
          ),
          const SizedBox(height: 12),
          Text(
            'No packing recommendations found',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: _PackingListScreenState.darkBlue,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try saving the trip again or checking the recommendation service.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: _PackingListScreenState.darkBlue.withValues(alpha: 0.62),
              fontSize: 12,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
