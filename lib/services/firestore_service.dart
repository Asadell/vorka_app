import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vorka_app2/core/constants/enums.dart';
import 'package:vorka_app2/core/constants/firebase_constants.dart';
import 'package:vorka_app2/core/utils/qr_helper.dart';
import 'package:vorka_app2/models/join_request_model.dart';
import 'package:vorka_app2/models/meeting_model.dart';
import 'package:vorka_app2/models/organization_model.dart';
import 'package:vorka_app2/models/proker_model.dart';
import 'package:vorka_app2/models/task_model.dart';
import 'package:vorka_app2/models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ========================================
  // ORGANIZATION CRUD
  // ========================================

  Future<OrganizationModel> createOrganization({
    required String name,
    required String description,
    required List<DepartmentModel> departments,
    required String createdBy,
  }) async {
    try {
      final orgId = QrHelper.generateOrgId();

      final org = OrganizationModel(
        id: orgId,
        name: name,
        description: description,
        createdBy: createdBy,
        departments: departments,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(FirebaseConstants.organizationsCollection)
          .doc(orgId)
          .set(org.toFirestore());

      // Update user organizations
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(createdBy)
          .update({
            'organizations': FieldValue.arrayUnion([
              UserOrganization(
                organizationId: orgId,
                role: UserRole.superAdmin,
                status: 'ACTIVE',
                joinedAt: DateTime.now(),
              ).toMap(),
            ]),
            'activeOrganizationId': orgId,
          });

      return org;
    } catch (e) {
      throw Exception('Create organization failed: $e');
    }
  }

  Future<OrganizationModel?> getOrganization(String orgId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConstants.organizationsCollection)
          .doc(orgId)
          .get();

      if (!doc.exists) return null;
      return OrganizationModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Get organization failed: $e');
    }
  }

  Stream<OrganizationModel> watchOrganization(String orgId) {
    return _firestore
        .collection(FirebaseConstants.organizationsCollection)
        .doc(orgId)
        .snapshots()
        .map((doc) => OrganizationModel.fromFirestore(doc));
  }

  Future<void> updateOrganization(
    String orgId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _firestore
          .collection(FirebaseConstants.organizationsCollection)
          .doc(orgId)
          .update(updates);
    } catch (e) {
      throw Exception('Update organization failed: $e');
    }
  }

  // ========================================
  // JOIN REQUEST CRUD
  // ========================================

  Future<String> createJoinRequest({
    required String userId,
    required String userName,
    required String userEmail,
    String? userPhotoUrl,
    required String organizationId,
    String? departmentId,
    required UserRole requestedRole,
  }) async {
    try {
      final requestId = _firestore
          .collection(FirebaseConstants.joinRequestsCollection)
          .doc()
          .id;

      final request = JoinRequestModel(
        id: requestId,
        userId: userId,
        userName: userName,
        userEmail: userEmail,
        userPhotoUrl: userPhotoUrl,
        organizationId: organizationId,
        departmentId: departmentId,
        requestedRole: requestedRole,
        status: JoinRequestStatus.pending,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(FirebaseConstants.joinRequestsCollection)
          .doc(requestId)
          .set(request.toFirestore());

      return requestId;
    } catch (e) {
      throw Exception('Create join request failed: $e');
    }
  }

  Stream<List<JoinRequestModel>> watchJoinRequests(String orgId) {
    return _firestore
        .collection(FirebaseConstants.joinRequestsCollection)
        .where('organizationId', isEqualTo: orgId)
        .where('status', isEqualTo: 'PENDING')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => JoinRequestModel.fromFirestore(doc))
              .toList(),
        );
  }

  Future<void> approveJoinRequest(String requestId, String approvedBy) async {
    try {
      final requestDoc = await _firestore
          .collection(FirebaseConstants.joinRequestsCollection)
          .doc(requestId)
          .get();

      final request = JoinRequestModel.fromFirestore(requestDoc);

      // Update join request status
      await _firestore
          .collection(FirebaseConstants.joinRequestsCollection)
          .doc(requestId)
          .update({
            'status': 'APPROVED',
            'processedBy': approvedBy,
            'processedAt': Timestamp.now(),
          });

      // Handle role assignment logic
      if (request.requestedRole != UserRole.anggota) {
        await _handleRoleAssignment(request);
      }

      // Add user to organization
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(request.userId)
          .update({
            'organizations': FieldValue.arrayUnion([
              UserOrganization(
                organizationId: request.organizationId,
                role: request.requestedRole,
                departmentId: request.departmentId,
                status: 'ACTIVE',
                joinedAt: DateTime.now(),
              ).toMap(),
            ]),
            'activeOrganizationId': request.organizationId,
          });
    } catch (e) {
      throw Exception('Approve join request failed: $e');
    }
  }

  Future<void> _handleRoleAssignment(JoinRequestModel request) async {
    final orgDoc = await _firestore
        .collection(FirebaseConstants.organizationsCollection)
        .doc(request.organizationId)
        .get();

    final org = OrganizationModel.fromFirestore(orgDoc);
    final updates = <String, dynamic>{};

    if (request.requestedRole == UserRole.ketuaOrganisasi) {
      if (org.ketuaOrganisasi != null) {
        // Remove old ketua role
        await _removeUserRole(org.ketuaOrganisasi!, request.organizationId);
      }
      updates['ketuaOrganisasi'] = request.userId;
    } else if (request.requestedRole == UserRole.wakilOrganisasi) {
      if (org.wakilOrganisasi != null) {
        await _removeUserRole(org.wakilOrganisasi!, request.organizationId);
      }
      updates['wakilOrganisasi'] = request.userId;
    } else if (request.requestedRole == UserRole.ketuaDepartemen ||
        request.requestedRole == UserRole.wakilDepartemen) {
      // Handle department role
      if (request.departmentId != null) {
        final deptIndex = org.departments.indexWhere(
          (d) => d.id == request.departmentId,
        );

        if (deptIndex != -1) {
          final dept = org.departments[deptIndex];

          if (request.requestedRole == UserRole.ketuaDepartemen) {
            if (dept.ketuaDepartemen != null) {
              await _removeUserRole(
                dept.ketuaDepartemen!,
                request.organizationId,
              );
            }
            updates['departments.$deptIndex.ketuaDepartemen'] = request.userId;
          } else {
            if (dept.wakilDepartemen != null) {
              await _removeUserRole(
                dept.wakilDepartemen!,
                request.organizationId,
              );
            }
            updates['departments.$deptIndex.wakilDepartemen'] = request.userId;
          }
        }
      }
    }

    if (updates.isNotEmpty) {
      await _firestore
          .collection(FirebaseConstants.organizationsCollection)
          .doc(request.organizationId)
          .update(updates);
    }
  }

  Future<void> _removeUserRole(String userId, String orgId) async {
    // This is a simplified version - you may need more complex logic
    await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(userId)
        .update({
          'organizations': FieldValue.arrayRemove([orgId]),
        });
  }

  Future<void> rejectJoinRequest(
    String requestId,
    String rejectedBy,
    String? notes,
  ) async {
    try {
      await _firestore
          .collection(FirebaseConstants.joinRequestsCollection)
          .doc(requestId)
          .update({
            'status': 'REJECTED',
            'processedBy': rejectedBy,
            'processedAt': Timestamp.now(),
            'notes': notes,
          });
    } catch (e) {
      throw Exception('Reject join request failed: $e');
    }
  }

  // ========================================
  // TASK CRUD
  // ========================================

  Future<String> createTask(TaskModel task) async {
    try {
      final taskId = _firestore
          .collection(FirebaseConstants.tasksCollection)
          .doc()
          .id;

      await _firestore
          .collection(FirebaseConstants.tasksCollection)
          .doc(taskId)
          .set(task.toFirestore());

      return taskId;
    } catch (e) {
      throw Exception('Create task failed: $e');
    }
  }

  Stream<List<TaskModel>> watchTasks(String orgId, {String? userId}) {
    Query query = _firestore
        .collection(FirebaseConstants.tasksCollection)
        .where('organizationId', isEqualTo: orgId);

    if (userId != null) {
      query = query.where('assigneeIds', arrayContains: userId);
    }

    return query
        .orderBy('deadline')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList(),
        );
  }

  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    try {
      await _firestore
          .collection(FirebaseConstants.tasksCollection)
          .doc(taskId)
          .update({'status': status.toFirestore()});
    } catch (e) {
      throw Exception('Update task status failed: $e');
    }
  }

  Future<void> toggleSubtask(
    String taskId,
    String subtaskId,
    bool isCompleted,
  ) async {
    try {
      final taskDoc = await _firestore
          .collection(FirebaseConstants.tasksCollection)
          .doc(taskId)
          .get();

      final task = TaskModel.fromFirestore(taskDoc);
      final subtasks = task.subtasks.map((sub) {
        if (sub.id == subtaskId) {
          return SubtaskModel(
            id: sub.id,
            title: sub.title,
            isCompleted: isCompleted,
            completedBy: isCompleted
                ? FirebaseAuth.instance.currentUser?.uid
                : null,
            completedAt: isCompleted ? DateTime.now() : null,
          );
        }
        return sub;
      }).toList();

      await _firestore
          .collection(FirebaseConstants.tasksCollection)
          .doc(taskId)
          .update({'subtasks': subtasks.map((e) => e.toMap()).toList()});
    } catch (e) {
      throw Exception('Toggle subtask failed: $e');
    }
  }

  // ========================================
  // MEETING CRUD
  // ========================================

  Future<String> createMeeting(MeetingModel meeting) async {
    try {
      final meetingId = _firestore
          .collection(FirebaseConstants.meetingsCollection)
          .doc()
          .id;

      await _firestore
          .collection(FirebaseConstants.meetingsCollection)
          .doc(meetingId)
          .set(meeting.toFirestore());

      return meetingId;
    } catch (e) {
      throw Exception('Create meeting failed: $e');
    }
  }

  Stream<List<MeetingModel>> watchMeetings(
    String orgId, {
    bool upcomingOnly = false,
  }) {
    Query query = _firestore
        .collection(FirebaseConstants.meetingsCollection)
        .where('organizationId', isEqualTo: orgId);

    if (upcomingOnly) {
      query = query.where('dateTime', isGreaterThanOrEqualTo: Timestamp.now());
    }

    return query
        .orderBy('dateTime')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MeetingModel.fromFirestore(doc))
              .toList(),
        );
  }

  Future<void> markAttendance(String meetingId, String userId) async {
    try {
      await _firestore
          .collection(FirebaseConstants.meetingsCollection)
          .doc(meetingId)
          .collection(FirebaseConstants.attendanceSubcollection)
          .doc(userId)
          .set({
            'userId': userId,
            'checkedInAt': Timestamp.now(),
            'status': 'ATTENDED',
          });
    } catch (e) {
      throw Exception('Mark attendance failed: $e');
    }
  }

  // ========================================
  // PROKER CRUD
  // ========================================

  Future<String> createProker(ProkerModel proker) async {
    try {
      final prokerId = _firestore
          .collection(FirebaseConstants.prokerCollection)
          .doc()
          .id;

      await _firestore
          .collection(FirebaseConstants.prokerCollection)
          .doc(prokerId)
          .set(proker.toFirestore());

      return prokerId;
    } catch (e) {
      throw Exception('Create proker failed: $e');
    }
  }

  Stream<List<ProkerModel>> watchProker(String orgId, {ProkerStatus? status}) {
    Query query = _firestore
        .collection(FirebaseConstants.prokerCollection)
        .where('organizationId', isEqualTo: orgId);

    if (status != null) {
      query = query.where('status', isEqualTo: status.toFirestore());
    }

    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ProkerModel.fromFirestore(doc))
              .toList(),
        );
  }

  Future<void> approveProker(
    String prokerId,
    int approvalIndex,
    String approvedBy,
  ) async {
    try {
      final prokerDoc = await _firestore
          .collection(FirebaseConstants.prokerCollection)
          .doc(prokerId)
          .get();

      final proker = ProkerModel.fromFirestore(prokerDoc);
      final approvals = List<ApprovalModel>.from(proker.approvals);

      approvals[approvalIndex] = ApprovalModel(
        id: approvals[approvalIndex].id,
        order: approvals[approvalIndex].order,
        title: approvals[approvalIndex].title,
        requiredFrom: approvals[approvalIndex].requiredFrom,
        roleRequired: approvals[approvalIndex].roleRequired,
        personId: approvals[approvalIndex].personId,
        status: ApprovalStatus.approved,
        approvedBy: approvedBy,
        approvedAt: DateTime.now(),
      );

      final updates = <String, dynamic>{
        'approvals': approvals.map((e) => e.toMap()).toList(),
      };

      // Check if all approvals are approved
      if (approvals.every((a) => a.status == ApprovalStatus.approved)) {
        updates['status'] = ProkerStatus.planning.toFirestore();
      }

      await _firestore
          .collection(FirebaseConstants.prokerCollection)
          .doc(prokerId)
          .update(updates);
    } catch (e) {
      throw Exception('Approve proker failed: $e');
    }
  }

  Future<void> markPreparationComplete(
    String prokerId,
    String preparationId,
    String completedBy,
  ) async {
    try {
      final prokerDoc = await _firestore
          .collection(FirebaseConstants.prokerCollection)
          .doc(prokerId)
          .get();

      final proker = ProkerModel.fromFirestore(prokerDoc);
      final preparations = proker.preparations.map((prep) {
        if (prep.id == preparationId) {
          return PreparationModel(
            id: prep.id,
            title: prep.title,
            assignedTo: prep.assignedTo,
            deadline: prep.deadline,
            status: 'COMPLETED',
            completedBy: completedBy,
            completedAt: DateTime.now(),
          );
        }
        return prep;
      }).toList();

      // Calculate progress
      final completedCount = preparations
          .where((p) => p.status == 'COMPLETED')
          .length;
      final progress = ((completedCount / preparations.length) * 100).round();

      await _firestore
          .collection(FirebaseConstants.prokerCollection)
          .doc(prokerId)
          .update({
            'preparations': preparations.map((e) => e.toMap()).toList(),
            'progress': progress,
          });
    } catch (e) {
      throw Exception('Mark preparation complete failed: $e');
    }
  }

  Future<void> updateProkerProgress(String prokerId, int progress) async {
    try {
      final updates = <String, dynamic>{'progress': progress};

      if (progress == 100) {
        updates['status'] = ProkerStatus.completed.toFirestore();
      }

      await _firestore
          .collection(FirebaseConstants.prokerCollection)
          .doc(prokerId)
          .update(updates);
    } catch (e) {
      throw Exception('Update proker progress failed: $e');
    }
  }
}
