import 'package:flutter/material.dart';
import 'package:bu_passport/classes/passport.dart';

class PassportModel with ChangeNotifier {
  Passport passport = Passport();
  StickerRepository stickerRepository = StickerRepository();

  void addStickerFromCheckIn() {
    Sticker newSticker = stickerRepository.getRandomSticker();
    passport.addSticker(newSticker);
    notifyListeners();
  }
}