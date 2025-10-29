import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/enums.dart';
import '../../core/extensions/context_extension.dart';
import '../../core/extensions/date_extension.dart';
import '../../models/proker_model.dart';
import '../../providers/proker_provider.dart';
import '../../providers/auth_provider.dart';

@RoutePage()
class ProkerDetailScreen extends StatefulWidget {
  final String prokerId;

  const ProkerDetailScreen({super.key, required this.prokerId});

  @override
  State<ProkerDetailScreen> createState() => _ProkerDetailScreenState();
}

class _ProkerDetailScreenState extends State<ProkerDetailScreen> {
  ProkerModel? _proker;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProker();
  }

  Future<void> _loadProker() async {
    final prokerProvider = context.read<ProkerProvider>();
    final proker = prokerProvider.prokers.firstWhere(
      (p) => p.id == widget.prokerId,
      orElse: () => ProkerModel(
        id: '',
        organizationId: '',
        departmentIds: [],
        title: '',
        description: '',
        planningStart: DateTime.now(),
        planningEnd: DateTime.now(),
        executionDate: DateTime.now(),
        picPerDept: {},
        status: ProkerStatus.awaitingApproval,
        progress: 0,
        approvals: [],
        preparations: [],
        createdBy: '',
        createdAt: DateTime.now(),
      ),
    );

    setState(() {
      _proker = proker;
      _isLoading = false;
    });
  }

  bool _canApprove(ApprovalModel approval) {
    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser == null) return false;

    // Check if user is eligible approver
    if (approval.requiredFrom == 'ROLE') {
      final userOrg = currentUser.organizations.firstWhere(
        (org) => org.organizationId == currentUser.activeOrganizationId,
        orElse: () => throw Exception('Organization not found'),
      );
      return approval.roleRequired == userOrg.role.toFirestore();
    } else {
      return approval.personId == currentUser.uid;
    }
  }

  bool _isPreviousApproved(int currentIndex) {
    if (currentIndex == 0) return true;
    return _proker!.approvals[currentIndex - 1].status ==
        ApprovalStatus.approved;
  }

  Future<void> _approveProker(int index) async {
    final confirmed = await context.showConfirmDialog(
      title: 'Setujui Proker?',
      message: 'Anda akan menyetujui proker ini',
      confirmText: 'Ya, Setujui',
      cancelText: 'Batal',
    );

    if (confirmed != true) return;

    final currentUser = context.read<AuthProvider>().currentUser!;
    final success = await context.read<ProkerProvider>().approveProker(
      widget.prokerId,
      index,
      currentUser.uid,
    );

    if (success) {
      context.showSuccessSnackbar('Proker berhasil disetujui');
      _loadProker();
    } else {
      context.showErrorSnackbar('Gagal menyetujui proker');
    }
  }

  Future<void> _markPreparationComplete(String preparationId) async {
    final currentUser = context.read<AuthProvider>().currentUser!;
    final success = await context
        .read<ProkerProvider>()
        .markPreparationComplete(
          widget.prokerId,
          preparationId,
          currentUser.uid,
        );

    if (success) {
      context.showSuccessSnackbar('Persiapan selesai');
      _loadProker();
    } else {
      context.showErrorSnackbar('Gagal menandai persiapan');
    }
  }

  void _showUpdateProgressDialog() {
    int currentProgress = _proker?.progress ?? 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Progress'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${currentProgress}%', style: AppTextStyles.headlineSmall),
                Slider(
                  value: currentProgress.toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 100,
                  onChanged: (value) {
                    setState(() {
                      currentProgress = value.toInt();
                    });
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await context
                  .read<ProkerProvider>()
                  .updateProkerProgress(widget.prokerId, currentProgress);

              if (success) {
                context.showSuccessSnackbar('Progress berhasil diupdate');
                _loadProker();
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_proker == null || _proker!.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text('Proker tidak ditemukan', style: AppTextStyles.titleMedium),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.router.pop(),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Proker')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        children: [
          // Poster
          if (_proker!.posterUrl != null)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                child: Image.network(_proker!.posterUrl!, fit: BoxFit.cover),
              ),
            ),
          const SizedBox(height: 16),

          // Title & Status
          Text(_proker!.title, style: AppTextStyles.headlineSmall),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _proker!.status.displayName.toUpperCase(),
              style: TextStyle(
                color: _getStatusColor(),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Progress Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress Keseluruhan',
                        style: AppTextStyles.titleMedium,
                      ),
                      Text(
                        '${_proker!.progress}%',
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: _proker!.progress / 100,
                    backgroundColor: AppColors.backgroundBase,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                  const SizedBox(height: 12),
                  if (_canUpdateProgress())
                    ElevatedButton(
                      onPressed: _showUpdateProgressDialog,
                      child: const Text('Update Progress'),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Description
          Text('Deskripsi', style: AppTextStyles.titleLarge),
          const SizedBox(height: 8),
          Text(_proker!.description, style: AppTextStyles.bodyMedium),
          const SizedBox(height: 24),

          // Timeline
          Text('Timeline', style: AppTextStyles.titleLarge),
          const SizedBox(height: 12),
          _buildTimelineItem(
            'Perencanaan',
            '${_proker!.planningStart.toFormattedDate()} - ${_proker!.planningEnd.toFormattedDate()}',
            Icons.calendar_today,
          ),
          _buildTimelineItem(
            'Pelaksanaan',
            _proker!.executionDate.toFormattedDate(),
            Icons.event,
          ),
          const SizedBox(height: 24),

          // Approvals Section
          Text('Persetujuan', style: AppTextStyles.titleLarge),
          const SizedBox(height: 12),
          ..._proker!.approvals.asMap().entries.map((entry) {
            final index = entry.key;
            final approval = entry.value;
            return _buildApprovalCard(approval, index);
          }),
          const SizedBox(height: 24),

          // Preparations Section
          Text('Persiapan', style: AppTextStyles.titleLarge),
          const SizedBox(height: 12),
          ..._proker!.preparations.map((prep) {
            return _buildPreparationCard(prep);
          }),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (_proker!.status) {
      case ProkerStatus.inProgress:
        return AppColors.statusSuccess;
      case ProkerStatus.planning:
      case ProkerStatus.awaitingApproval:
        return AppColors.statusWarning;
      case ProkerStatus.completed:
        return AppColors.textSecondary;
    }
  }

  bool _canUpdateProgress() {
    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser == null) return false;
    return _proker!.createdBy == currentUser.uid ||
        _proker!.picPerDept.values.contains(currentUser.uid);
  }

  Widget _buildTimelineItem(String title, String date, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelLarge),
                const SizedBox(height: 4),
                Text(date, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalCard(ApprovalModel approval, int index) {
    final isCurrentUserApprover = _canApprove(approval);
    final isPrevApproved = _isPreviousApproved(index);
    final canApproveNow =
        isCurrentUserApprover &&
        isPrevApproved &&
        approval.status == ApprovalStatus.pending;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: _getApprovalStatusColor(approval.status),
                  child: Text(
                    '${approval.order}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(approval.title, style: AppTextStyles.titleSmall),
                      const SizedBox(height: 4),
                      Text(
                        approval.requiredFrom == 'ROLE'
                            ? approval.roleRequired!.replaceAll('_', ' ')
                            : 'Person: ${approval.personId}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildApprovalStatusBadge(approval.status),
              ],
            ),
            if (approval.status == ApprovalStatus.approved) ...[
              const SizedBox(height: 8),
              Text(
                'Disetujui pada ${approval.approvedAt?.toFormattedDate() ?? '-'}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.statusSuccess,
                ),
              ),
            ],
            if (!isPrevApproved &&
                approval.status == ApprovalStatus.pending) ...[
              const SizedBox(height: 8),
              Text(
                '⚠️ Menunggu persetujuan sebelumnya',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.statusWarning,
                ),
              ),
            ],
            if (canApproveNow) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _approveProker(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.statusSuccess,
                      ),
                      child: const Text('Setujui'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        context.showSnackbar('Fitur tolak coming soon');
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.statusError,
                      ),
                      child: const Text('Tolak'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPreparationCard(PreparationModel prep) {
    final currentUser = context.read<AuthProvider>().currentUser;
    final canComplete =
        currentUser != null &&
        prep.assignedTo == currentUser.uid &&
        prep.status == 'PENDING';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Checkbox(
              value: prep.status == 'COMPLETED',
              onChanged: canComplete
                  ? (value) {
                      if (value == true) {
                        _markPreparationComplete(prep.id);
                      }
                    }
                  : null,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prep.title,
                    style: AppTextStyles.titleSmall.copyWith(
                      decoration: prep.status == 'COMPLETED'
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Deadline: ${prep.deadline.toFormattedDate()}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (prep.status == 'COMPLETED')
                    Text(
                      'Selesai pada ${prep.completedAt?.toFormattedDate() ?? '-'}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.statusSuccess,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getApprovalStatusColor(ApprovalStatus status) {
    switch (status) {
      case ApprovalStatus.pending:
        return AppColors.statusWarning;
      case ApprovalStatus.approved:
        return AppColors.statusSuccess;
      case ApprovalStatus.rejected:
        return AppColors.statusError;
    }
  }

  Widget _buildApprovalStatusBadge(ApprovalStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getApprovalStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _getApprovalStatusColor(status),
        ),
      ),
    );
  }
}
