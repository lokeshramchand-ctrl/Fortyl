
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class ScannerOverlayPainter extends CustomPainter {
  final Animation<double> animation;

  ScannerOverlayPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    const Color sageGreen = Color(0xFF30D158);
    final double scanAreaSize = size.width * 0.72;
    const double borderRadius = 36.0;

    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: scanAreaSize,
      height: scanAreaSize,
    );

    // 1. Deep OLED Background Mask
    // Using even-odd fill to create the transparent scanning aperture
    final backgroundPaint = Paint()..color = Colors.black.withOpacity(0.85);

    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(borderRadius)),
      )
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(backgroundPath, backgroundPaint);

    
    // 3. Titanium Corner Brackets
    // Drawing specific corners instead of a full box for a "Pro" technical look
    final borderPaint = Paint()
      ..color = sageGreen.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4;

    const double cornerLength = 32.0;
    final Path cornersPath = Path();

    // Top Left
    cornersPath.moveTo(rect.left, rect.top + cornerLength);
    cornersPath.lineTo(rect.left, rect.top + borderRadius);
    cornersPath.arcToPoint(
      Offset(rect.left + borderRadius, rect.top),
      radius: const Radius.circular(borderRadius),
    );
    cornersPath.lineTo(rect.left + cornerLength, rect.top);

    // Top Right
    cornersPath.moveTo(rect.right - cornerLength, rect.top);
    cornersPath.lineTo(rect.right - borderRadius, rect.top);
    cornersPath.arcToPoint(
      Offset(rect.right, rect.top + borderRadius),
      radius: const Radius.circular(borderRadius),
    );
    cornersPath.lineTo(rect.right, rect.top + cornerLength);

    // Bottom Right
    cornersPath.moveTo(rect.right, rect.bottom - cornerLength);
    cornersPath.lineTo(rect.right, rect.bottom - borderRadius);
    cornersPath.arcToPoint(
      Offset(rect.right - borderRadius, rect.bottom),
      radius: const Radius.circular(borderRadius),
    );
    cornersPath.lineTo(rect.right - cornerLength, rect.bottom);

    // Bottom Left
    cornersPath.moveTo(rect.left + cornerLength, rect.bottom);
    cornersPath.lineTo(rect.left + borderRadius, rect.bottom);
    cornersPath.arcToPoint(
      Offset(rect.left, rect.bottom - borderRadius),
      radius: const Radius.circular(borderRadius),
    );
    cornersPath.lineTo(rect.left, rect.bottom - cornerLength);

    canvas.drawPath(cornersPath, borderPaint);

    // 4. Subtle Aperture Shadow
    // Inner shadow to make the scan area feel recessed into the hardware
    final shadowPaint = Paint()
      ..color = sageGreen.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(borderRadius)),
      shadowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ScannerOverlayPainter oldDelegate) {
    return true;
  }
}