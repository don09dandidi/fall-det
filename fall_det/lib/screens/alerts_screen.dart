import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class AlertsScreen extends StatefulWidget {
  final int userId;
  const AlertsScreen({super.key, required this.userId});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  String selectedTab = "Toate";
  List<Map<String, dynamic>> alerts = [];
  bool isLoading = true;
  int activeCount = 0;
  int resolvedTodayCount = 0;
  int totalCount = 0;
  Timer? _refreshTimer;

  final String baseUrl = "http://YOUR_IP:5000"; // Replace with your backend IP

  @override
  void initState() {
    super.initState();
    fetchAlerts();
    fetchStats();
    // Auto-refresh every 5 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      fetchAlerts();
      fetchStats();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchAlerts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/alerts?user_id=${widget.userId}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          alerts = data.map((alert) => alert as Map<String, dynamic>).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching alerts: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/alerts/stats?user_id=${widget.userId}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          activeCount = data['active'];
          resolvedTodayCount = data['resolved_today'];
          totalCount = data['total'];
        });
      }
    } catch (e) {
      print('Error fetching stats: $e');
    }
  }

  Future<void> confirmAlert(int alertId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/alerts/$alertId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': 'Confirmat'}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alertă confirmată!')),
        );
        fetchAlerts();
        fetchStats();
      }
    } catch (e) {
      print('Error confirming alert: $e');
    }
  }

  Future<void> resolveAlert(int alertId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/alerts/$alertId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': 'Rezolvat'}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alertă rezolvată!')),
        );
        fetchAlerts();
        fetchStats();
      }
    } catch (e) {
      print('Error resolving alert: $e');
    }
  }

  List<Map<String, dynamic>> getFilteredAlerts() {
    if (selectedTab == "Toate") return alerts;
    if (selectedTab == "Active") {
      return alerts.where((a) => a['status'] == 'Activ').toList();
    }
    if (selectedTab == "Confirmate") {
      return alerts.where((a) => a['status'] == 'Confirmat').toList();
    }
    if (selectedTab == "Rezolvate") {
      return alerts.where((a) => a['status'] == 'Rezolvat').toList();
    }
    return alerts;
  }

  @override
  Widget build(BuildContext context) {
    final filteredAlerts = getFilteredAlerts();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await fetchAlerts();
            await fetchStats();
          },
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  physics: const AlwaysScrollableScrollPhysics(),
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

                      // Summary Cards
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              "Alerte Active",
                              "$activeCount",
                              Colors.redAccent,
                              Icons.warning_amber_rounded,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSummaryCard(
                              "Rezolvate Azi",
                              "$resolvedTodayCount",
                              Colors.green,
                              Icons.check_circle_outline,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSummaryCard(
                              "Total Alerte",
                              "$totalCount",
                              Colors.blueAccent,
                              Icons.analytics_outlined,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Tabs
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: ["Toate", "Active", "Confirmate", "Rezolvate"]
                              .map(
                                (tab) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: FilterChip(
                                    label: Text(tab),
                                    selected: selectedTab == tab,
                                    onSelected: (_) =>
                                        setState(() => selectedTab = tab),
                                    selectedColor: Colors.blueAccent,
                                    backgroundColor: Colors.grey[200],
                                    checkmarkColor: Colors.white,
                                    labelStyle: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                      color: selectedTab == tab
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
                      if (filteredAlerts.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            children: [
                              Icon(Icons.check_circle_outline,
                                  size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                "Nu există alerte",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ...filteredAlerts
                            .map((alert) => _buildAlertCard(alert))
                            .toList(),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  // Summary Card Widget
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

  // Alert Card Widget with Confirmation Button
  Widget _buildAlertCard(Map<String, dynamic> alert) {
    final String status = alert["status"];
    final bool isActive = status == "Activ";
    final bool isConfirmed = status == "Confirmat";

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isActive
            ? Border.all(color: Colors.redAccent, width: 2)
            : null,
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
                child: Row(
                  children: [
                    if (isActive)
                      const Icon(Icons.warning_amber_rounded,
                          color: Colors.redAccent, size: 20),
                    if (isActive) const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        alert["title"],
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isActive ? Colors.redAccent : Colors.black,
                        ),
                      ),
                    ),
                  ],
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
                _getPriorityColor(alert["priority"]).withOpacity(0.2),
                _getPriorityColor(alert["priority"]),
              ),
              _buildTag(
                alert["status"],
                _getStatusColor(alert["status"]).withOpacity(0.2),
                _getStatusColor(alert["status"]),
              ),
              _buildTag(
                alert["category"],
                Colors.grey.shade200,
                Colors.grey.shade800,
              ),
            ],
          ),

          // Action Buttons for Active/Confirmed alerts
          if (isActive || isConfirmed) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (isActive)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => confirmAlert(alert["id"]),
                      icon: const Icon(Icons.check, size: 18),
                      label: Text(
                        "Confirmă",
                        style: GoogleFonts.poppins(fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                if (isActive) const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => resolveAlert(alert["id"]),
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: Text(
                      "Rezolvă",
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
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

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case "Ridicat":
        return Colors.red;
      case "Mediu":
        return Colors.orange;
      case "Scăzut":
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Activ":
        return Colors.red;
      case "Confirmat":
        return Colors.orange;
      case "Rezolvat":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}