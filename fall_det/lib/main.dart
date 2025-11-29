import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/contacts_screen.dart';
import 'screens/checking_screen.dart';  // Your check-in screen
import 'screens/support_screen.dart';  // NEW - Support screen
import 'screens/settings_screen.dart';  // Your settings screen
import 'widgets/sidebar.dart';

class MainScreen extends StatefulWidget {
  final int userId;
  const MainScreen({super.key, required this.userId});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    
    // Initialize screens list
    _screens = [
      const DashboardScreen(),                    // Index 0 - Monitorizare
      AlertsScreen(userId: widget.userId),        // Index 1 - Alerte
      ContactsScreen(userId: widget.userId),      // Index 2 - Contacte
      CheckingScreen(userId: widget.userId),      // Index 3 - Check-in
      const SupportScreen(),                      // Index 4 - Suport (NEW)
      const SettingsScreen(),                     // Index 5 - Setări
    ];
    
    // Optional: Initialize push notifications here
    // NotificationService.initialize(widget.userId, "http://YOUR_IP:5000");
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.blueAccent),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          _getScreenTitle(_selectedIndex),
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      drawer: SideBar(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() => _selectedIndex = index);
          Navigator.pop(context); // Close drawer
        },
        onClose: () => Navigator.pop(context),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
    );
  }

  String _getScreenTitle(int index) {
    switch (index) {
      case 0:
        return 'Monitorizare';
      case 1:
        return 'Alerte';
      case 2:
        return 'Contacte';
      case 3:
        return 'Check-in';
      case 4:
        return 'Suport';
      case 5:
        return 'Setări';
      default:
        return 'SafeGuard';
    }
  }
}