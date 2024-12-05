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
  late final String imagePath;

  Sticker({required this.id}) {
    imagePath = _getImagePathById(id);
  }

  String _getImagePathById(int id) {
    // Map of id to image paths
    const Map<int, String> imagePaths = {
      0: 'assets/images/stickers/empty_sticker.png',
      1: 'assets/images/stickers/music.png',
      2: 'assets/images/stickers/art.png',
      3: 'assets/images/stickers/theater.png',
      4: 'assets/images/stickers/free.png',
      5: 'assets/images/stickers/dance.png',
      6: 'assets/images/stickers/crafting.png',
      7: 'assets/images/stickers/culinary.png',
      8: 'assets/images/stickers/film.png',
      9: 'assets/images/stickers/literature.png',
      // Add more mappings as needed
    };

    return imagePaths[id] ?? 'assets/images/passport/empty_sticker.png';
  }
}

class StickerRepository {
  final List<Sticker> allStickers = [
    Sticker(id: 0),
    Sticker(id: 1),
    Sticker(id: 2),
    Sticker(id: 3),
    Sticker(id: 4),
    Sticker(id: 5),
    Sticker(id: 6),
    Sticker(id: 7),
    Sticker(id: 8),
    Sticker(id: 9),
  ];

  Sticker getRandomSticker() {
    if (allStickers.isEmpty) {
      throw Exception('No stickers available');
    }
    final randomIndex = Random().nextInt(allStickers.length);
    return allStickers[randomIndex];
  }
}