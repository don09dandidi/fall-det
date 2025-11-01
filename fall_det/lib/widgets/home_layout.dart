import 'package:flutter/material.dart';
import 'package:fall_det/widgets/sidebar.dart';
import 'package:fall_det/screens/dashboard_screen.dart';
import 'package:fall_det/screens/alerts_screen.dart';
import 'package:fall_det/screens/contacts_screen.dart';
import 'package:fall_det/screens/checking_screen.dart';
import 'package:fall_det/screens/settings_screen.dart';

class HomeLayout extends StatefulWidget {
  final int userId; // 👈 userId from login
  const HomeLayout({super.key, required this.userId});

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
      ContactsScreen(userId: widget.userId),
      CheckingScreen(userId: widget.userId),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Main content
          screens[selectedIndex],

          // Overlay when sidebar open
          if (isSidebarOpen)
            GestureDetector(
              onTap: closeSidebar,
              child: Container(color: Colors.black.withOpacity(0.5)),
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

          // Menu button (when sidebar closed)
          if (!isSidebarOpen)
            Positioned(
              left: 16,
              top: MediaQuery.of(context).padding.top + 16,
              child: Material(
                color: Colors.white,
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => setState(() => isSidebarOpen = true),
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
