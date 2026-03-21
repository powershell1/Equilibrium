import 'package:equilibrium/function/APIHandler.dart';
import 'package:equilibrium/widgets/custom_nav_bar.dart';
import 'package:equilibrium/pages/ZoneDetailPage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'PairingPage.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Define colors from the design
  static const Color primary = Color(0xFF1BBB6E);
  static const Color backgroundLight = Color(0xFFF9FAF8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textMain = Color(0xFF2C3D35);
  static const Color muted = Color(0xFF9CAFA4);
  static const Color accent = Color(0xFF84A9C0);

  int _selectedIndex = 0;

  // Watt response
  Future<double> getTodayUsage() async {
    MeasurementsResponse response = await apiHandler.getMeasurements(MeasurementFrequency.daily);
    double deltaActivePower = response.measurements.first['activeEnergy'] - response.measurements.last['activeEnergy'];
    return deltaActivePower / 1000; // Convert from Wh to kWh
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100), // Add padding for navbar
              child: Column(
                children: [
                  // Sticky Header & Usage Hero
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                    decoration: BoxDecoration(
                      color: backgroundLight.withValues(alpha: 0.85),
                      border: Border(
                        bottom: BorderSide(
                          color: primary.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.eco, color: primary, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              "TODAY'S USAGE",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                                color: muted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              "0.0",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: textMain,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "kWh",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: muted,
                              ),
                            ),
                          ],
                        ),
                        /*
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.trending_down, color: primary, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                "14% below average today",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: primary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                         */
                      ],
                    ),
                  ),
                  
                  // Main Content: HEMS Box List
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Active Zones",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: textMain,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (context) => const PairingPage(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add, color: primary),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                hoverColor: primary.withValues(alpha: 0.1),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // Box Card 1: Living Room
                        _buildZoneCard(
                          icon: Icons.chair_outlined,
                          title: "Living Room",
                          deviceCount: 1,
                          wattage: 120,
                          isActive: true,
                        ),
                        const SizedBox(height: 80), // Spacer for bottom nav
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: CustomNavBar(selectedIndex: 0),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneCard({
    required IconData icon,
    required String title,
    required int deviceCount,
    required int wattage,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ZoneDetailPage(zoneName: title),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: primary.withValues(alpha: 0.05)),
          boxShadow: const [
             BoxShadow(
              color: Color.fromRGBO(90, 125, 108, 0.08), // Using rgba(90, 125, 108, 0.08)
              offset: Offset(0, 12),
              blurRadius: 32,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(icon, color: primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: textMain,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive ? Color(0xFF1BBB6E) : Color(0xFF9CAFA4),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "${isActive ? "Active" : "Offline"} • $deviceCount Devices",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: muted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isActive)
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    wattage.toString(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: accent,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "W",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: muted,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 32,
            decoration: BoxDecoration(
              color: isSelected ? primary.withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(
              icon,
              color: isSelected ? primary : muted,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? primary : muted,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
