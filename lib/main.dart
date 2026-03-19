import 'package:equilibrium/pages/PairingPage.dart';
import 'package:flutter/material.dart';
import 'pages/DashboardPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Equilibrium',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1BBB6E)),
        useMaterial3: true,
      ),
      home: const DashboardPage(),
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
