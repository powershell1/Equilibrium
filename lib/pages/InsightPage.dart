import 'package:equilibrium/widgets/custom_nav_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InsightPage extends StatefulWidget {
  const InsightPage({super.key});

  @override
  State<InsightPage> createState() => _InsightPageState();
}

class _InsightPageState extends State<InsightPage> {
  // Define colors from HTML design
  static const Color primary = Color(0xFF5A7D6C);
  static const Color backgroundLight = Color(0xFFF9FAF8);
  // static const Color backgroundDark = Color(0xFF112119);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textMain = Color(0xFF2C3D35);
  static const Color muted = Color(0xFF9CAFA4);
  static const Color accent = Color(0xFF84A9C0);
  static const Color warning = Color(0xFFD68A7C);

  String _selectedTimeframe = 'Week';

  // Mock Data for graphs
  final List<double> dailyUsage = [6.2, 4.5, 7.5, 8.5, 2.0, 1.5, 1.0];
  final int currentDayIndex = 3; // Thursday

  double get totalWeeklyUsage {
    double sum = 0;
    for (int i = 0; i <= currentDayIndex; i++) {
        sum += dailyUsage[i];
    }
    return sum;
  }

  List<FlSpot> get cumulativeSpots {
    double sum = 0;
    List<FlSpot> spots = [];
    // Only calculate for days up to current day (Thursday)
    for (int i = 0; i <= currentDayIndex; i++) {
      sum += dailyUsage[i];
      spots.add(FlSpot(i.toDouble(), sum));
    }
    return spots;
  }

  List<FlSpot> get regressionSpots {
    // Calculate regression based on known data (up to Thursday)
    final spots = cumulativeSpots;
    int n = spots.length;
    if (n == 0) return [];
    
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
    
    for (var spot in spots) {
        sumX += spot.x;
        sumY += spot.y;
        sumXY += spot.x * spot.y;
        sumX2 += spot.x * spot.x;
    }

    double slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    double intercept = (sumY - slope * sumX) / n;

    // Return line spanning the full week (0 to 6)
    return [
      FlSpot(0, intercept),
      FlSpot(6, slope * 6 + intercept),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120), // Padding for navbar
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Energy Insights",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: textMain,
                              height: 1.2,
                              letterSpacing: -0.02 * 24, // -0.02em
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tab Selector
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                    child: _buildTimeframeSelector(),
                  ),

