import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class CheckingScreen extends StatefulWidget {
  final int userId;
  const CheckingScreen({super.key, required this.userId});

  @override
  State<CheckingScreen> createState() => _CheckingScreenState();
}

class _CheckingScreenState extends State<CheckingScreen> {
  final String baseUrl = "http://192.168.0.7:5000";
  List<Map<String, dynamic>> verifications = [];

  int scheduled = 0;
  int completed = 0;

  @override
  void initState() {
    super.initState();
    _fetchVerifications();
  }

  // ---------------- API METHODS ----------------

  Future<void> _fetchVerifications() async {
    final res = await http.get(Uri.parse("$baseUrl/verifications?user_id=${widget.userId}"));
    if (res.statusCode == 200) {
      setState(() {
        verifications = List<Map<String, dynamic>>.from(json.decode(res.body));
        scheduled = verifications.where((v) => v['status'] == 'scheduled').length;
        completed = verifications.where((v) => v['status'] == 'completed').length;
      });
    }
  }

  Future<void> _addVerification(String title, String date) async {
    final res = await http.post(
      Uri.parse("$baseUrl/verifications"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "title": title,
        "date": date,
        "user_id": widget.userId,
      }),
    );
    if (res.statusCode == 201) _fetchVerifications();
  }

  Future<void> _updateStatus(int id, String newStatus) async {
    final res = await http.put(
      Uri.parse("$baseUrl/verifications/$id"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"status": newStatus}),
    );
    if (res.statusCode == 200) _fetchVerifications();
  }

  Future<void> _deleteVerification(int id) async {
    final res = await http.delete(Uri.parse("$baseUrl/verifications/$id"));
    if (res.statusCode == 200) _fetchVerifications();
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              Text(
                "Verificări Periodice",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Programați și urmăriți verificările de siguranță",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 20),

              // Add button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showAddDialog,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text(
                    "Programează Verificare",
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      "Programate",
                      scheduled.toString(),
                      Icons.schedule,
                      Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoCard(
                      "Complete",
                      completed.toString(),
                      Icons.check_circle_outline,
                      Colors.green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Verification list
              if (verifications.isEmpty)
                _buildEmptyState()
              else
                Column(
                  children: verifications.map((v) => _buildVerificationCard(v)).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------ COMPONENTS ------------------

  Widget _buildVerificationCard(Map<String, dynamic> v) {
    bool isDone = v['status'] == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle : Icons.schedule,
            color: isDone ? Colors.green : Colors.blueAccent,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  v['title'] ?? "Fără titlu",
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Data: ${v['date']}",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (!isDone)
            IconButton(
              icon: const Icon(Icons.done, color: Colors.green),
              tooltip: "Marchează ca Finalizată",
              onPressed: () => _updateStatus(v['id'], 'completed'),
            ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            tooltip: "Șterge",
            onPressed: () => _deleteVerification(v['id']),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.access_time_filled, size: 48, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 20),
          Text(
            "Nicio verificare programată",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Programați verificări periodice pentru a asigura siguranța",
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _showAddDialog,
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(
              "Programează Prima Verificare",
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(title, style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54)),
        ],
      ),
    );
  }

  // ---------------- DIALOG ----------------
  void _showAddDialog() {
    final titleCtrl = TextEditingController();
    final dateCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Programează Verificare"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: "Titlu")),
            TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: "Dată (ex: 2025-11-01)")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Anulează")),
          ElevatedButton(
            onPressed: () async {
              await _addVerification(titleCtrl.text, dateCtrl.text);
              Navigator.pop(context);
            },
            child: const Text("Salvează"),
          ),
        ],
      ),
    );
  }
}
