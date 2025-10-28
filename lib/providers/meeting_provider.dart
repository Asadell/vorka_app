import 'package:flutter/material.dart';
import 'package:vorka_app2/models/meeting_model.dart';
import 'package:vorka_app2/services/firestore_service.dart';

class MeetingProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<MeetingModel> _meetings = [];
  bool _isLoading = false;
  String? _error;

  List<MeetingModel> get meetings => _meetings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<MeetingModel> get upcomingMeetings {
    final now = DateTime.now();
    return _meetings.where((m) => m.dateTime.isAfter(now)).toList();
  }

  List<MeetingModel> get pastMeetings {
    final now = DateTime.now();
    return _meetings.where((m) => m.dateTime.isBefore(now)).toList();
  }

  void watchMeetings(String orgId, {bool upcomingOnly = false}) {
    _firestoreService
        .watchMeetings(orgId, upcomingOnly: upcomingOnly)
        .listen(
          (meetings) {
            _meetings = meetings;
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

  Future<bool> createMeeting(MeetingModel meeting) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestoreService.createMeeting(meeting);

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

  Future<void> markAttendance(String meetingId, String userId) async {
    try {
      await _firestoreService.markAttendance(meetingId, userId);
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
