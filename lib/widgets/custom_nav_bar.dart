import 'package:flutter/material.dart';
import '../pages/DashboardPage.dart';
import '../pages/SettingPage.dart';
import '../pages/InsightPage.dart';
import '../pages/NotificationPage.dart';

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;

  const CustomNavBar({
    super.key,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 24, top: 16, left: 16, right: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAF8).withValues(alpha: 0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(48)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C3D35).withValues(alpha: 0.06),
            offset: const Offset(0, -16),
            blurRadius: 40,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavBarItem(
            icon: Icons.home_outlined,
            label: 'Home',
            isActive: selectedIndex == 0,
            onTap: () => _navigateTo(context, 0),
          ),
          _NavBarItem(
            icon: Icons.insights,
            label: 'Insights',
            isActive: selectedIndex == 1,
            onTap: () => _navigateTo(context, 1),
          ),
          _NavBarItem(
            icon: Icons.notifications_outlined,
            label: 'Alerts',
            isActive: selectedIndex == 2,
            onTap: () => _navigateTo(context, 2),
          ),
          _NavBarItem(
            icon: Icons.settings,
            label: 'Settings',
            isActive: selectedIndex == 3,
            onTap: () => _navigateTo(context, 3),
          ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, int index) {
    if (selectedIndex == index) return;

    Widget page;
    switch (index) {
      case 0:
        page = const DashboardPage();
        break;
      case 1:
        page = const InsightPage();
        break;
      case 2:
        page = const NotificationPage();
        break;
      case 3:
        page = const SettingPage();
        break;
      default:
        return;
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: isActive
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFD3E7DC), // secondary-container (active bg)
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: const Color(0xFF2C3D35)), // Active text color
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2C3D35),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: const Color(0xFF414844)),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF414844),
                  ),
                ),
              ],
            ),
    );
  }
}
