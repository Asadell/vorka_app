import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vorka_app2/core/constants/enums.dart';

class ApprovalModel {
  final String id;
  final int order;
  final String title;
  final String requiredFrom; // "ROLE" or "PERSON"
  final String? roleRequired;
  final String? personId;
  final ApprovalStatus status;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? notes;

  ApprovalModel({
    required this.id,
    required this.order,
    required this.title,
    required this.requiredFrom,
    this.roleRequired,
    this.personId,
    required this.status,
    this.approvedBy,
    this.approvedAt,
    this.notes,
  });

  factory ApprovalModel.fromMap(Map<String, dynamic> map) {
    return ApprovalModel(
      id: map['id'] ?? '',
      order: map['order'] ?? 0,
      title: map['title'] ?? '',
      requiredFrom: map['requiredFrom'] ?? 'ROLE',
      roleRequired: map['roleRequired'],
      personId: map['personId'],
      status: ApprovalStatus.fromString(map['status'] ?? 'PENDING'),
      approvedBy: map['approvedBy'],
      approvedAt: map['approvedAt'] != null
          ? (map['approvedAt'] as Timestamp).toDate()
          : null,
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order': order,
      'title': title,
      'requiredFrom': requiredFrom,
      'roleRequired': roleRequired,
      'personId': personId,
      'status': status.toFirestore(),
      'approvedBy': approvedBy,
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'notes': notes,
    };
  }
}

class PreparationModel {
  final String id;
  final String title;
  final String assignedTo;
  final DateTime deadline;
  final String status; // "PENDING" or "COMPLETED"
  final String? completedBy;
  final DateTime? completedAt;

  PreparationModel({
    required this.id,
    required this.title,
    required this.assignedTo,
    required this.deadline,
    this.status = 'PENDING',
    this.completedBy,
    this.completedAt,
  });

  factory PreparationModel.fromMap(Map<String, dynamic> map) {
    return PreparationModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      assignedTo: map['assignedTo'] ?? '',
      deadline: (map['deadline'] as Timestamp).toDate(),
      status: map['status'] ?? 'PENDING',
      completedBy: map['completedBy'],
      completedAt: map['completedAt'] != null
          ? (map['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'assignedTo': assignedTo,
      'deadline': Timestamp.fromDate(deadline),
      'status': status,
      'completedBy': completedBy,
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
    };
  }
}

class ProkerModel {
  final String id;
  final String organizationId;
  final List<String> departmentIds;
  final String title;
  final String description;
  final String? posterUrl;
  final DateTime planningStart;
  final DateTime planningEnd;
  final DateTime executionDate;
  final Map<String, String> picPerDept; // deptId: userId
  final ProkerStatus status;
  final int progress; // 0-100
  final List<ApprovalModel> approvals;
  final List<PreparationModel> preparations;
  final List<String> attachments;
  final String createdBy;
  final DateTime createdAt;

  ProkerModel({
    required this.id,
    required this.organizationId,
    required this.departmentIds,
    required this.title,
    required this.description,
    this.posterUrl,
    required this.planningStart,
    required this.planningEnd,
    required this.executionDate,
    required this.picPerDept,
    required this.status,
    this.progress = 0,
    required this.approvals,
    required this.preparations,
    this.attachments = const [],
    required this.createdBy,
    required this.createdAt,
  });

  factory ProkerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProkerModel(
      id: doc.id,
      organizationId: data['organizationId'] ?? '',
      departmentIds: List<String>.from(data['departmentIds'] ?? []),
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      posterUrl: data['posterUrl'],
      planningStart: (data['planningStart'] as Timestamp).toDate(),
      planningEnd: (data['planningEnd'] as Timestamp).toDate(),
      executionDate: (data['executionDate'] as Timestamp).toDate(),
      picPerDept: Map<String, String>.from(data['picPerDept'] ?? {}),
      status: ProkerStatus.fromString(data['status'] ?? 'AWAITING_APPROVAL'),
      progress: data['progress'] ?? 0,
      approvals:
          (data['approvals'] as List<dynamic>?)
              ?.map((e) => ApprovalModel.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      preparations:
          (data['preparations'] as List<dynamic>?)
              ?.map((e) => PreparationModel.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      attachments: List<String>.from(data['attachments'] ?? []),
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'organizationId': organizationId,
      'departmentIds': departmentIds,
      'title': title,
      'description': description,
      'posterUrl': posterUrl,
      'planningStart': Timestamp.fromDate(planningStart),
      'planningEnd': Timestamp.fromDate(planningEnd),
      'executionDate': Timestamp.fromDate(executionDate),
      'picPerDept': picPerDept,
      'status': status.toFirestore(),
      'progress': progress,
      'approvals': approvals.map((e) => e.toMap()).toList(),
      'preparations': preparations.map((e) => e.toMap()).toList(),
      'attachments': attachments,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
