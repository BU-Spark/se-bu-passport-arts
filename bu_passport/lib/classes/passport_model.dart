import 'package:flutter/material.dart';
import 'package:bu_passport/classes/passport.dart';

class PassportModel extends ChangeNotifier {
  Passport passport;

  PassportModel(this.passport);

  void addSticker(Sticker sticker, int pageIndex, int position) {
    // Check if the sticker is already in the passport
    bool stickerExists = passport.pages.any((page) => page.contains(sticker));
    if (!stickerExists && pageIndex < passport.pages.length) {
      // Add the sticker to the specified page and position
      if (passport.pages[pageIndex].length <= position) {
        passport.pages[pageIndex].add(sticker);
      } else {
        passport.pages[pageIndex].insert(position, sticker);
      }
      notifyListeners();
    }
  }
}