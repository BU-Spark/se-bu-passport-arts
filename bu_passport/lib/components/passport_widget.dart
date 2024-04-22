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
        width: MediaQuery.of(context).size.width * 0.9, // Take 90% of screen width
        height: 300, // Fixed height for the passport book
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
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
                decoration: BoxDecoration(
                  border: Border(right: BorderSide(color: Colors.black26)),
                ),
                child: buildPageContent(passportModel.passport.pages.length > 0 ? passportModel.passport.pages[0] : []),
              ),
            ),
            // Right Page
            Expanded(
              child: buildPageContent(passportModel.passport.pages.length > 1 ? passportModel.passport.pages[1] : []),
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
