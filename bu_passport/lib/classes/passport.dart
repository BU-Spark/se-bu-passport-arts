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
      0: 'assets/images/passport/empty_sticker.png',
      1: 'assets/images/passport/music_sticker.png',
      2: 'assets/images/passport/paintbrush_sticker.png',
      3: 'assets/images/passport/theater_sticker.png',
      // Add more mappings as needed
    };

    return imagePaths[id] ?? 'assets/images/passport/empty_sticker.png';
  }
}

class StickerRepository {
  final List<Sticker> allStickers = [
    Sticker(id: 1),
    Sticker(id: 2),
    Sticker(id: 3),
    Sticker(id: 4),
  ];

  Sticker getRandomSticker() {
    if (allStickers.isEmpty) {
      throw Exception('No stickers available');
    }
    final randomIndex = Random().nextInt(allStickers.length);
    return allStickers[randomIndex];
  }
}