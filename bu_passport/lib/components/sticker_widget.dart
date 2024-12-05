import 'package:flutter/material.dart';
import 'package:bu_passport/classes/passport.dart';

class StickerWidget extends StatelessWidget {
  final List<int> stickerIds;

  StickerWidget({required this.stickerIds});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(8), // Increase padding around the grid
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3x3 grid
        crossAxisSpacing: 16, // Increase space between columns
        mainAxisSpacing: 16, // Increase space between rows
        childAspectRatio: 1, // Ensure the grid cells are square
      ),
      itemCount: 9, // Always show 9 items
      itemBuilder: (context, index) {
        if (index < stickerIds.length) {
          Sticker sticker = Sticker(id: stickerIds[index]);
          return Draggable<Map<String, dynamic>>(
            data: {'sticker': sticker, 'position': index},
            feedback: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(sticker.imagePath),
                  fit: BoxFit.contain, // Ensure the entire sticker is visible
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
                  image: AssetImage(sticker.imagePath),
                  fit: BoxFit.contain, // Ensure the entire sticker is visible
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
                fit: BoxFit.contain, // Ensure the entire sticker is visible
              ),
              border: Border.all(color: Colors.transparent, width: 0),
            ),
          );
        }
      },
    );
  }
}