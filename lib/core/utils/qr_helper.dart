import 'dart:convert';
import 'dart:math';

class QrHelper {
  static String generateOrgQrData(String orgId, String orgName) {
    return jsonEncode({
      'type': 'vorka_org',
      'orgId': orgId,
      'orgName': orgName,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  static String generateAttendanceQrData(String meetingId, String orgId) {
    return jsonEncode({
      'type': 'vorka_attendance',
      'meetingId': meetingId,
      'orgId': orgId,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  static Map<String, dynamic>? parseQrData(String qrData) {
    try {
      final data = jsonDecode(qrData) as Map<String, dynamic>;
      return data;
    } catch (e) {
      return null;
    }
  }

  static bool isValidOrgQr(Map<String, dynamic>? data) {
    if (data == null) return false;
    return data['type'] == 'vorka_org' &&
        data['orgId'] != null &&
        data['orgName'] != null;
  }

  static bool isValidAttendanceQr(Map<String, dynamic>? data) {
    if (data == null) return false;
    return data['type'] == 'vorka_attendance' &&
        data['meetingId'] != null &&
        data['orgId'] != null;
  }

  static String generateOrgId() {
    final random = Random();
    final digits = List.generate(5, (_) => random.nextInt(10)).join();
    return 'ORG-$digits';
  }

  static bool isAttendanceQrValid(
    Map<String, dynamic> data,
    DateTime meetingStart,
    DateTime meetingEnd,
  ) {
    final createdAt = data['createdAt'] as int?;
    if (createdAt == null) return false;

    final qrCreatedTime = DateTime.fromMillisecondsSinceEpoch(createdAt);
    final now = DateTime.now();

    // QR valid dari meeting start sampai 30 menit setelah meeting end
    final validUntil = meetingEnd.add(const Duration(minutes: 30));

    return now.isAfter(meetingStart) && now.isBefore(validUntil);
  }
}
