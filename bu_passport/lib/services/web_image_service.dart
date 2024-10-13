import 'package:flutter/cupertino.dart';

class WebImageService {
  // Helper function to build the correct ImageProvider
  static ImageProvider buildImageProvider(String imageUrl) {
    try {
      print(imageUrl);
      if (imageUrl == null || imageUrl.isEmpty) {
        return const AssetImage('assets/images/arts/placeholder-image.jpeg');
      }
      return NetworkImage(imageUrl);
    } catch (e) {
      return const AssetImage('assets/images/arts/placeholder-image.jpeg');
    }
  }
}