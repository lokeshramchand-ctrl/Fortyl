// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/otp_model.dart';
import 'scanner_overlay.dart';
// <-- your homepage

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  final MobileScannerController _scannerController = MobileScannerController();

  bool _hasScanned = false; // HARD LOCK

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) {
              if (_hasScanned) return;

              final barcodes = capture.barcodes;
              if (barcodes.isEmpty) return;

              final raw = barcodes.first.rawValue;
              if (raw == null) return;

              _hasScanned = true;
              _scannerController.stop();

              _handleScannedData(raw);
            },
          ),

          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: ScannerOverlayPainter(_animationController),
          ),

          Positioned(
            top: 48,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------
  // SCAN HANDLER
  // ---------------------------------------------------

  void _handleScannedData(String data) {
    try {
      final account = OtpAccount.fromOtpAuthUri(data);

      // SUCCESS → return result to HomeScreen
      Future.microtask(() {
        Navigator.pop(context, account);
      });
    } catch (_) {
      _showInvalidQr();
    }
  }

  void _showInvalidQr() async {
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Invalid QR code. Please scan a valid authenticator QR.',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.redAccent.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 800));

    _hasScanned = false;
    _scannerController.start();
  }
}
