import 'package:cloud_firestore/cloud_firestore.dart';

class AttendeeModel {
  final String userId;
  final String status; // "PENDING", "ATTENDING", "NOT_ATTENDING"
  final DateTime? checkedInAt;

  AttendeeModel({
    required this.userId,
    this.status = 'PENDING',
    this.checkedInAt,
  });

  factory AttendeeModel.fromMap(Map<String, dynamic> map) {
    return AttendeeModel(
      userId: map['userId'] ?? '',
      status: map['status'] ?? 'PENDING',
      checkedInAt: map['checkedInAt'] != null
          ? (map['checkedInAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'status': status,
      'checkedInAt': checkedInAt != null
          ? Timestamp.fromDate(checkedInAt!)
          : null,
    };
  }
}

class MeetingModel {
  final String id;
  final String organizationId;
  final String title;
  final DateTime dateTime;
  final DateTime endTime;
  final String location;
  final String type;
  final List<String> attendeeIds;
  final List<String> attendeeDepartments;
  final List<String> agenda;
  final String createdBy;
  final String? notes;
  final List<String> attachments;
  final DateTime createdAt;

  MeetingModel({
    required this.id,
    required this.organizationId,
    required this.title,
    required this.dateTime,
    required this.endTime,
    required this.location,
    required this.type,
    required this.attendeeIds,
    required this.attendeeDepartments,
    required this.agenda,
    required this.createdBy,
    this.notes,
    this.attachments = const [],
    required this.createdAt,
  });

  factory MeetingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MeetingModel(
      id: doc.id,
      organizationId: data['organizationId'] ?? '',
      title: data['title'] ?? '',
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      location: data['location'] ?? '',
      type: data['type'] ?? '',
      attendeeIds: List<String>.from(data['attendeeIds'] ?? []),
      attendeeDepartments: List<String>.from(data['attendeeDepartments'] ?? []),
      agenda: List<String>.from(data['agenda'] ?? []),
      createdBy: data['createdBy'] ?? '',
      notes: data['notes'],
      attachments: List<String>.from(data['attachments'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'organizationId': organizationId,
      'title': title,
      'dateTime': Timestamp.fromDate(dateTime),
      'endTime': Timestamp.fromDate(endTime),
      'location': location,
      'type': type,
      'attendeeIds': attendeeIds,
      'attendeeDepartments': attendeeDepartments,
      'agenda': agenda,
      'createdBy': createdBy,
      'notes': notes,
      'attachments': attachments,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
