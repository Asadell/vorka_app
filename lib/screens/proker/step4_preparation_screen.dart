import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:vorka_app2/core/constants/enums.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/extensions/context_extension.dart';
import '../../core/extensions/date_extension.dart';
import '../../models/proker_model.dart';
import '../../providers/proker_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/storage_service.dart';

@RoutePage()
class Step4PreparationScreen extends StatefulWidget {
  final String title;
  final String description;
  final List<String> departmentIds;
  final File? posterFile;
  final DateTime planningStart;
  final DateTime planningEnd;
  final DateTime executionDate;
  final List<ApprovalModel> approvals;

  const Step4PreparationScreen({
    super.key,
    required this.title,
    required this.description,
    required this.departmentIds,
    this.posterFile,
    required this.planningStart,
    required this.planningEnd,
    required this.executionDate,
    required this.approvals,
  });

  @override
  State<Step4PreparationScreen> createState() => _Step4PreparationScreenState();
}

class _Step4PreparationScreenState extends State<Step4PreparationScreen> {
  List<PreparationModel> _preparations = [];
  bool _isLoading = false;
  Map<String, String> _picPerDept = {};

  @override
  void initState() {
    super.initState();
    // Initialize PIC per dept
    for (var deptId in widget.departmentIds) {
      _picPerDept[deptId] = ''; // Will be filled by user
    }
  }

  void _addPreparation() {
    showDialog(
      context: context,
      builder: (context) => _PreparationDialog(
        onSave: (preparation) {
          setState(() {
            _preparations.add(preparation);
          });
        },
      ),
    );
  }

  void _removePreparation(int index) {
    setState(() {
      _preparations.removeAt(index);
    });
  }