                  // Summary Metric
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        Text(
                          "TOTAL USAGE THIS WEEK",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14, // text-sm
                            fontWeight: FontWeight.w500,
                            color: muted,
                            letterSpacing: 0.05 * 14, // 0.05em
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              totalWeeklyUsage.toStringAsFixed(1),
                              style: GoogleFonts.outfit(
                                fontSize: 36,
                                fontWeight: FontWeight.w600,
                                color: textMain,
                                letterSpacing: -0.02 * 36,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "kWh",
                              style: GoogleFonts.outfit(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                color: muted,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.eco, color: accent, size: 30),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8EFEA),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.arrow_downward, color: primary, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                "14% below average",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Bar Chart Area
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(24), // rounded-2xl
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF5A7D6C).withValues(alpha: 0.08),
                            offset: const Offset(0, 12),
                            blurRadius: 32,
                            // spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: _buildBarChart(),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Cumulative Chart Area
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Cumulative Trend",
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: textMain,
                            letterSpacing: -0.02 * 20,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 300,
                          padding: const EdgeInsets.fromLTRB(16, 24, 24, 16),
                          decoration: BoxDecoration(
                            color: surface,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF5A7D6C).withValues(alpha: 0.08),
                                offset: const Offset(0, 12),
                                blurRadius: 32,
                              ),
                            ],
                          ),
                          child: _buildCumulativeChart(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Impact Cards Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      "Your Impact",
                      style: GoogleFonts.outfit(
                        fontSize: 20, // text-xl
                        fontWeight: FontWeight.w600,
                        color: textMain,
                        letterSpacing: -0.02 * 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Impact Cards Grid
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Column(
                          children: [
                            _buildSavingsCard(),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: CustomNavBar(selectedIndex: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeframeSelector() {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5A7D6C).withValues(alpha: 0.08),
            offset: const Offset(0, 12),
            blurRadius: 32,
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTimeframeTab("Week"),
          _buildTimeframeTab("Month"),
          _buildTimeframeTab("Year"),
        ],
      ),
    );
  }

  Widget _buildTimeframeTab(String label) {
    bool isSelected = _selectedTimeframe == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTimeframe = label;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? primary : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : muted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCumulativeChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 10,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: muted.withValues(alpha: 0.2),
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                if (value.toInt() >= 0 && value.toInt() < days.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      days[value.toInt()],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: muted,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 10,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: muted,
                  ),
                  textAlign: TextAlign.left,
                );
              },
              reservedSize: 42,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        minX: 0,
        maxX: 6,
        minY: 0,
        lineBarsData: [
           // Regression Line
          LineChartBarData(
            spots: regressionSpots,
            isCurved: false,
            color: warning,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            dashArray: [5, 5],
            belowBarData: BarAreaData(show: false),
          ),
          // Cumulative Line
          LineChartBarData(
            spots: cumulativeSpots,
            isCurved: true,
            color: primary,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: surface,
                  strokeWidth: 2,
                  strokeColor: primary,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: primary.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return SizedBox(
      height: 192, // h-48 = 12rem = 192px
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Y-axis labels
          SizedBox(
            width: 20,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("10", style: _axisLabelStyle()),
                Text("5", style: _axisLabelStyle()),
                Text("0", style: _axisLabelStyle()),
              ],
            ),
          ),
          const SizedBox(width: 8),
          
          Expanded(
            child: Stack(
              children: [
                // Grid Lines
                 Column(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     _buildDashedLine(),
                     _buildDashedLine(),
                     _buildSolidLine(),
                   ],
                 ),
                 
                // Bars
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 20), // Lift up slightly to match axis
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildBar("Mon", 0.60, "6.2"),
                      _buildBar("Tue", 0.45, null),
                      _buildBar("Wed", 0.75, null),
                      _buildBar("Thu", 0.85, "8.5", isHighlighted: true),
                      _buildBar("Fri", 0.20, null, isProjected: true),
                      _buildBar("Sat", 0.15, null, isProjected: true),
                      _buildBar("Sun", 0.10, null, isProjected: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _axisLabelStyle() {
    return GoogleFonts.plusJakartaSans(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: muted,
    );
  }

  Widget _buildDashedLine() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: List.generate(
            constraints.maxWidth ~/ 10,
            (index) => Expanded(
              child: Container(
                color: index % 2 == 0 ? muted.withValues(alpha: 0.2) : Colors.transparent,
                height: 1,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSolidLine() {
    return Container(
      color: muted.withValues(alpha: 0.2),
      height: 1,
      width: double.infinity,
    );
  }

  Widget _buildBar(String day, double heightFactor, String? label, {bool isHighlighted = false, bool isProjected = false}) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (isHighlighted && label != null)
             Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5A7D6C).withValues(alpha: 0.08),
                      offset: const Offset(0, 12),
                      blurRadius: 32,
                    ),
                  ],
                  border: Border.all(color: primary.withValues(alpha: 0.1)),
                ),
                child: Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: textMain,
                  ),
                ),
              ),
          if (!isHighlighted && label != null)
             Opacity(
               opacity: 0,
               child: Text(label),
             ),
          
          Flexible(
            child: Container(
              width: double.infinity,
              height: 140 * heightFactor, // Approximate bar height
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                // Projected bars are lighter/transparent
                color: isProjected 
                    ? surface 
                    : (isHighlighted ? primary : accent.withValues(alpha: isHighlighted ? 1 : 0.2)),
                border: isProjected 
                    ? Border.all(color: muted.withValues(alpha: 0.3), width: 1, style: BorderStyle.solid) // Dashed border is harder with BoxDecoration, solid is fine for now or we create custom painter
                    : null,
                borderRadius: BorderRadius.circular(8),
                boxShadow: isHighlighted
                    ? [
                         BoxShadow(
                          color: primary.withValues(alpha: 0.3),
                          offset: const Offset(0, 4),
                          blurRadius: 12,
                        ),
                      ]
                    : null,
              ),
              child: isProjected 
                  ? Center(
                      child: Icon(Icons.more_horiz, size: 12, color: muted.withValues(alpha: 0.5)),
                    ) 
                  : null, 
            ),
          ),
          const SizedBox(height: 8),
          Text(
            day,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isHighlighted ? textMain : muted,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSavingsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5A7D6C).withValues(alpha: 0.08),
            offset: const Offset(0, 12),
            blurRadius: 32,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
             Positioned(
               right: 0,
               top: 0,
               bottom: 0,
               width: 128,
               child: Container(
                 decoration: BoxDecoration(
                   gradient: LinearGradient(
                     begin: Alignment.centerRight,
                     end: Alignment.centerLeft,
                     colors: [
                       accent.withValues(alpha: 0.1),
                       accent.withValues(alpha: 0.0),
                     ],
                   ),
                 ),
               ),
             ),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFF0F4F8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.savings_outlined, color: accent, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "~450.52฿",
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textMain,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Estimated savings this week",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
