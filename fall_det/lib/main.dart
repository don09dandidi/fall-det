import 'package:flutter/material.dart';
import 'package:fall_det/widgets/sidebar.dart';
import 'package:fall_det/screens/dashboard_screen.dart';

void main() {
  runApp(const SafeGuardApp());
}

class SafeGuardApp extends StatelessWidget {
  const SafeGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeGuard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        useMaterial3: true,
      ),
      home: const HomeLayout(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeLayout extends StatefulWidget {
  const HomeLayout({super.key});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const DashboardScreen(),
      const Center(child: Text("Alerte")),
      const Center(child: Text("Contacte")),
      const Center(child: Text("Check-in")),
      const Center(child: Text("Setări")),
    ];

    return Scaffold(
      body: Row(
        children: [
          SideBar(
            selectedIndex: selectedIndex,
            onItemSelected: (index) {
              setState(() => selectedIndex = index);
            },
          ),
          Expanded(child: screens[selectedIndex]),
        ],
      ),
    );
  }
}
