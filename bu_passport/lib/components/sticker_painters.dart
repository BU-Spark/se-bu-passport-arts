
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../classes/sticker.dart';
import 'postmark_widget.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:http/http.dart' as http;




class ImagePainter extends CustomPainter {
  final ui.Image? image;
  final Color _frameColor = Color(0xFFCC0000); // Frame color
  final double _frameThickness = 8.0; // Thickness of the frame
  final ui.Image? frame;
  final ui.Image? sticker1;
  final ui.Image? sticker2;



  ImagePainter(this.image, this.frame, this.sticker1, this.sticker2);


  @override
  void paint(Canvas canvas, Size size) {

    final double image_padding = size.height*0.167;
    final double frame_padding = size.height*0.167;

    if(image!=null&&frame!=null){
      canvas.drawImageRect(
        image!,
        Rect.fromLTWH(0, 0, image!.width.toDouble(), image!.height.toDouble()),
        Rect.fromLTWH(image_padding/2+frame_padding/2, image_padding/2+frame_padding/2, size.width-image_padding-frame_padding, size.height-image_padding-frame_padding), // Center the image by adding padding
        Paint(),
      );
      canvas.drawImageRect(
        frame!,
        Rect.fromLTWH(0, 0, frame!.width.toDouble(), frame!.height.toDouble()),
        Rect.fromLTWH(frame_padding/2, frame_padding/2, size.width-frame_padding, size.height-frame_padding), // Increase size for the frame
        Paint(),
      );

      if (sticker1 != null) {
        canvas.drawImageRect(
          sticker1!,
          Rect.fromLTWH(0, 0, sticker1!.width.toDouble(), sticker1!.height.toDouble()),
          Rect.fromLTWH(0, size.height*0.58, size.height*0.42, size.height*0.42), // Bottom left
          Paint(),
        );
      }

      if (sticker2 != null) {
        canvas.drawImageRect(
          sticker2!,
          Rect.fromLTWH(0, 0, sticker2!.width.toDouble(), sticker2!.height.toDouble()),
          Rect.fromLTWH(size.width*0.58, 0, size.width*0.42, size.width*0.42), // Upper right
          Paint(),
        );
      }
    }


  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class IconPainter extends CustomPainter {
  final ui.Image? image;
  final Color _frameColor = Color(0xFFCC0000);
  final ui.Image? sticker1;
  final ui.Image? sticker2;



  IconPainter(this.image, this.sticker1, this.sticker2);


  @override
  void paint(Canvas canvas, Size size) {
    if (image != null) {
      final double centerX = size.width / 2;
      final double centerY = size.height / 2;
      final double radius = size.width / 2;
      final double _outerFrameThickness = size.height*0.0292;
      final double _innerFrameThickness = size.height*0.01;
      final _middleFrameThickness = size.height*0.01667;

      final Paint outerFramePaint = Paint()
        ..color = _frameColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = _outerFrameThickness;
      canvas.drawCircle(Offset(centerX, centerY), radius, outerFramePaint);

      final Paint middleFramePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = _middleFrameThickness;
      canvas.drawCircle(Offset(centerX, centerY), radius - (_outerFrameThickness / 2), middleFramePaint);

      final Paint innerFramePaint = Paint()
        ..color = _frameColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = _innerFrameThickness;
      canvas.drawCircle(Offset(centerX, centerY), radius - (_outerFrameThickness + _middleFrameThickness), innerFramePaint);


      canvas.save();
      canvas.clipPath(Path()..addOval(Rect.fromCircle(center: Offset(centerX, centerY), radius: radius - _outerFrameThickness-_middleFrameThickness-_innerFrameThickness-3.0)));

      canvas.drawImageRect(
        image!,
        Rect.fromLTWH(0, 0, image!.width.toDouble(), image!.height.toDouble()),
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint(),
      );
      canvas.restore();

      if (sticker1 != null) {
        final double stickerSize = size.height*0.4167;
        canvas.drawImageRect(
          sticker1!,
          Rect.fromLTWH(0, 0, sticker1!.width.toDouble(), sticker1!.height.toDouble()),
          Rect.fromLTWH(-stickerSize * 0.1, size.height - stickerSize, stickerSize, stickerSize), // Adjusted position
          Paint(),
        );
      }

      if (sticker2 != null) {
        final double stickerSize = size.height*0.4167;
        canvas.drawImageRect(
          sticker2!,
          Rect.fromLTWH(0, 0, sticker2!.width.toDouble(), sticker2!.height.toDouble()),
          Rect.fromLTWH(size.width - stickerSize, -stickerSize * 0.1, stickerSize, stickerSize), // Adjusted position
          Paint(),
        );
      }

      canvas.restore();
    }
  }


  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
