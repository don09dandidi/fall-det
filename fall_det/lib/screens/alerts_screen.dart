import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  String selectedTab = "Toate";

  final List<Map<String, dynamic>> alerts = [
    {
      "title": "Update Sistem",
      "description": "Sistem actualizat la versiunea 2.1.0",
      "priority": "Scăzut",
      "status": "Rezolvat",
      "category": "Sistem",
      "time": "13:32",
      "date": "17 oct 2025",
    },
    {
      "title": "Check-in Ratat",
      "description": "Check-in ratat - 2 ore întârziere",
      "priority": "Mediu",
      "status": "Confirmat",
      "category": "Dormitor Principal",
      "time": "13:32",
      "date": "17 oct 2025",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              Text(
                "Istoric Alerte",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "Monitorizați și gestionați toate alertele sistemului",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 24),

              // Summary Cards - Fixed Layout
              LayoutBuilder(
                builder: (context, constraints) {
                  // Calculate card width based on available space
                  final availableWidth = constraints.maxWidth;
                  final cardWidth =
                      (availableWidth - 24) / 3; // 3 cards with spacing

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          "Alerte Active",
                          "0",
                          Colors.redAccent,
                          Icons.warning_amber_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          "Rezolvate Azi",
                          "1",
                          Colors.green,
                          Icons.check_circle_outline,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          "Total Alerte",
                          "2",
                          Colors.blueAccent,
                          Icons.analytics_outlined,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              // Tabs - Fixed positioning issue
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      ["Toate", "Active", "Confirmate", "Rezolvate"]
                          .map(
                            (tab) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(tab),
                                selected: selectedTab == tab,
                                onSelected:
                                    (_) => setState(() => selectedTab = tab),
                                selectedColor: Colors.blueAccent,
                                backgroundColor: Colors.grey[200],
                                checkmarkColor: Colors.white,
                                labelStyle: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  color:
                                      selectedTab == tab
                                          ? Colors.white
                                          : Colors.black87,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),

              const SizedBox(height: 20),

              // Alerts list
              ...alerts.map((alert) => _buildAlertCard(alert)).toList(),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // Summary Card Widget - Fixed overflow
  Widget _buildSummaryCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // Alert Card Widget
  Widget _buildAlertCard(Map<String, dynamic> alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  alert["title"],
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    "${alert["time"]} | ${alert["date"]}",
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Description
          Text(
            alert["description"],
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),

          const SizedBox(height: 10),

          // Tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTag(
                alert["priority"],
                Colors.blue.shade100,
                Colors.blue.shade700,
              ),
              _buildTag(
                alert["status"],
                Colors.green.shade100,
                Colors.green.shade700,
              ),
              _buildTag(
                alert["category"],
                Colors.grey.shade200,
                Colors.grey.shade800,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Tag Widget
  Widget _buildTag(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: fg,
        ),
      ),
    );
  }
}
