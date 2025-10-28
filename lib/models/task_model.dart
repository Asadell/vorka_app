import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vorka_app2/core/constants/enums.dart';

class SubtaskModel {
  final String id;
  final String title;
  final bool isCompleted;
  final String? completedBy;
  final DateTime? completedAt;

  SubtaskModel({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.completedBy,
    this.completedAt,
  });

  factory SubtaskModel.fromMap(Map<String, dynamic> map) {
    return SubtaskModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
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
      'isCompleted': isCompleted,
      'completedBy': completedBy,
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
    };
  }
}

class TaskModel {
  final String id;
  final String organizationId;
  final String departmentId;
  final String title;
  final String description;
  final String assignedTo; // "INDIVIDUAL" or "DEPARTMENT"
  final List<String> assigneeIds;
  final String createdBy;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime deadline;
  final List<SubtaskModel> subtasks;
  final List<String> attachments;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.organizationId,
    required this.departmentId,
    required this.title,
    required this.description,
    required this.assignedTo,
    required this.assigneeIds,
    required this.createdBy,
    required this.priority,
    required this.status,
    required this.deadline,
    this.subtasks = const [],
    this.attachments = const [],
    required this.createdAt,
  });

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      organizationId: data['organizationId'] ?? '',
      departmentId: data['departmentId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      assignedTo: data['assignedTo'] ?? 'INDIVIDUAL',
      assigneeIds: List<String>.from(data['assigneeIds'] ?? []),
      createdBy: data['createdBy'] ?? '',
      priority: TaskPriority.fromString(data['priority'] ?? 'LOW'),
      status: TaskStatus.fromString(data['status'] ?? 'BACKLOG'),
      deadline: (data['deadline'] as Timestamp).toDate(),
      subtasks:
          (data['subtasks'] as List<dynamic>?)
              ?.map((e) => SubtaskModel.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      attachments: List<String>.from(data['attachments'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'organizationId': organizationId,
      'departmentId': departmentId,
      'title': title,
      'description': description,
      'assignedTo': assignedTo,
      'assigneeIds': assigneeIds,
      'createdBy': createdBy,
      'priority': priority.toFirestore(),
      'status': status.toFirestore(),
      'deadline': Timestamp.fromDate(deadline),
      'subtasks': subtasks.map((e) => e.toMap()).toList(),
      'attachments': attachments,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

extension SubtaskModelExtension on SubtaskModel {
  SubtaskModel copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    String? completedBy,
    DateTime? completedAt,
  }) {
    return SubtaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      completedBy: completedBy ?? this.completedBy,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

// TaskModel copyWith extension
extension TaskModelExtension on TaskModel {
  TaskModel copyWith({
    String? id,
    String? organizationId,
    String? departmentId,
    String? title,
    String? description,
    String? assignedTo,
    List<String>? assigneeIds,
    String? createdBy,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? deadline,
    List<SubtaskModel>? subtasks,
    List<String>? attachments,
    DateTime? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      departmentId: departmentId ?? this.departmentId,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedTo: assignedTo ?? this.assignedTo,
      assigneeIds: assigneeIds ?? this.assigneeIds,
      createdBy: createdBy ?? this.createdBy,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      deadline: deadline ?? this.deadline,
      subtasks: subtasks ?? this.subtasks,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
