import 'dart:math';
import 'package:flutter/material.dart';

class PostmarkPainter extends CustomPainter {
  final int points; // Added to accept points

  PostmarkPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final _color =  Color(0xFFCC0000);
    canvas.translate(radius, radius);
    canvas.rotate(_degreeToRadian(-20));
    canvas.translate(-radius, -radius);

    // Paint object for the dashed outer circle
    final Paint outerPaint = Paint()
      ..color = _color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.03*size.height;

    // Dashed circle logic
    double dashWidth = 0.08*size.height;
    double dashSpace = 0.07*size.height;
    double angle = 0;

    while (angle < 360) {
      final startX = radius + (radius - 0.05*size.height) * cos(_degreeToRadian(angle));
      final startY = radius + (radius - 0.05*size.height) * sin(_degreeToRadian(angle));
      final endX = radius + (radius - 0.05*size.height) * cos(_degreeToRadian(angle + dashWidth));
      final endY = radius + (radius - 0.05*size.height) * sin(_degreeToRadian(angle + dashWidth));

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        outerPaint,
      );

      angle += dashWidth + dashSpace;
    }

    // Inner solid circle
    final Paint innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(radius, radius), radius - 0.1*size.height, innerPaint);

    // Paint inner circle border
    final Paint innerBorderPaint = Paint()
      ..color = _color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.02*size.height;

    canvas.drawCircle(Offset(radius, radius), radius - 0.12*size.height, innerBorderPaint);

    // Draw points text
    final TextStyle textStyle = TextStyle(
      fontFamily: 'Inter',
      color: _color,
      fontSize: 0.38*size.height,
      fontWeight: FontWeight.bold,
    );

    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: '$points',
        style: textStyle,
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2 - 0.08*size.height,
      ),
    );

    // Draw "pts" label
    final TextStyle ptsStyle = TextStyle(
      color: _color,
      fontSize: 0.18*size.height,
      fontWeight: FontWeight.bold,
    );

    final TextPainter ptsPainter = TextPainter(
      text: TextSpan(
        text: 'Pts',
        style: ptsStyle,
      ),
      textDirection: TextDirection.ltr,
    );

    ptsPainter.layout();
    ptsPainter.paint(
      canvas,
      Offset(
        (size.width - ptsPainter.width) / 2,
        (size.height - ptsPainter.height) / 2 + 0.18*size.height,
      ),
    );
  }

  double _degreeToRadian(double degree) => degree * (pi / 180);

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
