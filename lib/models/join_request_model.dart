import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vorka_app2/core/constants/enums.dart';

class JoinRequestModel {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String? userPhotoUrl;
  final String organizationId;
  final String? departmentId;
  final UserRole requestedRole;
  final JoinRequestStatus status;
  final String? processedBy;
  final DateTime? processedAt;
  final String? notes;
  final DateTime createdAt;

  JoinRequestModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userPhotoUrl,
    required this.organizationId,
    this.departmentId,
    required this.requestedRole,
    required this.status,
    this.processedBy,
    this.processedAt,
    this.notes,
    required this.createdAt,
  });

  factory JoinRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return JoinRequestModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userEmail: data['userEmail'] ?? '',
      userPhotoUrl: data['userPhotoUrl'],
      organizationId: data['organizationId'] ?? '',
      departmentId: data['departmentId'],
      requestedRole: UserRole.fromString(data['requestedRole'] ?? 'ANGGOTA'),
      status: JoinRequestStatus.fromString(data['status'] ?? 'PENDING'),
      processedBy: data['processedBy'],
      processedAt: data['processedAt'] != null
          ? (data['processedAt'] as Timestamp).toDate()
          : null,
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhotoUrl': userPhotoUrl,
      'organizationId': organizationId,
      'departmentId': departmentId,
      'requestedRole': requestedRole.toFirestore(),
      'status': status.toFirestore(),
      'processedBy': processedBy,
      'processedAt': processedAt != null
          ? Timestamp.fromDate(processedAt!)
          : null,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
