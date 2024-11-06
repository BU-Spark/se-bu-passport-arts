import 'dart:io';
import 'package:bu_passport/components/sticker_painters.dart';
import 'package:flutter/material.dart';
import 'postmark_widget.dart';
import 'dart:ui' as ui;




class SuccessDialog extends StatelessWidget {
  final String eventTitle;
  final int points;
  final ui.Image? image;
  final ui.Image? logo;
  final ui.Image? frame;
  final ui.Image? sticker1;
  final ui.Image? sticker2;
  static const double STAMP_SIZE=100;
  static const double POSTMARK_SIZE=100;

  const SuccessDialog({
    Key? key,
    required this.eventTitle,
    required this.points,
    this.image, this.frame, this.sticker1, this.sticker2, this.logo,
  }) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'SUCCESS!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFCC0000),
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            if (image != null)
              CustomPaint(
                size: Size(STAMP_SIZE,STAMP_SIZE),
                painter: ImagePainter(image,frame,sticker1,sticker2),
              ),
            if(image==null)
              CustomPaint(
                size: const Size(STAMP_SIZE, STAMP_SIZE),
                painter: LogoPainter(logo,sticker1,sticker2),
              ),
            const SizedBox(height: 16),
            Text(
              eventTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            CustomPaint(
              size: Size(POSTMARK_SIZE,POSTMARK_SIZE),
              painter: PostmarkPainter(points: points),// points
            ),
          ],
        ),
      ),
    );
  }
}
