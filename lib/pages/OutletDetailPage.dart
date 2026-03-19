import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OutletDetailPage extends StatefulWidget {
  final String outletName;
  final String currentWattage;
  final bool initialStatus;

  const OutletDetailPage({
    super.key,
    required this.outletName,
    required this.currentWattage,
    required this.initialStatus,
  });

  @override
  State<OutletDetailPage> createState() => _OutletDetailPageState();
}

class _OutletDetailPageState extends State<OutletDetailPage> {
  // Colors from the design
  static const Color primary = Color(0xFF5A7D6C); // Sage Green
  static const Color primaryLight = Color(0xFFE8EFEA);
  static const Color backgroundLight = Color(0xFFF9FAF8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textMain = Color(0xFF2C3D35);
  static const Color muted = Color(0xFF9CAFA4);
  static const Color accent = Color(0xFF84A9C0);

  late bool isOn;
  bool routine1 = true;
  bool routine2 = true;

  @override
  void initState() {
    super.initState();
    isOn = widget.initialStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCircleButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.pop(context, isOn),
                  ),
                  Text(
                    widget.outletName,
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: textMain,
                      letterSpacing: -0.5,
                    ),
                  ),
                  _buildCircleButton(
                    icon: Icons.more_vert,
                    onTap: () {},
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 32),
                children: [
                  // Power Ring Section
                  Padding(
                    padding: const EdgeInsets.only(top: 32, bottom: 48),
                    child: Column(
                      children: [
                        // Power Ring
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isOn = !isOn;
                            });
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer Glow (Active)
                              if (isOn)
                                Container(
                                  width: 210,
                                  height: 210,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: primary.withValues(alpha: 0.2),
                                  ),
                                ),
                              // Ring Border
                              Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: primary,
                                    width: 8,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color.fromRGBO(90, 125, 108, 0.3),
                                      blurRadius: 30,
                                      spreadRadius: 0,
                                    )
                                  ],
                                ),
                              ),
                              // Inner Circle
                              Container(
                                width: 176,
                                height: 176,
                                decoration: const BoxDecoration(
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
                                child: Icon(
                                  Icons.power_settings_new,
                                  size: 64,
                                  color: isOn ? primary : muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Status Text
                        Text(
                          isOn ? widget.currentWattage : "0W",
                          style: GoogleFonts.outfit(
                            fontSize: 36,
                            fontWeight: FontWeight.w600,
                            color: textMain,
                            letterSpacing: -1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isOn ? "CURRENTLY ACTIVE" : "OFFLINE",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isOn ? primary : muted,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Energy Usage Chart Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Today's Usage",
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: textMain,
                              ),
                            ),
                            Text(
                              "1.2 kWh Total",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: muted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 200,
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
                          child: Stack(
                            children: [
                              // Grid Lines
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: List.generate(
                                  5,
                                  (index) => Container(
                                    height: 1,
                                    color: muted.withValues(alpha: 0.1),
                                    margin: EdgeInsets.only(
                                      top: index == 0 ? 20 : 0,
                                      bottom: index == 4 ? 40 : 0,
                                      left: 20,
                                      right: 20,
                                    ),
                                  ),
                                ),
                              ),
                              // Chart Area
                              Positioned(
                                left: 20,
                                right: 20,
                                bottom: 40,
                                top: 40,
                                child: ClipPath(
                                  clipper: ChartClipper(),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          accent.withValues(alpha: 0.2),
                                          accent.withValues(alpha: 0.0),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Chart Line Border (Top of clip) - Approximated visually or just let the area be enough
                              // X-Axis Labels
                              Positioned(
                                bottom: 12,
                                left: 20,
                                right: 20,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildAxisLabel("6 AM"),
                                    _buildAxisLabel("12 PM"),
                                    _buildAxisLabel("6 PM"),
                                    _buildAxisLabel("Now"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Routines Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Routines",
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: textMain,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildRoutineItem(
                          icon: Icons.coffee_maker,
                          title: "Morning Brew",
                          subtitle: "Turn ON • 7:00 AM",
                          isOn: routine1,
                          onToggle: (v) => setState(() => routine1 = v),
                          iconBg: primaryLight,
                          iconColor: primary,
                        ),
                        const SizedBox(height: 12),
                        _buildRoutineItem(
                          icon: Icons.power_off,
                          title: "Auto Shutoff",
                          subtitle: "Turn OFF • After 2hrs",
                          isOn: routine2,
                          onToggle: (v) => setState(() => routine2 = v),
                          iconBg: backgroundLight,
                          iconColor: muted,
                        ),
                        const SizedBox(height: 16),
                        // Add Routine Button
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: muted.withValues(alpha: 0.3),
                              width: 2,
                              style: BorderStyle.none, // Dashed border needs CustomPaint or specific package, simplfying with dotted logic or different style
                            ),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: InkWell(
                            onTap: () {},
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                               height: 56,
                               decoration: BoxDecoration(
                                 borderRadius: BorderRadius.circular(999),
                                 border: Border.all(
                                   color: muted.withValues(alpha: 0.3),
                                   style: BorderStyle.solid, // Using solid for simplicity
                                   width: 2,
                                 ),
                               ),
                               child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add, color: muted, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Add Routine",
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildCircleButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 40,
        height: 40, // Keeping touch target slightly larger visually/physically
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: textMain),
      ),
    );
  }

  Widget _buildAxisLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: muted,
      ),
    );
  }

  Widget _buildRoutineItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isOn,
    required ValueChanged<bool> onToggle,
    required Color iconBg,
    required Color iconColor,
  }) {
    return Container(
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
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textMain,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: muted,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isOn,
            onChanged: onToggle,
            activeThumbColor: primary,
            activeTrackColor: primaryLight,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }
}

class ChartClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height);
    
    // clip-path: polygon(0 40%, 10% 35%, 20% 45%, 30% 20%, 40% 25%, 50% 10%, 60% 30%, 70% 50%, 80% 40%, 90% 60%, 100% 50%, 100% 100%, 0 100%);
    // Mapping percentages to width/height
    // 0 40%
    path.lineTo(0, size.height * 0.40);
    path.lineTo(size.width * 0.10, size.height * 0.35);
    path.lineTo(size.width * 0.20, size.height * 0.45);
    path.lineTo(size.width * 0.30, size.height * 0.20);
    path.lineTo(size.width * 0.40, size.height * 0.25);
    path.lineTo(size.width * 0.50, size.height * 0.10);
    path.lineTo(size.width * 0.60, size.height * 0.30);
    path.lineTo(size.width * 0.70, size.height * 0.50);
    path.lineTo(size.width * 0.80, size.height * 0.40);
    path.lineTo(size.width * 0.90, size.height * 0.60);
    path.lineTo(size.width * 1.00, size.height * 0.50);
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}


