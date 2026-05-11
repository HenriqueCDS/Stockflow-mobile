import 'package:flutter/material.dart';
import 'package:homestock_mobile/core/theme/app_colors.dart';

class ScanBracketPainter extends CustomPainter {
  final bool isActive;

  const ScanBracketPainter({this.isActive = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isActive ? AppColors.accent : Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLen = 28.0;
    final w = size.width;
    final h = size.height;

    // Top-left
    canvas.drawLine(Offset(0, cornerLen), Offset.zero, paint);
    canvas.drawLine(Offset.zero, Offset(cornerLen, 0), paint);

    // Top-right
    canvas.drawLine(Offset(w - cornerLen, 0), Offset(w, 0), paint);
    canvas.drawLine(Offset(w, 0), Offset(w, cornerLen), paint);

    // Bottom-left
    canvas.drawLine(Offset(0, h - cornerLen), Offset(0, h), paint);
    canvas.drawLine(Offset(0, h), Offset(cornerLen, h), paint);

    // Bottom-right
    canvas.drawLine(Offset(w - cornerLen, h), Offset(w, h), paint);
    canvas.drawLine(Offset(w, h), Offset(w, h - cornerLen), paint);
  }

  @override
  bool shouldRepaint(ScanBracketPainter old) => old.isActive != isActive;
}
