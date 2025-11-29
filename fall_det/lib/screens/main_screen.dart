import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'alerts_screen.dart';
import 'contacts_screen.dart';
import 'checking_screen.dart';
import 'support_screen.dart';
import 'settings_screen.dart';
import '../widgets/sidebar.dart';
import '../services/notification_service.dart';

class MainScreen extends StatefulWidget {
  final int userId;
  const MainScreen({super.key, required this.userId});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _screens;
  
  // Update this with your actual backend IP
  final String baseUrl = "http://192.168.0.7:5000";

  @override
  void initState() {
    super.initState();
    
    // Initialize screens list
    _screens = [
      const DashboardScreen(),                    // Index 0 - Monitorizare
      AlertsScreen(userId: widget.userId),        // Index 1 - Alerte
      ContactsScreen(userId: widget.userId),      // Index 2 - Contacte
      CheckingScreen(userId: widget.userId),      // Index 3 - Check-in
      const SupportScreen(),                      // Index 4 - Suport
      const SettingsScreen(),                     // Index 5 - Setări
    ];
    
    // Initialize push notifications
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      await NotificationService.initialize(widget.userId, baseUrl);
      print('Notifications initialized successfully');
    } catch (e) {
      print('Error initializing notifications: $e');
    }
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
        actions: [
          // Optional: Add a test notification button
          // IconButton(
          //   icon: const Icon(Icons.notifications, color: Colors.blueAccent),
          //   onPressed: () {
          //     NotificationService.sendTestNotification();
          //   },
          // ),
        ],
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