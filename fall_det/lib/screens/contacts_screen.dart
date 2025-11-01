import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class ContactsScreen extends StatefulWidget {
  final int userId; // Pass from login (user['id'])
  const ContactsScreen({super.key, required this.userId});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final String baseUrl = "http://192.168.0.7:5000"; // your Flask backend
  List<Map<String, dynamic>> contacts = [];

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  // ------------------ API CALLS ------------------
  Future<void> _fetchContacts() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/contacts?user_id=${widget.userId}"),
      );
      if (res.statusCode == 200) {
        setState(() {
          contacts = List<Map<String, dynamic>>.from(json.decode(res.body));
        });
      }
    } catch (e) {
      debugPrint("Error fetching contacts: $e");
    }
  }

  Future<void> _addContact(String name, String role, String phone) async {
    final res = await http.post(
      Uri.parse("$baseUrl/contacts"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "name": name,
        "role": role,
        "phone": phone,
        "rating": 5,
        "active": true,
        "user_id": widget.userId,
      }),
    );
    if (res.statusCode == 201) _fetchContacts();
  }

  Future<void> _updateContact(
    int id,
    String name,
    String role,
    String phone,
  ) async {
    final res = await http.put(
      Uri.parse("$baseUrl/contacts/$id"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"name": name, "role": role, "phone": phone}),
    );
    if (res.statusCode == 200) _fetchContacts();
  }

  Future<void> _deleteContact(int id) async {
    final res = await http.delete(Uri.parse("$baseUrl/contacts/$id"));
    if (res.statusCode == 200) _fetchContacts();
  }

  // ------------------ UI ------------------
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
                "Contacte de Urgență",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Gestionați persoanele de contact pentru situații de urgență",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Add Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showAddDialog,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text(
                    "Adaugă Contact Nou",
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
              const SizedBox(height: 24),

              // Contact List
              ...contacts.map((contact) => _buildContactCard(contact)).toList(),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------ CONTACT CARD ------------------
  Widget _buildContactCard(Map<String, dynamic> contact) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFFEAF1FF),
                child: Icon(Icons.person, color: Colors.blueAccent, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact["name"],
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      contact["role"] ?? "",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          const SizedBox(height: 16),

          // Phone
          Row(
            children: [
              const Icon(Icons.phone, color: Colors.black54, size: 18),
              const SizedBox(width: 8),
              Text(
                contact["phone"] ?? "",
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
          const SizedBox(height: 16),

          // Status + Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusChip(
                contact["active"] == true ? "Notificare Activă" : "Inactiv",
                contact["active"] == true
                    ? Colors.green.shade100
                    : Colors.red.shade100,
                contact["active"] == true
                    ? Colors.green.shade700
                    : Colors.red.shade700,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _showEditDialog(contact),
                    icon: const Icon(Icons.edit, color: Colors.blueAccent),
                  ),
                  IconButton(
                    onPressed: () => _confirmDelete(contact),
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------ CHIP ------------------
  Widget _buildStatusChip(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: fg,
        ),
      ),
    );
  }

  // ------------------ DIALOGS ------------------
  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    final roleCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Adaugă Contact Nou"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: "Nume"),
                ),
                TextField(
                  controller: roleCtrl,
                  decoration: const InputDecoration(labelText: "Rol"),
                ),
                TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(labelText: "Telefon"),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Anulează"),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _addContact(
                    nameCtrl.text,
                    roleCtrl.text,
                    phoneCtrl.text,
                  );
                  Navigator.pop(context);
                },
                child: const Text("Adaugă"),
              ),
            ],
          ),
    );
  }

  void _showEditDialog(Map<String, dynamic> contact) {
    final nameCtrl = TextEditingController(text: contact["name"]);
    final roleCtrl = TextEditingController(text: contact["role"]);
    final phoneCtrl = TextEditingController(text: contact["phone"]);

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Editează Contact"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: "Nume"),
                ),
                TextField(
                  controller: roleCtrl,
                  decoration: const InputDecoration(labelText: "Rol"),
                ),
                TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(labelText: "Telefon"),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Anulează"),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _updateContact(
                    contact["id"],
                    nameCtrl.text,
                    roleCtrl.text,
                    phoneCtrl.text,
                  );
                  Navigator.pop(context);
                },
                child: const Text("Salvează"),
              ),
            ],
          ),
    );
  }

  void _confirmDelete(Map<String, dynamic> contact) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Șterge contactul?"),
            content: Text("Sigur doriți să ștergeți ${contact["name"]}?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Anulează"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: () async {
                  await _deleteContact(contact["id"]);
                  Navigator.pop(context);
                },
                child: const Text("Șterge"),
              ),
            ],
          ),
    );
  }
}
