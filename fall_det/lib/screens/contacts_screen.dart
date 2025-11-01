import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final List<Map<String, dynamic>> contacts = [
    {
      "name": "Maria Ionescu",
      "role": "Soție",
      "phone": "+40 721 234 567",
      "rating": 5,
      "active": true,
    },
    {
      "name": "Dr. Andrei Popescu",
      "role": "Medic Familie",
      "phone": "+40 722 345 678",
      "rating": 5,
      "active": true,
    },
    {
      "name": "Elena Dumitrescu",
      "role": "Vecină",
      "phone": "+40 723 456 789",
      "rating": 5,
      "active": true,
    },
  ];

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
              const SizedBox(height: 30),
              Text(
                "Gestionați persoanele de contact pentru situații de urgență",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),

              // Add Contact Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Add new contact logic
                  },
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

              // Contacts List
              ...contacts.map((contact) => _buildContactCard(contact)).toList(),
            ],
          ),
        ),
      ),
    );
  }

  // Contact Card Widget
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
          // Header: Avatar + Name + Stars
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
                      contact["role"],
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Stars
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  contact["rating"],
                  (index) =>
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Phone number
          Row(
            children: [
              const Icon(Icons.phone, color: Colors.black54, size: 18),
              const SizedBox(width: 8),
              Text(
                contact["phone"],
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
          const SizedBox(height: 16),

          // Bottom row: Status + Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusChip(
                contact["active"] ? "Notificare Activă" : "Inactiv",
                contact["active"] ? Colors.green.shade100 : Colors.red.shade100,
                contact["active"] ? Colors.green.shade700 : Colors.red.shade700,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      // TODO: Edit contact
                    },
                    icon: const Icon(Icons.edit, color: Colors.blueAccent),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: () {
                      // TODO: Delete contact
                    },
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Status Chip Widget
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
}
