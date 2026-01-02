// ignore_for_file: unused_field, deprecated_member_use

import 'dart:async';
import 'package:aegis_mobile/Screens/scanner_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otp/otp.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Timer _refreshTimer;
  double _percent = 1.0;

  @override
  void initState() {
    super.initState();
    // Update every 100ms for "Liquid" smooth animations
    _refreshTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final now = DateTime.now().millisecondsSinceEpoch;
      setState(() {
        _percent = 1.0 - ((now % 30000) / 30000);
      });
    });
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      appBar: _buildAppBar(),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: 3, // In production, this comes from your database
        itemBuilder: (context, index) => const PoshOTPKeyCard(
          label: "GitHub",
          account: "lokesh.ram@university.com",
          secret: "JBSWY3DPEHPK3PXP", // Mock Base32 Secret
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      title: const Text("Vault", 
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1)),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: ElevatedButton(
            onPressed: () {
              // Action for adding a new OTP key
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const ScannerScreen()),
  );            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF07127),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
          ),
        )
      ],
    );
  }
}

class PoshOTPKeyCard extends StatelessWidget {
  final String label;
  final String account;
  final String secret;

  const PoshOTPKeyCard({required this.label, required this.account, required this.secret, super.key});

  String _generateOTP() {
    return OTP.generateTOTPCodeString(secret, DateTime.now().millisecondsSinceEpoch, 
      interval: 30, algorithm: Algorithm.SHA1, isGoogle: true);
  }

  @override
  Widget build(BuildContext context) {
    // We use a TweenAnimationBuilder for the 'Liquid' progress effect
    final now = DateTime.now().millisecondsSinceEpoch;
    final double progress = 1.0 - ((now % 30000) / 30000);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 140,
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Stack(
        children: [
          // 1. The Liquid Background Fill (The "Posh" Timer)
          Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    colors: [const Color(0xFFF07127).withOpacity(0.15), Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
          
          // 2. Content Layer
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(label, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(account, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                    const SizedBox(height: 12),
                    // Digital OTP Code
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: _generateOTP()));
                        HapticFeedback.vibrate();
                      },
                      child: Text(
                        _generateOTP().replaceAllMapped(RegExp(r".{3}"), (match) => "${match.group(0)} "),
                        style: const TextStyle(
                          color: Color(0xFFF07127), 
                          fontSize: 36, 
                          fontWeight: FontWeight.w900, 
                          letterSpacing: 1
                        ),
                      ),
                    ),
                  ],
                ),
                // 3. Status Indicator (Minimalist Dot)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.copy_rounded, color: Colors.white.withOpacity(0.2), size: 20),
                    const Spacer(),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: progress > 0.2 ? const Color(0xFFF07127) : Colors.redAccent,
                        boxShadow: [
                          BoxShadow(
                            color: (progress > 0.2 ? const Color(0xFFF07127) : Colors.redAccent).withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2
                          )
                        ]
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}