import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vorka_app2/core/constants/firebase_constants.dart';
import 'package:vorka_app2/models/user_model.dart';

class FcmService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    try {
      final userDoc = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .get();

      final user = UserModel.fromFirestore(userDoc);

      if (user.fcmToken != null) {
        // In production, call Cloud Function or use FCM Admin SDK
        // For now, just log
        print('Send notification to ${user.name}: $title');
      }
    } catch (e) {
      throw Exception('Send notification failed: $e');
    }
  }

  Future<void> sendNotificationToMultipleUsers({
    required List<String> userIds,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    for (final userId in userIds) {
      await sendNotificationToUser(
        userId: userId,
        title: title,
        body: body,
        data: data,
      );
    }
  }

  Future<void> sendNotificationToOrg({
    required String orgId,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    try {
      // Send to topic
      final topic = FirebaseConstants.orgTopic(orgId);
      print('Send notification to topic $topic: $title');
      // In production, call Cloud Function
    } catch (e) {
      throw Exception('Send org notification failed: $e');
    }
  }
}
