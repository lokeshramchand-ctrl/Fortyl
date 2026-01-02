// lib/screens/qr_scanner_overlay.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class ScannerOverlayPainter extends CustomPainter {
  final Animation<double> animation;
  ScannerOverlayPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final scanAreaSize = size.width * 0.7;
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: scanAreaSize,
      height: scanAreaSize,
    );

    // 1. Draw the darkened background
    final backgroundPaint = Paint()..color = Colors.black.withOpacity(0.7);
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(24)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(backgroundPath, backgroundPaint);

    // 2. Draw the orange "Laser" line
    final laserPaint = Paint()
      ..color = const Color(0xFFF07127)
      ..strokeWidth = 2.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    
    // Animate the line up and down
    final double yPos = rect.top + (rect.height * animation.value);
    canvas.drawLine(Offset(rect.left + 10, yPos), Offset(rect.right - 10, yPos), laserPaint);

    // 3. Draw rounded corners for the "Posh" look
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(24)), borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}