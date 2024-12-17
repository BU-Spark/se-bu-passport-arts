import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bu_passport/classes/passport_model.dart';
import 'package:bu_passport/classes/passport.dart';

class PassportBookWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final passportModel = Provider.of<PassportModel>(context);
    final borderColor = Color(0x59F4E2AF).withOpacity(0.8); // Darker version of the color

    return Center(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.5, // Increased height
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0xFFF2EFE7).withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // Left Page
            Expanded(
              child: DragTarget<Map<String, dynamic>>(
                onWillAccept: (data) {
                  // Check if the sticker is already in the passport
                  return !passportModel.passport.pages.any((page) => page.contains(data?['sticker']));
                },
                onAccept: (data) {
                  passportModel.addSticker(data['sticker'], 0, data['position']);
                },
                builder: (context, candidateData, rejectedData) {
                  return Container(
                    decoration: ShapeDecoration(
                      color: Color(0x59F4E2AF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9.21),
                        side: BorderSide(color: borderColor, width: 1),
                      ),
                    ),
                    child: buildPageContent(passportModel.passport.pages.length > 0 ? passportModel.passport.pages[0] : [], 0),
                  );
                },
              ),
            ),
            // Right Page
            Expanded(
              child: DragTarget<Map<String, dynamic>>(
                onWillAccept: (data) {
                  // Check if the sticker is already in the passport
                  return !passportModel.passport.pages.any((page) => page.contains(data?['sticker']));
                },
                onAccept: (data) {
                  passportModel.addSticker(data['sticker'], 1, data['position']);
                },
                builder: (context, candidateData, rejectedData) {
                  return Container(
                    decoration: ShapeDecoration(
                      color: Color(0x59F4E2AF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9.21),
                        side: BorderSide(color: borderColor, width: 1),
                      ),
                    ),
                    child: buildPageContent(passportModel.passport.pages.length > 1 ? passportModel.passport.pages[1] : [], 1),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPageContent(List<Sticker> stickers, int pageIndex) {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: stickers.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(stickers[index].imagePath),
              fit: BoxFit.contain,
            ),
            border: Border.all(color: Colors.transparent, width: 0),
          ),
        );
      },
    );
  }
}