// lib/screens/scanner_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/otp_model.dart';
import 'scanner_overlay.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _animationController;
  bool _scanned = false; // prevents multiple scans

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
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
            onDetect: (capture) {
              if (_scanned) return;

              final barcode = capture.barcodes.firstOrNull;
              final code = barcode?.rawValue;

              if (code != null && code.startsWith("otpauth://")) {
                _scanned = true;
                _handleScannedData(code);
              }
            },
          ),

          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: ScannerOverlayPainter(_animationController),
          ),

          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // OTPAUTH PARSER
  // ==========================================================

  void _handleScannedData(String data) {
    try {
      final uri = Uri.parse(data);

      final secret = uri.queryParameters['secret'];
      if (secret == null) return;

      final issuerParam = uri.queryParameters['issuer'];

      // Path format: /totp/Issuer:account OR /totp/account
      final path = uri.path.replaceFirst('/totp/', '');
      String issuer = issuerParam ?? 'Unknown';
      String account = path;

      if (path.contains(':')) {
        final parts = path.split(':');
        issuer = parts[0];
        account = parts[1];
      }

      Navigator.pop(
        context,
        OtpAccount(
          label: issuer,
          account: account,
          secret: secret,
        ),
      );
    } catch (_) {
      Navigator.pop(context);
    }
  }
}
