import 'package:equilibrium/widgets/custom_nav_bar.dart';
import 'dart:ui';
import 'package:equilibrium/function/APIHandler.dart';
import 'package:equilibrium/pages/DashboardPage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Colors from the design
  static const Color primaryColor = Color(0xFF5A7D6C);
  static const Color sage100 = Color(0xFFE4EBE7);
  static const Color sage400 = Color(0xFF7A9F8D);
  static const Color backgroundLight = Color(0xFFF9FAF8);
  static const Color backgroundDark = Color(0xFF112119);


  @override
  Widget build(BuildContext context) {
    // Determine screen size for responsive layout
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final backgroundColor = isDark ? backgroundDark : backgroundLight;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B); // Slate 800/900
    final secondaryTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B); // Slate 400/500
    
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Background Blobs
          Align(
             alignment: Alignment.bottomLeft,
             child: FractionallySizedBox(
               widthFactor: 0.5,
               heightFactor: 0.5,
               child: Transform.translate(
                 offset: const Offset(-80, 80),
                 child: Container(
                   decoration: BoxDecoration(
                     color: primaryColor.withValues(alpha: 0.05),
                     shape: BoxShape.circle,
                   ),
                   child: BackdropFilter(
                     filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                     child: Container(color: Colors.transparent),
                   ),
                 ),
               ),
             ),
          ),
          Align(
             alignment: Alignment.topRight,
             child: FractionallySizedBox(
               widthFactor: 0.6,
               heightFactor: 0.6,
               child: Transform.translate(
                 offset: const Offset(80, -80),
                 child: Container(
                   decoration: BoxDecoration(
                     color: primaryColor.withValues(alpha: 0.1),
                     shape: BoxShape.circle,
                   ),
                   child: BackdropFilter(
                     filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                     child: Container(color: Colors.transparent),
                   ),
                 ),
               ),
             ),
          ),

          // Main Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 120), // Added bottom padding
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo Header
                    _buildLogoHeader(isDark),

                    const SizedBox(height: 5),
                    
                    // Welcome Text
                    Text(
                      "Welcome Back",
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Enter your credentials to manage your sustainable home.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        color: secondaryTextColor,
                        height: 1.5,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Login Form
                    _buildLoginForm(isDark, textColor, secondaryTextColor),

                    /*
                    const SizedBox(height: 40),
                    
                    // Alternative Sign In
                    _buildDivider(isDark),
                    
                    const SizedBox(height: 32),
                    
                    // Social Buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildSocialButton(
                            icon: _buildGoogleIcon(),
                            label: "", // Icon only in design
                            isDark: isDark,
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSocialButton(
                            icon: Icon(Icons.apple, color: isDark ? Colors.white : Colors.black),
                            label: "Apple",
                            isDark: isDark,
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 48),

                    // Footer
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: secondaryTextColor,
                        ),
                        children: [
                          const TextSpan(text: "New to HEMS? "),
                          TextSpan(
                            text: "Create Account",
                            style: GoogleFonts.plusJakartaSans(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()..onTap = () {},
                          ),
                        ],
                      ),
                    ),

                     */
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoHeader(bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.eco, // Material 'eco' icon
            color: primaryColor,
            size: 40,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Green Sight",
          style: GoogleFonts.outfit(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            color: isDark ? Colors.white : const Color(0xFF0F172A), // Slate 900
          ),
        ),
      ],
    );
  }
  
  Widget _buildLoginForm(bool isDark, Color textColor, Color secondaryTextColor) {
    final inputFillColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : sage100;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Email Field
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(
            "Password",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor.withValues(alpha: 0.8),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: inputFillColor,
            borderRadius: BorderRadius.circular(24), // rounded-3xl approx
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.08),
                blurRadius: 30,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: TextField(
            controller: _emailController,
            style: GoogleFonts.plusJakartaSans(color: textColor),
            decoration: InputDecoration(
              hintText: "hello@example.com",
              hintStyle: TextStyle(color: secondaryTextColor.withValues(alpha: 0.5)),
              prefixIcon: Icon(Icons.mail_outline, color: sage400),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Password Field
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Password",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor.withValues(alpha: 0.8),
                ),
              ),
              InkWell(
                onTap: () {},
                child: Text(
                  "Forgot Password?",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: inputFillColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor),
             boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.08),
                blurRadius: 30,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: TextField(
            controller: _passwordController,
            obscureText: true,
            style: GoogleFonts.plusJakartaSans(color: textColor),
            decoration: InputDecoration(
              hintText: "••••••••",
              hintStyle: TextStyle(color: secondaryTextColor.withValues(alpha: 0.5)),
              prefixIcon: Icon(Icons.lock_outline, color: sage400),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            ),
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Submit Button
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: () async {
               // Handle Login logic
                final email = _emailController.text.trim();
                final password = _passwordController.text.trim();
                
                LoginResponse response = await apiHandler.login(email, password);
                
                if (context.mounted) {
                  if (response.success) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const DashboardPage()),
                    );
                  } else {
                    // Show error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Login failed. Please check your credentials.")),
                    );
                  }
                }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              shadowColor: Colors.transparent,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Sign In",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
