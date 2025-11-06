import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:vorka_app2/core/constants/firebase_constants.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFile({
    required File file,
    required String path,
    required String fileName,
  }) async {
    try {
      final ref = _storage.ref().child(path).child(fileName);
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Upload file failed: $e');
    }
  }

  Future<String> uploadProfilePicture(File file, String userId) async {
    final fileName = 'profile_$userId.jpg';
    return await uploadFile(
      file: file,
      path: FirebaseConstants.profilePicturesPath,
      fileName: fileName,
    );
  }

  Future<String> uploadOrgLogo(File file, String orgId) async {
    final fileName = 'logo_$orgId.jpg';
    return await uploadFile(
      file: file,
      path: FirebaseConstants.organizationLogosPath,
      fileName: fileName,
    );
  }

  Future<String> uploadTaskAttachment(File file, String taskId) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    return await uploadFile(
      file: file,
      path: '${FirebaseConstants.taskAttachmentsPath}/$taskId',
      fileName: fileName,
    );
  }

  Future<String> uploadMeetingAttachment(File file, String meetingId) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    return await uploadFile(
      file: file,
      path: '${FirebaseConstants.meetingAttachmentsPath}/$meetingId',
      fileName: fileName,
    );
  }

  Future<String> uploadProkerPoster(File file, String prokerId) async {
    final fileName = 'poster_$prokerId.jpg';
    return await uploadFile(
      file: file,
      path: FirebaseConstants.prokerPostersPath,
      fileName: fileName,
    );
  }

  Future<String> uploadProkerAttachment(File file, String prokerId) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    return await uploadFile(
      file: file,
      path: '${FirebaseConstants.prokerAttachmentsPath}/$prokerId',
      fileName: fileName,
    );
  }

  Future<String> uploadPdfDocument(File file, String userId) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    return await uploadFile(
      file: file,
      path: '${FirebaseConstants.pdfDocumentsPath}/$userId',
      fileName: fileName,
    );
  }

  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      throw Exception('Delete file failed: $e');
    }
  }
}
