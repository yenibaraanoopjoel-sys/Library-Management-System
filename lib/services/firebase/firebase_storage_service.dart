import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

/// Low-level wrapper service for Firebase Storage operations (Book covers, user avatars)
class FirebaseStorageService {
  final FirebaseStorage _storage;

  FirebaseStorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  FirebaseStorage get storage => _storage;

  Future<String> uploadFile(
    String path,
    Uint8List bytes,
    String contentType,
  ) async {
    final ref = _storage.ref().child(path);
    final metadata = SettableMetadata(contentType: contentType);
    final uploadTask = await ref.putData(bytes, metadata);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<String> uploadProfileImage(
    String uid,
    Uint8List bytes, {
    String contentType = 'image/jpeg',
  }) async {
    final path = 'avatars/$uid.jpg';
    return await uploadFile(path, bytes, contentType);
  }

  Future<String> uploadBookCover(
    String bookId,
    Uint8List bytes, {
    String contentType = 'image/jpeg',
  }) async {
    final path = 'books/$bookId.jpg';
    return await uploadFile(path, bytes, contentType);
  }

  Future<String> getDownloadUrl(String path) async {
    return await _storage.ref().child(path).getDownloadURL();
  }

  Future<void> deleteFile(String path) async {
    try {
      await _storage.ref().child(path).delete();
    } catch (_) {
      // Ignore if file doesn't exist
    }
  }
}
