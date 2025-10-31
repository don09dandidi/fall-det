import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SideBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const SideBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  bool isCollapsed = false;

  void toggleSidebar() {
    setState(() => isCollapsed = !isCollapsed);
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
      // 👇 Swipe gestures to expand/collapse
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx > 6 && isCollapsed) {
          toggleSidebar(); // swipe right → expand
        } else if (details.delta.dx < -6 && !isCollapsed) {
          toggleSidebar(); // swipe left → collapse
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: isCollapsed ? 70 : 200,
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
                        isCollapsed ? Icons.menu : Icons.arrow_back_ios_new,
                        color: Colors.blueAccent,
                      ),
                      onPressed: toggleSidebar,
                    ),
                    if (!isCollapsed) ...[
                      const SizedBox(width: 6),
                      Flexible(
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
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: GoogleFonts.poppins(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
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
              ...List.generate(menuItems.length, (index) {
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
                    color: isActive ? Colors.blue.shade50 : Colors.transparent,
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
                          Text(
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
                        ],
                      ],
                    ),
                  ),
                );
              }),

              const Spacer(),
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
                          fontSize: 12,
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
                          Text(
                            "Cameră Activă",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.black87,
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
                          Text(
                            "Monitorizare",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

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
            ],
          ),
        ),
      ),
    );
  }
}
