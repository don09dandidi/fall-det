import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SideBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final VoidCallback onClose;

  const SideBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onClose,
  });

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  bool isCollapsed = false;

  void toggleSidebar() {
    if (isCollapsed) {
      setState(() => isCollapsed = false);
    } else {
      setState(() => isCollapsed = true);
      // Close completely after animation
      Future.delayed(const Duration(milliseconds: 300), () {
        widget.onClose();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {'icon': Icons.monitor_heart, 'title': 'Monitorizare'},
      {'icon': Icons.notifications, 'title': 'Alerte'},
      {'icon': Icons.people, 'title': 'Contacte'},
      {'icon': Icons.timer, 'title': 'Check-in'},
      {'icon': Icons.settings, 'title': 'Setări'},
    ];

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx < -6) {
          // Swipe left to close
          widget.onClose();
        }
      },
      child: Material(
        elevation: 8,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isCollapsed ? 70 : 230,
          color: Colors.white,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // Header with toggle button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          isCollapsed ? Icons.menu : Icons.close,
                          color: Colors.blueAccent,
                        ),
                        onPressed: toggleSidebar,
                      ),
                      if (!isCollapsed) ...[
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "SafeGuard",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Sistem Detectare Căderi",
                                style: GoogleFonts.poppins(
                                  color: Colors.grey[600],
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 15),
                const Divider(),

                // Navigation Items
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: List.generate(menuItems.length, (index) {
                        final item = menuItems[index];
                        final isActive = index == widget.selectedIndex;

                        return InkWell(
                          onTap: () => widget.onItemSelected(index),
                          hoverColor: Colors.blue.shade50.withOpacity(0.3),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 18,
                            ),
                            color:
                                isActive
                                    ? Colors.blue.shade50
                                    : Colors.transparent,
                            child: Row(
                              children: [
                                Icon(
                                  item['icon'],
                                  color:
                                      isActive
                                          ? Colors.blueAccent
                                          : Colors.grey.shade600,
                                ),
                                if (!isCollapsed) ...[
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      item['title'],
                                      style: GoogleFonts.poppins(
                                        color:
                                            isActive
                                                ? Colors.blueAccent
                                                : Colors.grey.shade800,
                                        fontWeight:
                                            isActive
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),

                const Divider(),

                // System Status
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 6,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isCollapsed)
                        Text(
                          "STATUS SISTEM",
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.camera_alt,
                            color: Colors.green,
                            size: 16,
                          ),
                          if (!isCollapsed) ...[
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "Cameră Activă",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.security,
                            color: Colors.blue,
                            size: 16,
                          ),
                          if (!isCollapsed) ...[
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "Monitorizare",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Assistance Section
                if (!isCollapsed)
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Asistență 24/7",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Suntem aici pentru tine",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
