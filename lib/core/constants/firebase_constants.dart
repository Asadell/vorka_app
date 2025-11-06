class FirebaseConstants {
  // Collections
  static const String usersCollection = 'users';
  static const String organizationsCollection = 'organizations';
  static const String tasksCollection = 'tasks';
  static const String meetingsCollection = 'meetings';
  static const String prokerCollection = 'proker';
  static const String joinRequestsCollection = 'join_requests';
  static const String chatHistoryCollection = 'chat_history';

  // Subcollections
  static const String attendanceSubcollection = 'attendance';
  static const String messagesSubcollection = 'messages';

  // Storage Paths
  static const String profilePicturesPath = 'profile_pictures';
  static const String organizationLogosPath = 'organization_logos';
  static const String taskAttachmentsPath = 'task_attachments';
  static const String meetingAttachmentsPath = 'meeting_attachments';
  static const String prokerPostersPath = 'proker_posters';
  static const String prokerAttachmentsPath = 'proker_attachments';
  static const String pdfDocumentsPath = 'pdf_documents';

  // FCM Topics
  static String orgTopic(String orgId) => 'vorka_org_$orgId';
  static String deptTopic(String orgId, String deptId) =>
      'vorka_dept_${orgId}_$deptId';
}
