import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bu_passport/classes/passport_model.dart';
import 'package:bu_passport/classes/passport.dart';

class PassportBookWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final passportModel = Provider.of<PassportModel>(context);
    return Center(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.5,
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
              child: Container(
                decoration: ShapeDecoration(
                color: Color(0x59F4E2AF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9.21),
                  side: BorderSide(color: Color.fromARGB(88, 165, 151, 111), width: 2.0),
                ),
              ),
                child: buildPageContent(passportModel.passport.pages.length > 0 ? passportModel.passport.pages[0] : []),
              ),
            ),
            // Right Page
            Expanded(
              child: Container(
                decoration: ShapeDecoration(
                color: Color(0x59F4E2AF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9.21),
                  side: BorderSide(color: Color.fromARGB(88, 165, 151, 111), width: 2.0),
                ),
              ),
                child: buildPageContent(passportModel.passport.pages.length > 1 ? passportModel.passport.pages[1] : []),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPageContent(List<Sticker> stickers) {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: stickers.length,
      itemBuilder: (context, index) {
        return Image.asset(stickers[index].imagePath, fit: BoxFit.cover);
      },
    );
  }
}