  Future<void> _createProker() async {
    if (_preparations.isEmpty) {
      context.showErrorSnackbar('Tambahkan minimal 1 persiapan');
      return;
    }

    // Check if all PICs are assigned
    if (widget.departmentIds.length > 1) {
      for (var entry in _picPerDept.entries) {
        if (entry.value.isEmpty) {
          context.showErrorSnackbar('Assign PIC untuk semua departemen');
          return;
        }
      }
    }

    setState(() => _isLoading = true);

    try {
      // Upload poster if exists
      String? posterUrl;
      if (widget.posterFile != null) {
        final storageService = StorageService();
        posterUrl = await storageService.uploadProkerPoster(
          widget.posterFile!,
          const Uuid().v4(), // temp ID for upload
        );
      }

      final authProvider = context.read<AuthProvider>();
      final currentUser = authProvider.currentUser!;

      // If single dept, use current user as PIC
      if (widget.departmentIds.length == 1) {
        _picPerDept[widget.departmentIds.first] = currentUser.uid;
      }

      final proker = ProkerModel(
        id: '',
        organizationId: currentUser.activeOrganizationId!,
        departmentIds: widget.departmentIds,
        title: widget.title,
        description: widget.description,
        posterUrl: posterUrl,
        planningStart: widget.planningStart,
        planningEnd: widget.planningEnd,
        executionDate: widget.executionDate,
        picPerDept: _picPerDept,
        status: ProkerStatus.awaitingApproval,
        progress: 0,
        approvals: widget.approvals,
        preparations: _preparations,
        createdBy: currentUser.uid,
        createdAt: DateTime.now(),
      );

      final success = await context.read<ProkerProvider>().createProker(proker);

      setState(() => _isLoading = false);

      if (success) {
        if (mounted) {
          context.showSuccessSnackbar('Proker berhasil dibuat');
          // Pop all 4 steps
          context.router.popUntilRouteWithName('ProkerListRoute');
        }
      } else {
        if (mounted) {
          context.showErrorSnackbar('Gagal membuat proker');
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        context.showErrorSnackbar('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Proker Baru')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        children: [
          _buildProgressIndicator(4),
          const SizedBox(height: 24),

          // PIC per department (if multi-dept)
          if (widget.departmentIds.length > 1) ...[
            Text('PIC per Departemen', style: AppTextStyles.titleLarge),
            const SizedBox(height: 12),
            ...widget.departmentIds.map((deptId) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DropdownButtonFormField<String>(
                  value: _picPerDept[deptId]!.isEmpty
                      ? null
                      : _picPerDept[deptId],
                  decoration: InputDecoration(
                    labelText: 'PIC untuk Dept $deptId',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                  ),
                  items: [
                    // TODO: Load from dept members
                    const DropdownMenuItem(
                      value: 'user1',
                      child: Text('Ahmad Rizki'),
                    ),
                    const DropdownMenuItem(
                      value: 'user2',
                      child: Text('Budi Santoso'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _picPerDept[deptId] = value ?? '';
                    });
                  },
                ),
              );
            }),
            const SizedBox(height: 24),
          ],

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Persiapan', style: AppTextStyles.titleLarge),
              TextButton.icon(
                onPressed: _addPreparation,
                icon: const Icon(Icons.add),
                label: const Text('Tambah'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Daftar persiapan yang harus diselesaikan',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),

          if (_preparations.isEmpty)
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 48),
                  Icon(Icons.checklist, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada persiapan',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _addPreparation,
                    child: const Text('Tambah Persiapan'),
                  ),
                ],
              ),
            )
          else
            ..._preparations.asMap().entries.map((entry) {
              final index = entry.key;
              final prep = entry.value;
              return _buildPreparationCard(prep, index);
            }),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : () => context.router.pop(),
                  child: const Text('Kembali'),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading || _preparations.isEmpty
                      ? null
                      : _createProker,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.textSecondary,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text('Buat Proker'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(int currentStep) {
    return Row(
      children: List.generate(4, (index) {
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
            decoration: BoxDecoration(
              color: index < currentStep
                  ? AppColors.primary
                  : AppColors.backgroundBase,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPreparationCard(PreparationModel prep, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.backgroundBase,
              child: Icon(Icons.checklist, size: 16, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(prep.title, style: AppTextStyles.titleSmall),
                  const SizedBox(height: 4),
                  Text(
                    'Deadline: ${prep.deadline.toFormattedDate()}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'Assigned to: ${prep.assignedTo}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _removePreparation(index),
              color: AppColors.statusError,
            ),
          ],
        ),
      ),
    );
  }
}

class _PreparationDialog extends StatefulWidget {
  final Function(PreparationModel) onSave;

  const _PreparationDialog({required this.onSave});

  @override
  State<_PreparationDialog> createState() => _PreparationDialogState();
}

class _PreparationDialogState extends State<_PreparationDialog> {
  final _titleController = TextEditingController();
  DateTime? _deadline;
  String? _assignedTo;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() => _deadline = date);
    }
  }

  void _save() {
    if (_titleController.text.trim().isEmpty) {
      context.showErrorSnackbar('Judul tidak boleh kosong');
      return;
    }

    if (_deadline == null) {
      context.showErrorSnackbar('Pilih deadline');
      return;
    }

    if (_assignedTo == null) {
      context.showErrorSnackbar('Pilih person');
      return;
    }

    final preparation = PreparationModel(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      assignedTo: _assignedTo!,
      deadline: _deadline!,
      status: 'PENDING',
    );

    widget.onSave(preparation);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Persiapan'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Judul *',
                hintText: 'Contoh: Booking tempat',
              ),
            ),
            const SizedBox(height: 16),
            Text('Deadline *', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDeadline,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 12),
                    Text(
                      _deadline?.toFormattedDate() ?? 'Pilih tanggal',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: _deadline == null
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Assign ke *', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _assignedTo,
              decoration: const InputDecoration(hintText: 'Pilih person'),
              items: [
                // TODO: Load from org members
                const DropdownMenuItem(
                  value: 'user1',
                  child: Text('Ahmad Rizki'),
                ),
                const DropdownMenuItem(
                  value: 'user2',
                  child: Text('Budi Santoso'),
                ),
              ],
              onChanged: (value) {
                setState(() => _assignedTo = value);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        ElevatedButton(onPressed: _save, child: const Text('Simpan')),
      ],
    );
  }
}
