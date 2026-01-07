// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otp/otp.dart';
import 'package:google_fonts/google_fonts.dart';

import 'scanner_screen.dart';
import '../models/otp_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Timer _refreshTimer;
  final List<OtpAccount> _accounts = [];

  @override
  void initState() {
    super.initState();
    // 60fps refresh for liquid-smooth progress transitions
    _refreshTimer = Timer.periodic(
      const Duration(milliseconds: 50),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    super.dispose();
  }

  // Peak Apple Interaction: Heavy mechanical haptics on code copy
  // Designed to feel like a physical "thud" inside the chassis
  void _handleCopy(String code) {
    Clipboard.setData(ClipboardData(text: code));
    HapticFeedback.heavyImpact(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          _buildLuxuryAppBar(),
          SliverToBoxAdapter(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              switchInCurve: Curves.easeOutQuart,
              child: _accounts.isEmpty ? _buildEmptyState() : _buildProList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLuxuryAppBar() {
    return SliverAppBar(
      expandedHeight: 160.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.black.withOpacity(0.8),
      elevation: 0,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 24, bottom: 20),
        title: Text(
          "Vault",
          style: GoogleFonts.inter(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -1.8,
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 24, top: 12),
          child: _buildProAddButton(),
        ),
      ],
    );
  }

  Widget _buildProAddButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _openScanner();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.05), width: 2),
            ),
            child: const Icon(Icons.face_retouching_natural, size: 64, color: Colors.white10),
          ),
          const SizedBox(height: 32),
          Text(
            "Enclave Isolated",
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Your digital credentials appear here once securely imported.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: Colors.white24,
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      itemCount: _accounts.length,
      itemBuilder: (_, index) => _buildTactileCard(_accounts[index]),
    );
  }

  Widget _buildTactileCard(OtpAccount account) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final progress = 1.0 - ((now % 30000) / 30000);
    final isCritical = progress < 0.25;
    
    // Apple Pro Palette
    const azureBlue = Color(0xFF007AFF);
    const systemRed = Color(0xFFFF3B30);
    final accent = isCritical ? systemRed : azureBlue;

    final otp = OTP.generateTOTPCodeString(
      account.secret,
      now,
      interval: 30,
      algorithm: Algorithm.SHA1,
      isGoogle: true,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF121214),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            // Ambient Liquid Progress
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 50),
                width: MediaQuery.of(context).size.width * progress,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accent.withOpacity(0.08), Colors.transparent],
                  ),
                ),
              ),
            ),
            
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _handleCopy(otp),
                highlightColor: accent.withOpacity(0.03),
                splashColor: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              account.label.toUpperCase(),
                              style: GoogleFonts.inter(
                                color: Colors.white54,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              account.account,
                              style: GoogleFonts.inter(
                                color: Colors.white24,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              otp.replaceAllMapped(RegExp(r".{3}"), (m) => "${m.group(0)} "),
                              style: GoogleFonts.inter(
                                color: isCritical ? systemRed : Colors.white,
                                fontSize: 44,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildProTimer(accent, progress),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProTimer(Color color, double progress) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 52,
          width: 52,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 3,
            color: color,
            backgroundColor: Colors.white.withOpacity(0.05),
          ),
        ),
        Container(
          height: 8,
          width: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openScanner() async {
    final result = await Navigator.push<OtpAccount>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const ScannerScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );

    if (result != null) {
      HapticFeedback.lightImpact();
      setState(() => _accounts.add(result));
    }
  }
}