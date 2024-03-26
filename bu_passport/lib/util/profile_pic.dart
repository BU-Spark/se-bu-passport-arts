import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<File?> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  Future<String?> uploadImage(File imageFile) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    TaskSnapshot snapshot =
        await _storage.ref('profilePictures/$userId.jpg').putFile(imageFile);

    if (snapshot.state == TaskState.success) {
      return await snapshot.ref.getDownloadURL();
    }
    return null;
  }

  Future<void> updateUserProfilePicture(String imageUrl) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'profileImageUrl': imageUrl,
          });
    }
  }
}
