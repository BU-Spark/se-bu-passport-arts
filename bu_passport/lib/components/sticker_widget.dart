import 'package:flutter/material.dart';
import 'package:bu_passport/classes/passport.dart';

class StickerWidget extends StatelessWidget {
  final List<Sticker> stickers;

  StickerWidget({required this.stickers});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3x3 grid
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: 9, // Always show 9 items
      itemBuilder: (context, index) {
        if (index < stickers.length) {
          return Draggable<Map<String, dynamic>>(
            data: {'sticker': stickers[index], 'position': index},
            feedback: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(stickers[index].imagePath),
                  fit: BoxFit.contain,
                ),
                border: Border.all(color: Colors.transparent, width: 0),
              ),
            ),
            childWhenDragging: Container(
              width: 60,
              height: 60,
              color: Colors.transparent,
            ),
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(stickers[index].imagePath),
                  fit: BoxFit.contain,
                ),
                border: Border.all(color: Colors.transparent, width: 0),
              ),
            ),
          );
        } else {
          return Container(
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/images/stickers/empty_sticker.png'),
                fit: BoxFit.contain,
              ),
              border: Border.all(color: Colors.transparent, width: 0),
            ),
          );
        }
      },
    );
  }
}