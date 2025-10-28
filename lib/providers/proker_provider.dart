import 'package:flutter/material.dart';
import 'package:vorka_app2/core/constants/enums.dart';
import 'package:vorka_app2/models/proker_model.dart';
import 'package:vorka_app2/services/firestore_service.dart';

class ProkerProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<ProkerModel> _prokers = [];
  bool _isLoading = false;
  String? _error;

  List<ProkerModel> get prokers => _prokers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<ProkerModel> get activeProkers =>
      _prokers.where((p) => p.status == ProkerStatus.inProgress).toList();

  List<ProkerModel> get planningProkers => _prokers
      .where(
        (p) =>
            p.status == ProkerStatus.planning ||
            p.status == ProkerStatus.awaitingApproval,
      )
      .toList();

  List<ProkerModel> get completedProkers =>
      _prokers.where((p) => p.status == ProkerStatus.completed).toList();

  void watchProker(String orgId, {ProkerStatus? status}) {
    _firestoreService
        .watchProker(orgId, status: status)
        .listen(
          (prokers) {
            _prokers = prokers;
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

  Future<bool> createProker(ProkerModel proker) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestoreService.createProker(proker);

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

  Future<void> approveProker(
    String prokerId,
    int approvalIndex,
    String approvedBy,
  ) async {
    try {
      await _firestoreService.approveProker(
        prokerId,
        approvalIndex,
        approvedBy,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markPreparationComplete(
    String prokerId,
    String preparationId,
    String completedBy,
  ) async {
    try {
      await _firestoreService.markPreparationComplete(
        prokerId,
        preparationId,
        completedBy,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateProkerProgress(String prokerId, int progress) async {
    try {
      await _firestoreService.updateProkerProgress(prokerId, progress);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
