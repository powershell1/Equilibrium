import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'OutletDetailPage.dart';

class ZoneDetailPage extends StatefulWidget {
  final String zoneName;

  const ZoneDetailPage({super.key, required this.zoneName});

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
  bool isEspressoOn = true;
  bool isFridgeOn = true;
  bool isMicrowaveOn = false;
  bool isBlenderOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                         BoxShadow(
                          color: Color.fromRGBO(90, 125, 108, 0.08),
                          offset: Offset(0, 12),
                          blurRadius: 32,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, size: 24, color: slate900),
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "${widget.zoneName} HEMS Box",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: slate900,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40), // Balance the back button space
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
                                        text: "850W",
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: slate900,
                                        ),
                                      ),
                                      TextSpan(
                                        text: " / 1800W",
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
                                Container(
                                  height: 10,
                                  width: constraints.maxWidth * 0.47,
                                  decoration: BoxDecoration(
                                    color: primary,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                              ],
                            );
                          }
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "47% Capacity",
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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          "4 Active",
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
                    childAspectRatio: 1.0, // Square cards
                    children: [
                       _buildOutletCard(
                        icon: Icons.coffee_maker,
                        name: "Espresso Machine",
                        value: "450W",
                        isOn: isEspressoOn,
                        onToggle: () => setState(() => isEspressoOn = !isEspressoOn),
                        onCardTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OutletDetailPage(
                                outletName: "Espresso Machine",
                                currentWattage: "450W",
                                initialStatus: isEspressoOn,
                              ),
                            ),
                          );
                          if (result != null && result is bool) {
                            setState(() {
                              isEspressoOn = result;
                            });
                          }
                        },
                       ),
                       _buildOutletCard(
                        icon: Icons.kitchen, // Smart Fridge
                        name: "Smart Fridge",
                        value: "200W",
                        isOn: isFridgeOn,
                         onToggle: () => setState(() => isFridgeOn = !isFridgeOn),
                         onCardTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OutletDetailPage(
                                outletName: "Smart Fridge",
                                currentWattage: "200W",
                                initialStatus: isFridgeOn,
                              ),
                            ),
                          );
                          if (result != null && result is bool) {
                            setState(() {
                              isFridgeOn = result;
                            });
                          }
                         },
                       ),
                       _buildOutletCard(
                        icon: Icons.microwave,
                        name: "Microwave",
                        value: "Standby",
                        isOn: isMicrowaveOn,
                         onToggle: () => setState(() => isMicrowaveOn = !isMicrowaveOn),
                         onCardTap: () {},
                       ),
                       _buildOutletCard(
                        icon: Icons.blender,
                        name: "Blender",
                        value: "Off",
                        isOn: isBlenderOn,
                         onToggle: () => setState(() => isBlenderOn = !isBlenderOn),
                         onCardTap: () {},
                       ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutletCard({
    required IconData icon,
    required String name,
    required String value,
    required bool isOn,
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
                   color: isOn ? primary : const Color(0xFFE2E8F0), // slate-200
                   shape: BoxShape.circle,
                   boxShadow: isOn ? [
                      BoxShadow(
                       color: primary.withValues(alpha: 0.6),
                       blurRadius: 8,
                     )
                   ] : [],
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
                  color: isMicrowaveOn && name == "Microwave" ? slate900 : slate900, // Just using logic to match potential slight variants
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
