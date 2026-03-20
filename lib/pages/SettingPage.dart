import 'package:equilibrium/widgets/custom_nav_bar.dart';
import 'package:equilibrium/function/APIHandler.dart';
import 'package:equilibrium/pages/LoginPage.dart';
import 'package:flutter/material.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF8),
      body: Stack(
        children: [
          // Content
          SingleChildScrollView(
            padding: const EdgeInsets.only(
                top: 100, bottom: 120, left: 24, right: 24),
            child: Column(
              children: [
                const _UserProfileSection(),
                const SizedBox(height: 24),
                
                // Account Section
                _SectionContainer(
                  title: 'ACCOUNT',
                  children: [
                    _SettingsItem(
                      icon: Icons.person_outline,
                      title: 'Profile Information',
                      onTap: () {
                        apiHandler.getMeasurements(MeasurementFrequency.weekly);
                      },
                    ),
                    _SettingsItem(
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // App Settings Section
                _SectionContainer(
                  title: 'APP SETTINGS',
                  children: [
                    _SettingsItem(
                      icon: Icons.straighten_outlined,
                      title: 'Units',
                      trailing: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFE7E8E6), // surface-container-high
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF426454), // primary
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Text(
                                'kWh',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              child: const Text(
                                'MJ',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF414844),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _SettingsItem(
                      icon: Icons.palette_outlined,
                      title: 'Appearance',
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Light',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF414844),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right,
                              color: Color(0xFFC1C8C2)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Logout Button
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 16),
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      // Clear auth token
                      await apiHandler.clearAuthToken();
                      
                      // Navigate to LoginPage
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                      backgroundColor:
                          const Color(0xFF986A68).withValues(alpha: 0.1),
                      side: BorderSide(
                          color: const Color(0xFF986A68).withValues(alpha: 0.2)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.logout, color: Color(0xFF7D5250)),
                    label: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Color(0xFF7D5250),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // App Version
                const Text(
                  'GREEN-SIGHT V2.4.0',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF727974), // outline
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
          ),
          
          // Custom Header
          const _CustomHeader(),
          
          // Custom Bottom Navigation
          const Align(
            alignment: Alignment.bottomCenter,
            child: CustomNavBar(selectedIndex: 3),
          ),
        ],
      ),
    );
  }
}

class _CustomHeader extends StatelessWidget {
  const _CustomHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAF8).withValues(alpha: 0.7),
        // Simplified backdrop filter simulation if needed, but opacity works well for simple overlay
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  'Settings',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF426454),
                    letterSpacing: -0.5,
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

class _UserProfileSection extends StatelessWidget {
  const _UserProfileSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2C3D35).withValues(alpha: 0.06),
                    offset: const Offset(0, 16),
                    blurRadius: 40,
                  ),
                ],
              ),
               // Replace with NetworkImage if needed, using placeholder for now
              child: ClipOval(
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuB9_BbjpeB2ke-N6Hg4wn3ZPjyPLv8air7kYsUGdkmMBCRUaoL5XwMYVsWnFYsceA6PUu9oBI3AEtWLfAnQhDg2jSMt-uSxcCO-M0T4hVJgjcigdplFmrl0WS8DDrCk-5KuCYUzrDikrvbv3-FsYGV4Ao0QnsATDHlzBNJGkiKXyfx9TvpNy82B886g3vZydFd_gVhYBUifcUj0YPLrqN4pDyP70uUzHBRIE---a3s9AzQxwhL4M7gQTkSE4NEzJWbGGrFCajC7sWQ',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.person, size: 48, color: Colors.grey),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF426454), // primary
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: const Icon(Icons.edit, size: 14, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Alex Green',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF191C1B),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'alex@example.com',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF414844),
          ),
        ),
      ],
    );
  }
}

class _SectionContainer extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionContainer({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F2), // surface-container-low
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF426454), // primary
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF414844)),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF191C1B),
              ),
            ),
            const Spacer(),
            if (trailing != null)
              trailing!
            else
              const Icon(Icons.chevron_right, color: Color(0xFFC1C8C2)),
          ],
        ),
      ),
    );
  }
}


