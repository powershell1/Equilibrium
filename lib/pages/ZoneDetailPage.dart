import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'OutletDetailPage.dart';

class ZoneDetailPage extends StatefulWidget {
  final String zoneName;
  final bool isOutletOn;

  const ZoneDetailPage({
    super.key,
    required this.zoneName,
    this.isOutletOn = false,
  });

  @override
  State<ZoneDetailPage> createState() => _ZoneDetailPageState();
}

class _ZoneDetailPageState extends State<ZoneDetailPage> {
  static const Color primary = Color(0xFF1BBB6E);
  static const Color backgroundLight = Color(0xFFF6F8F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color slate900 = Color(0xFF0F172A); // Tailwind slate-900
  static const Color slate500 = Color(0xFF64748B); // Tailwind slate-500
  static const Color slate400 = Color(0xFF94A3B8); // Tailwind slate-400
  static const Color slate100 = Color(0xFFF1F5F9); // Tailwind slate-100

  // Simulating state for the toggle buttons
  late bool isOutletOn;

  int totalLoad = 0; // Simulated total load in watts
  int maxLoad = 3520; // Simulated max load capacity in watts

  @override
  void initState() {
    super.initState();
    isOutletOn = widget.isOutletOn;
    totalLoad = isOutletOn ? 750 : 0;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, isOutletOn);
      },
      child: Scaffold(
        backgroundColor: backgroundLight,
        body: SafeArea(
          child: Column(
            children: [
              // Sticky Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                color: backgroundLight.withValues(alpha: 0.9),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context, isOutletOn),
                      child: const Icon(Icons.arrow_back, size: 24, color: slate900),
                    ),
                    Expanded(
                      child: Text(
                        "${widget.zoneName}",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: slate900,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                  ],
                ),
              ),

              // Main Content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 96),
                  children: [
                    // Total Load Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(90, 125, 108, 0.08),
                            offset: Offset(0, 12),
                            blurRadius: 32,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Total Load",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: slate500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "${totalLoad}W",
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: slate900,
                                          ),
                                        ),
                                        TextSpan(
                                          text: " / ${maxLoad}W",
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: slate400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Icon(Icons.bolt, color: primary, size: 32),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Gauge Bar
                          LayoutBuilder(
                            builder: (context, constraints) {
                              return Stack(
                                children: [
                                  Container(
                                    height: 10,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: slate100,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                  // Danger Zone (Last 20%)
                                  Positioned(
                                    right: 0,
                                    child: Container(
                                      height: 10,
                                      width: constraints.maxWidth * 0.2,
                                      // 20%
                                      decoration: const BoxDecoration(
                                        color: Colors.amber,
                                        borderRadius: BorderRadius.horizontal(
                                          right: Radius.circular(999),
                                        ),
                                      ),
                                    ),
                                  ),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeOutCubic,
                                    height: 10,
                                    width:
                                        constraints.maxWidth *
                                        (totalLoad / maxLoad).clamp(0.0, 1.0),
                                    decoration: BoxDecoration(
                                      color: (totalLoad / maxLoad) > 0.8
                                          ? Colors.amber
                                          : primary,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "${(totalLoad / maxLoad * 100).floor()}% Capacity",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: slate500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Outlets Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Connected Outlets",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: slate900,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            "${isOutletOn ? 1 : 0} Active",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: primary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Outlets Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.0,
                      // Square cards
                      children: [
                        _buildOutletCard(
                          icon: Icons.coffee_maker,
                          name: "Coffee Maker",
                          value: isOutletOn ? "750W" : "0W",
                          isOn: isOutletOn,
                          deviceConnection: false,
                          onToggle: () => setState(() {
                            isOutletOn = !isOutletOn;
                            totalLoad = isOutletOn ? 750 : 0;
                          }),
                          onCardTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OutletDetailPage(
                                  outletName: "Coffee Maker",
                                  currentWattage: "750W",
                                  initialStatus: isOutletOn,
                                ),
                              ),
                            );
                            if (result != null && result is bool) {
                              setState(() {
                                isOutletOn = result;
                                totalLoad = isOutletOn ? 750 : 0;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOutletCard({
    required IconData icon,
    required String name,
    required String value,
    required bool isOn,
    required bool deviceConnection,
    required VoidCallback onToggle,
    required VoidCallback onCardTap,
  }) {
    return GestureDetector(
      onTap: onCardTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(90, 125, 108, 0.08),
              offset: Offset(0, 12),
              blurRadius: 32,
            ),
          ],
          // Opacity effect for OFF state if needed, though design uses color changes mostly
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: slate400, size: 24),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isOn && deviceConnection
                        ? primary
                        : const Color(0xFFE2E8F0), // slate-200
                    shape: BoxShape.circle,
                    boxShadow: isOn
                        ? [
                            BoxShadow(
                              color: primary.withValues(alpha: 0.6),
                              blurRadius: 8,
                            ),
                          ]
                        : [],
                  ),
                ),
              ],
            ),

            // Power Button
            GestureDetector(
              onTap: onToggle,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isOn ? primary.withValues(alpha: 0.1) : slate100,
                  shape: BoxShape.circle,
                  border: isOn ? Border.all(color: primary, width: 2) : null,
                ),
                child: Icon(
                  Icons.power_settings_new,
                  size: 32,
                  color: isOn ? primary : slate400,
                ),
              ),
            ),

            Column(
              children: [
                Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color:
                        slate900, // Just using logic to match potential slight variants
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isOn ? primary : slate400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
