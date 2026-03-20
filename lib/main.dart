import 'package:equilibrium/function/APIHandler.dart';
import 'package:equilibrium/pages/DashboardPage.dart';
import 'package:equilibrium/pages/LoginPage.dart';
import 'package:equilibrium/pages/PairingPage.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load the saved auth token when the app starts
  await apiHandler.loadAuthToken();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Green Sight',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1BBB6E)),
        useMaterial3: true,
      ),
      // Navigate to LoginPage if no auth token, otherwise go to DashboardPage
      home: apiHandler.authToken.isNotEmpty 
        ? const DashboardPage() 
        : const LoginPage(),
    );
  }
}

class DebugPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      body: SafeArea(
        child: ElevatedButton(
          child: Text("Click Me"),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) => const PairingPage(),
              ),
            );
            // Action to perform when the button is pressed
            print("Button pressed!");
          },
        ),
      ),
    );
  }
}
