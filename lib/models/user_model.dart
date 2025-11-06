import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vorka_app2/core/constants/enums.dart';

class UserOrganization {
  final String organizationId;
  final UserRole role;
  final String? departmentId;
  final String status;
  final DateTime joinedAt;

  UserOrganization({
    required this.organizationId,
    required this.role,
    this.departmentId,
    required this.status,
    required this.joinedAt,
  });

  factory UserOrganization.fromMap(Map<String, dynamic> map) {
    return UserOrganization(
      organizationId: map['organizationId'] ?? '',
      role: UserRole.fromString(map['role'] ?? ''),
      departmentId: map['departmentId'],
      status: map['status'] ?? 'ACTIVE',
      joinedAt: (map['joinedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'organizationId': organizationId,
      'role': role.toFirestore(),
      'departmentId': departmentId,
      'status': status,
      'joinedAt': Timestamp.fromDate(joinedAt),
    };
  }
}

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String? photoURL;
  final String? phoneNumber;
  final String? fcmToken;
  final String? activeOrganizationId;
  final List<UserOrganization> organizations;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.photoURL,
    this.phoneNumber,
    this.fcmToken,
    this.activeOrganizationId,
    this.organizations = const [],
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      photoURL: data['photoURL'],
      phoneNumber: data['phoneNumber'],
      fcmToken: data['fcmToken'],
      activeOrganizationId: data['activeOrganizationId'],
      organizations:
          (data['organizations'] as List<dynamic>?)
              ?.map((e) => UserOrganization.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'photoURL': photoURL,
      'phoneNumber': phoneNumber,
      'fcmToken': fcmToken,
      'activeOrganizationId': activeOrganizationId,
      'organizations': organizations.map((e) => e.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? photoURL,
    String? phoneNumber,
    String? fcmToken,
    String? activeOrganizationId,
    List<UserOrganization>? organizations,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      photoURL: photoURL ?? this.photoURL,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fcmToken: fcmToken ?? this.fcmToken,
      activeOrganizationId: activeOrganizationId ?? this.activeOrganizationId,
      organizations: organizations ?? this.organizations,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
