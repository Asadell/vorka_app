import 'package:flutter/material.dart';
import 'package:vorka_app2/models/organization_model.dart';
import 'package:vorka_app2/services/firestore_service.dart';

class OrganizationProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  OrganizationModel? _currentOrganization;
  List<OrganizationModel> _userOrganizations = [];
  bool _isLoading = false;
  String? _error;

  OrganizationModel? get currentOrganization => _currentOrganization;
  List<OrganizationModel> get userOrganizations => _userOrganizations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> createOrganization({
    required String name,
    required String description,
    required List<DepartmentModel> departments,
    required String createdBy,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final org = await _firestoreService.createOrganization(
        name: name,
        description: description,
        departments: departments,
        createdBy: createdBy,
      );

      _currentOrganization = org;
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

  Future<void> loadOrganization(String orgId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _currentOrganization = await _firestoreService.getOrganization(orgId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void watchOrganization(String orgId) {
    _firestoreService.watchOrganization(orgId).listen((org) {
      _currentOrganization = org;
      notifyListeners();
    });
  }

  Future<void> updateOrganization(
    String orgId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _firestoreService.updateOrganization(orgId, updates);
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
