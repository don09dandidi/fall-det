import 'package:flutter/material.dart';
import 'package:fall_det/widgets/sidebar.dart';
import 'package:fall_det/screens/dashboard_screen.dart';
import 'package:fall_det/screens/alerts_screen.dart';
import 'package:fall_det/screens/contacts_screen.dart';
import 'package:fall_det/screens/checking_screen.dart';
import 'package:fall_det/screens/settings_screen.dart';

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
  bool isSidebarOpen = true;

  void closeSidebar() {
    setState(() => isSidebarOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const DashboardScreen(),
      const AlertsScreen(),
      const ContactsScreen(),
      const CheckingScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Main content (always full width)
          screens[selectedIndex],

          // Dark overlay when sidebar is open
          if (isSidebarOpen)
            GestureDetector(
              onTap: closeSidebar,
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),

          // Sidebar overlay
          if (isSidebarOpen)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: SideBar(
                selectedIndex: selectedIndex,
                onItemSelected: (index) {
                  setState(() => selectedIndex = index);
                },
                onClose: closeSidebar,
              ),
            ),

          // Hamburger menu button (when sidebar is closed)
          if (!isSidebarOpen)
            Positioned(
              left: 16,
              top: MediaQuery.of(context).padding.top + 16,
              child: Material(
                color: Colors.white,
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () {
                    setState(() => isSidebarOpen = true);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: const Icon(
                      Icons.menu,
                      color: Colors.blueAccent,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}