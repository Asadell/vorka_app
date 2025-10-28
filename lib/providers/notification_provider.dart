import 'package:flutter/material.dart';
import 'package:vorka_app2/core/constants/enums.dart';
import 'package:vorka_app2/models/join_request_model.dart';
import 'package:vorka_app2/services/firestore_service.dart';

class NotificationProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<JoinRequestModel> _joinRequests = [];
  bool _isLoading = false;
  String? _error;

  List<JoinRequestModel> get joinRequests => _joinRequests;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get pendingCount => _joinRequests.length;

  void watchJoinRequests(String orgId) {
    _firestoreService
        .watchJoinRequests(orgId)
        .listen(
          (requests) {
            _joinRequests = requests;
            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            _error = error.toString();
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  Future<bool> createJoinRequest({
    required String userId,
    required String userName,
    required String userEmail,
    String? userPhotoUrl,
    required String organizationId,
    String? departmentId,
    required UserRole requestedRole,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestoreService.createJoinRequest(
        userId: userId,
        userName: userName,
        userEmail: userEmail,
        userPhotoUrl: userPhotoUrl,
        organizationId: organizationId,
        departmentId: departmentId,
        requestedRole: requestedRole,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> approveJoinRequest(String requestId, String approvedBy) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestoreService.approveJoinRequest(requestId, approvedBy);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectJoinRequest(
    String requestId,
    String rejectedBy,
    String? notes,
  ) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestoreService.rejectJoinRequest(requestId, rejectedBy, notes);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
