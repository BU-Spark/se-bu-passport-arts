import 'dart:io';
import 'package:flutter/material.dart';
import 'postmark_widget.dart';
import 'dart:ui' as ui;

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


    // Draw the user's photo
// Assume 'image' is the user photo and 'frame' is the frame image
    final double image_padding = size.height*0.167; // Padding around the image to create the frame effect
    final double frame_padding = size.height*0.167;


    //final backgroundPaint = Paint()..color = Colors.black; // Change color as needed
    //canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

// Center the image in the frame
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

      // Draw stickers if they are not null
      if (sticker1 != null) {
        // Draw sticker1 in the bottom left corner
        canvas.drawImageRect(
          sticker1!,
          Rect.fromLTWH(0, 0, sticker1!.width.toDouble(), sticker1!.height.toDouble()),
          Rect.fromLTWH(0, size.height*0.58, size.height*0.42, size.height*0.42), // Bottom left
          Paint(),
        );
      }

      if (sticker2 != null) {
        // Draw sticker2 in the upper right corner
        canvas.drawImageRect(
          sticker2!,
          Rect.fromLTWH(0, 0, sticker2!.width.toDouble(), sticker2!.height.toDouble()),
          Rect.fromLTWH(size.width*0.58, 0, size.width*0.42, size.width*0.42), // Upper right
          Paint(),
        );
        }
    }


    // Draw the frame first, larger than the image


  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class IconPainter extends CustomPainter {
  final ui.Image? image;
  final Color _frameColor = Color(0xFFCC0000); // Frame color
  final ui.Image? sticker1;
  final ui.Image? sticker2;



  IconPainter(this.image, this.sticker1, this.sticker2);


  @override
  void paint(Canvas canvas, Size size) {
    if (image != null) {
      // Calculate the center and radius for the frame
      final double centerX = size.width / 2;
      final double centerY = size.height / 2;
      final double radius = size.width / 2;
      final double _outerFrameThickness = size.height*0.0292; // Thickness of the outer frame
      final double _innerFrameThickness = size.height*0.01; // Thickness of the inner frame
      final _middleFrameThickness = size.height*0.01667;

      // Draw the outer frame (bold)
// Draw the outer frame (thick red)
      final Paint outerFramePaint = Paint()
        ..color = _frameColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = _outerFrameThickness;
      canvas.drawCircle(Offset(centerX, centerY), radius, outerFramePaint);

      // Draw the middle frame (thin white)
      final Paint middleFramePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = _middleFrameThickness;
      canvas.drawCircle(Offset(centerX, centerY), radius - (_outerFrameThickness / 2), middleFramePaint);

      // Draw the inner frame (thinner red)
      final Paint innerFramePaint = Paint()
        ..color = _frameColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = _innerFrameThickness;
      canvas.drawCircle(Offset(centerX, centerY), radius - (_outerFrameThickness + _middleFrameThickness), innerFramePaint);

      // Clip the canvas to a circle to create rounded image
      canvas.save();
      canvas.clipPath(Path()..addOval(Rect.fromCircle(center: Offset(centerX, centerY), radius: radius - _outerFrameThickness-_middleFrameThickness-_innerFrameThickness-3.0)));

      // Draw the image, clipped to the circle
      canvas.drawImageRect(
        image!,
        Rect.fromLTWH(0, 0, image!.width.toDouble(), image!.height.toDouble()),
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint(),
      );
      canvas.restore();

      // Draw stickers overlapping the frame
      if (sticker1 != null) {
        final double stickerSize = size.height*0.4167; // Size for the stickers
        // Move sticker1 closer to the middle
        canvas.drawImageRect(
          sticker1!,
          Rect.fromLTWH(0, 0, sticker1!.width.toDouble(), sticker1!.height.toDouble()),
          Rect.fromLTWH(-stickerSize * 0.1, size.height - stickerSize, stickerSize, stickerSize), // Adjusted position
          Paint(),
        );
      }

      if (sticker2 != null) {
        final double stickerSize = size.height*0.4167; // Size for the stickers
        // Move sticker2 closer to the middle
        canvas.drawImageRect(
          sticker2!,
          Rect.fromLTWH(0, 0, sticker2!.width.toDouble(), sticker2!.height.toDouble()),
          Rect.fromLTWH(size.width - stickerSize, -stickerSize * 0.1, stickerSize, stickerSize), // Adjusted position
          Paint(),
        );
      }

      // Restore the canvas to allow for future drawings
      canvas.restore();
    }
  }


  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}



class SuccessDialog extends StatelessWidget {
  final String eventTitle;
  final int points;
  final ui.Image? image; // Add this to receive the image
  final ui.Image? icon; // Add this to receive the image
  final ui.Image? frame; // Add this to receive the image
  final ui.Image? sticker1; // Add this to receive the image
  final ui.Image? sticker2; // Add this to receive the image
  static const double STAMP_SIZE=120;
  static const double POSTMARK_SIZE=95;

  const SuccessDialog({
    Key? key,
    required this.eventTitle,
    required this.points,
    this.image, this.frame, this.sticker1, this.sticker2, this.icon, // Optional image parameter
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
                size: const Size(STAMP_SIZE, STAMP_SIZE), // Size for the image
                painter: IconPainter(icon,sticker1,sticker2),
              ),
            const SizedBox(height: 16), // Spacing between image and postmark
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
