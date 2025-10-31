import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isMonitoring = false;
  bool fallDetected = false;
  String status = "🔴 Sistemul este oprit";

  final String baseUrl = "http://192.168.0.7:5000"; // Flask backend
  Timer? statusTimer;

  @override
  void initState() {
    super.initState();
    _checkStatus();
    // Refresh every 2 seconds
    statusTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _checkStatus(),
    );
  }

  @override
  void dispose() {
    statusTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkStatus() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/status"));
      final data = json.decode(res.body);

      setState(() {
        isMonitoring = data['status'] == "active";
        fallDetected = data['fall_detected'] ?? false;
        status = isMonitoring
            ? "🟢 Sistemul monitorizează posibile căderi..."
            : "🔴 Sistemul este oprit";
      });
    } catch (e) {
      setState(() {
        status = "⚠️ Conexiune cu serverul eșuată";
      });
    }
  }

  Future<void> _toggleMonitoring() async {
    try {
      final url = isMonitoring ? "$baseUrl/stop" : "$baseUrl/start";
      final res = await http.get(Uri.parse(url));
      final data = json.decode(res.body);

      if (data['status'] == "started") {
        setState(() {
          isMonitoring = true;
          status = "🟢 Sistemul monitorizează posibile căderi...";
        });
      } else if (data['status'] == "stopped") {
        setState(() {
          isMonitoring = false;
          status = "🔴 Sistemul este oprit";
          fallDetected = false;
        });
      }
    } catch (e) {
      setState(() {
        status = "⚠️ Eroare de conexiune la server";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              "Monitorizare Activă",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              status,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: isMonitoring ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 20),

            // Live Video Stream
            if (isMonitoring)
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: InAppWebView(
                    initialUrlRequest: URLRequest(
                      url: WebUri("$baseUrl/video_feed"),
                    ),
                    initialSettings: InAppWebViewSettings(
                      mediaPlaybackRequiresUserGesture: false,
                      mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: Center(
                  child: Icon(
                    Icons.videocam_off,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // ⚠️ Live Fall Detection Banner
            if (isMonitoring)
              Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: fallDetected ? Colors.redAccent : Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    fallDetected
                        ? "⚠️ Cădere detectată!"
                        : "🟢 Nicio cădere detectată",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // Start/Stop Button
            Center(
              child: ElevatedButton.icon(
                onPressed: _toggleMonitoring,
                icon: Icon(
                  isMonitoring ? Icons.stop : Icons.play_arrow,
                  color: Colors.white,
                ),
                label: Text(
                  isMonitoring
                      ? "Oprește Monitorizarea"
                      : "Pornește Monitorizarea",
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isMonitoring ? Colors.redAccent : Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}