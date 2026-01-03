// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otp/otp.dart';
import 'package:permission_handler/permission_handler.dart';
import 'scanner_screen.dart';
import '../Models/otp_model.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Timer _refreshTimer;

  final List<OtpAccount> _accounts = [];

  @override
  void initState() {
    super.initState();

    _refreshTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) {
        final now = DateTime.now().millisecondsSinceEpoch;
        setState(() {
          _percent = 1.0 - ((now % 30000) / 30000);
        });
      },
    );
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
      body: _accounts.isEmpty ? _emptyState() : _buildList(),
    );
  }

  // ---------------- UI ----------------

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text(
        "Vault",
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -1,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: ElevatedButton(
            onPressed: _openScanner,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF07127),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white),
          ),
        )
      ],
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Text(
        "No accounts yet\nTap + to add",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white38, fontSize: 14),
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: _accounts.length,
      itemBuilder: (_, index) {
        final acc = _accounts[index];
        return PoshOTPKeyCard(
          label: acc.label,
          account: acc.account,
          secret: acc.secret,
        );
      },
    );
  }

  // ---------------- Logic ----------------

  Future<void> _openScanner() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) return;

    final result = await Navigator.push<OtpAccount>(
      context,
      MaterialPageRoute(builder: (_) => const ScannerScreen()),
    );

    if (result != null) {
      setState(() => _accounts.add(result));
    }
  }
}

// =======================================================
// OTP CARD
// =======================================================

class PoshOTPKeyCard extends StatelessWidget {
  final String label;
  final String account;
  final String secret;

  const PoshOTPKeyCard({
    super.key,
    required this.label,
    required this.account,
    required this.secret,
  });

  String _generateOTP() {
    return OTP.generateTOTPCodeString(
      secret,
      DateTime.now().millisecondsSinceEpoch,
      interval: 30,
      algorithm: Algorithm.SHA1,
      isGoogle: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final progress = 1.0 - ((now % 30000) / 30000);

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
          // Liquid timer background
          FractionallySizedBox(
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFF07127).withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _info(),
                _status(progress),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _info() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          account,
          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: _generateOTP()));
            HapticFeedback.vibrate();
          },
          child: Text(
            _generateOTP().replaceAllMapped(
              RegExp(r".{3}"),
              (m) => "${m.group(0)} ",
            ),
            style: const TextStyle(
              color: Color(0xFFF07127),
              fontSize: 36,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _status(double progress) {
    final color = progress > 0.2 ? const Color(0xFFF07127) : Colors.redAccent;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.copy_rounded, color: Colors.white.withOpacity(0.2)),
        const Spacer(),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.5), blurRadius: 10),
            ],
          ),
        ),
      ],
    );
  }
}
