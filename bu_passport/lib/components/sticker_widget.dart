import 'package:flutter/material.dart';
import 'package:bu_passport/classes/passport.dart';

class StickerWidget extends StatelessWidget {
  final List<Sticker> stickers;

  StickerWidget({required this.stickers});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: GridView.builder(
        padding: EdgeInsets.all(8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // 3x3 grid
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          childAspectRatio: 1, // Ensure the grid cells are square
        ),
        itemCount: 9, // Always show 9 items
        itemBuilder: (context, index) {
          if (index < stickers.length) {
            return Draggable<Sticker>(
              data: stickers[index],
              feedback: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(stickers[index].imagePath),
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(color: Colors.transparent, width: 0),
                ),
              ),
              childWhenDragging: Container(
                width: 60,
                height: 60,
                color: Colors.white,
              ),
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(stickers[index].imagePath),
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(color: Colors.transparent, width: 0),
                ),
              ),
            );
          } else {
            return Container(
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/images/passport/empty_sticker.png'),
                  fit: BoxFit.cover,
                ),
                border: Border.all(color: Colors.transparent, width: 0), // Remove grid lines
              ),
            );
          }
        },
      )
    );
  }
}