// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/otp_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
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
      (_) => setState(() {}),
    );
 

  _refreshTimer = Timer.periodic(
    const Duration(milliseconds: 100),
    (_) => setState(() {}),
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
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _accounts.isEmpty ? _emptyState() : _buildList(),
      ),
    );
  }

  // ================= APP BAR =================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        "Vault",
        style: GoogleFonts.inter(
          fontSize: 30,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -1,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 18),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _openScanner,
            child: Ink(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF07127),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF07127).withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
            ),
          ),
        ),
      ],
    );
  }

  // ================= EMPTY STATE =================

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shield_outlined, size: 52, color: Colors.white24),
          const SizedBox(height: 14),
          Text(
            "No accounts yet",
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Tap + to add your first key",
            style: GoogleFonts.inter(
              color: Colors.white38,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ================= LIST =================

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      itemCount: _accounts.length,
      itemBuilder: (_, index) {
        final acc = _accounts[index];
        return OtpAccount(
          label: acc.label,
          account: acc.account,
          secret: acc.secret,
        );
      },
    );
  }

  // ================= SCANNER =================

Future<void> _openScanner() async {
  final status = await Permission.camera.request();
  if (!status.isGranted) return;

  final result = await Navigator.push<OtpAccount>(
    context,
    MaterialPageRoute(builder: (_) => const ScannerScreen()),
  );

  if (result != null) {
    setState(() {
      _accounts.add(result);
    });
  }
}

}
