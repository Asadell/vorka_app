enum UserRole {
  superAdmin,
  ketuaOrganisasi,
  wakilOrganisasi,
  ketuaDepartemen,
  wakilDepartemen,
  anggota;

  String get displayName {
    switch (this) {
      case UserRole.superAdmin:
        return 'Super Admin';
      case UserRole.ketuaOrganisasi:
        return 'Ketua Organisasi';
      case UserRole.wakilOrganisasi:
        return 'Wakil Organisasi';
      case UserRole.ketuaDepartemen:
        return 'Ketua Departemen';
      case UserRole.wakilDepartemen:
        return 'Wakil Departemen';
      case UserRole.anggota:
        return 'Anggota';
    }
  }

  static UserRole fromString(String role) {
    switch (role.toUpperCase()) {
      case 'SUPER_ADMIN':
        return UserRole.superAdmin;
      case 'KETUA_ORGANISASI':
        return UserRole.ketuaOrganisasi;
      case 'WAKIL_ORGANISASI':
        return UserRole.wakilOrganisasi;
      case 'KETUA_DEPARTEMEN':
        return UserRole.ketuaDepartemen;
      case 'WAKIL_DEPARTEMEN':
        return UserRole.wakilDepartemen;
      default:
        return UserRole.anggota;
    }
  }

  String toFirestore() {
    switch (this) {
      case UserRole.superAdmin:
        return 'SUPER_ADMIN';
      case UserRole.ketuaOrganisasi:
        return 'KETUA_ORGANISASI';
      case UserRole.wakilOrganisasi:
        return 'WAKIL_ORGANISASI';
      case UserRole.ketuaDepartemen:
        return 'KETUA_DEPARTEMEN';
      case UserRole.wakilDepartemen:
        return 'WAKIL_DEPARTEMEN';
      case UserRole.anggota:
        return 'ANGGOTA';
    }
  }
}

enum TaskStatus {
  backlog,
  inProgress,
  review,
  done;

  String get displayName {
    switch (this) {
      case TaskStatus.backlog:
        return 'Backlog';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.review:
        return 'Review';
      case TaskStatus.done:
        return 'Done';
    }
  }

  static TaskStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'IN_PROGRESS':
        return TaskStatus.inProgress;
      case 'REVIEW':
        return TaskStatus.review;
      case 'DONE':
        return TaskStatus.done;
      default:
        return TaskStatus.backlog;
    }
  }

  String toFirestore() {
    switch (this) {
      case TaskStatus.backlog:
        return 'BACKLOG';
      case TaskStatus.inProgress:
        return 'IN_PROGRESS';
      case TaskStatus.review:
        return 'REVIEW';
      case TaskStatus.done:
        return 'DONE';
    }
  }
}

enum TaskPriority {
  low,
  medium,
  high;

  String get displayName {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }

  static TaskPriority fromString(String priority) {
    switch (priority.toUpperCase()) {
      case 'HIGH':
        return TaskPriority.high;
      case 'MEDIUM':
        return TaskPriority.medium;
      default:
        return TaskPriority.low;
    }
  }

  String toFirestore() => name.toUpperCase();
}

enum ProkerStatus {
  awaitingApproval,
  planning,
  inProgress,
  completed;

  String get displayName {
    switch (this) {
      case ProkerStatus.awaitingApproval:
        return 'Menunggu Persetujuan';
      case ProkerStatus.planning:
        return 'Perencanaan';
      case ProkerStatus.inProgress:
        return 'Sedang Berjalan';
      case ProkerStatus.completed:
        return 'Selesai';
    }
  }

  static ProkerStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'AWAITING_APPROVAL':
        return ProkerStatus.awaitingApproval;
      case 'PLANNING':
        return ProkerStatus.planning;
      case 'IN_PROGRESS':
        return ProkerStatus.inProgress;
      default:
        return ProkerStatus.completed;
    }
  }

  String toFirestore() {
    switch (this) {
      case ProkerStatus.awaitingApproval:
        return 'AWAITING_APPROVAL';
      case ProkerStatus.planning:
        return 'PLANNING';
      case ProkerStatus.inProgress:
        return 'IN_PROGRESS';
      case ProkerStatus.completed:
        return 'COMPLETED';
    }
  }
}

enum ApprovalStatus {
  pending,
  approved,
  rejected;

  String get displayName {
    switch (this) {
      case ApprovalStatus.pending:
        return 'Menunggu';
      case ApprovalStatus.approved:
        return 'Disetujui';
      case ApprovalStatus.rejected:
        return 'Ditolak';
    }
  }

  static ApprovalStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return ApprovalStatus.approved;
      case 'REJECTED':
        return ApprovalStatus.rejected;
      default:
        return ApprovalStatus.pending;
    }
  }

  String toFirestore() => name.toUpperCase();
}

enum JoinRequestStatus {
  pending,
  approved,
  rejected;

  String get displayName {
    switch (this) {
      case JoinRequestStatus.pending:
        return 'Menunggu';
      case JoinRequestStatus.approved:
        return 'Disetujui';
      case JoinRequestStatus.rejected:
        return 'Ditolak';
    }
  }

  static JoinRequestStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return JoinRequestStatus.approved;
      case 'REJECTED':
        return JoinRequestStatus.rejected;
      default:
        return JoinRequestStatus.pending;
    }
  }

  String toFirestore() => name.toUpperCase();
}
