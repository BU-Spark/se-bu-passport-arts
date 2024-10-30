import 'dart:math';

class Passport {
  static const int maxStickersPerPage = 6;
  List<List<Sticker>> pages = [[]];

  void addSticker(Sticker sticker) {
    List<Sticker> currentPage = pages.last;
    if (currentPage.length >= maxStickersPerPage) {
      currentPage = [];
      pages.add(currentPage);
    }
    currentPage.add(sticker);
  }
}

class Sticker {
  final int id;
  final String imagePath;

  Sticker({required this.id, required this.imagePath});
}

class StickerRepository {
  final List<Sticker> allStickers = [
    Sticker(id: 1, imagePath: '../assets/images/passport/sticker_1.png'),
    Sticker(id: 2, imagePath: '../assets/images/passport/sticker_2.png'),
    Sticker(id: 3, imagePath: '../assets/images/passport/sticker_3.png'),
    Sticker(id: 4, imagePath: '../assets/images/passport/sticker_4.png')
  ];

  Sticker getRandomSticker() {
    if (allStickers.isEmpty) {
      throw Exception('No stickers available');
    }
    final randomIndex = Random().nextInt(allStickers.length);
    return allStickers[randomIndex];
  }
}