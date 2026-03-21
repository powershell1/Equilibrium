import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:equilibrium/widgets/custom_nav_bar.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF8),
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 60, 24, 140),
        children: [
          // Header Actions
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ACTIVITY FEED',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF414844),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Latest Alerts',
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2C3D35),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 40),

          // Today Group
          _buildSectionHeader('Today'),
          const SizedBox(height: 24),
          _buildNotificationItem(
            icon: Icons.eco,
            iconBgColor: const Color(0xFFC5EBD7),
            iconColor: const Color(0xFF426454),
            title: '10% below average',
            time: '2h ago',
            description: 'Great job! Your energy consumption is significantly lower than your weekly average. Keep it up!',
          ),
          const SizedBox(height: 16),
          _buildNotificationItem(
            icon: Icons.lightbulb_outline,
            iconBgColor: const Color(0xFFD3E7DC),
            iconColor: const Color(0xFF394B42),
            title: 'Eco-Tip: Unplug standby devices',
            time: '5h ago',
            description: 'Devices in standby mode still consume \'vampire\' energy. Unplugging your TV and gaming console could save you \$5/mo.',
            hasLeftBorder: true,
          ),

          const SizedBox(height: 48),

          // Yesterday Group
          _buildSectionHeader('Yesterday'),
          const SizedBox(height: 24),
          _buildNotificationItem(
            icon: Icons.settings,
            iconBgColor: const Color(0xFFE1E3E1),
            iconColor: const Color(0xFF414844),
            title: 'Living Room HEMS updated',
            time: 'Yesterday',
            description: 'System firmware version 2.4.1 has been successfully installed. Includes optimized peak-load algorithms.',
            opacity: 0.8,
          ),
          const SizedBox(height: 16),
          _buildNotificationItem(
            icon: Icons.priority_high,
            iconBgColor: const Color(0xFFFFDAD8), // tertiary-fixed
            iconColor: const Color(0xFF633C3B), // on-tertiary-fixed-variant
            title: 'Peak Pricing Alert',
            time: 'Yesterday',
            description: "Utility rates are currently 2x higher than usual. We've automatically adjusted your HVAC to Eco-mode.",
            opacity: 0.8,
          ),

          const SizedBox(height: 48),

          // Earlier Group
          _buildSectionHeader('Earlier this week'),
          const SizedBox(height: 24),
          _buildNotificationItem(
            icon: Icons.insert_chart_outlined,
            iconBgColor: const Color(0xFFD3E7DC),
            iconColor: const Color(0xFF394B42),
            title: 'Weekly Summary Ready',
            time: 'Monday',
            description: 'You saved 14% more energy compared to last week. Tap to see your full impact report.',
            opacity: 0.6,
          ),
        ],
      ),
      bottomNavigationBar: const CustomNavBar(selectedIndex: 2),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3D35),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFFC1C8C2).withOpacity(0.2),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String time,
    required String description,
    bool hasLeftBorder = false,
    double opacity = 1.0,
  }) {
    return Opacity(
      opacity: opacity,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F2), // surface-container-low
          borderRadius: BorderRadius.circular(16),
          border: hasLeftBorder
              ? const Border(left: BorderSide(color: Color(0xFF426454), width: 4))
              : null,
        ),
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16, // Adjusted slightly smaller than lg to fit
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2C3D35),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE1E3E1), // surface-container-highest
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          time,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF414844),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      height: 1.5,
                      color: const Color(0xFF414844),
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

