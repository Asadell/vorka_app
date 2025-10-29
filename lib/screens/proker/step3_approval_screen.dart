import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../config/routes/app_router.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/enums.dart';
import '../../core/extensions/context_extension.dart';
import '../../models/proker_model.dart';
import '../../providers/organization_provider.dart';

@RoutePage()
class Step3ApprovalScreen extends StatefulWidget {
  final String title;
  final String description;
  final List<String> departmentIds;
  final File? posterFile;
  final DateTime planningStart;
  final DateTime planningEnd;
  final DateTime executionDate;

  const Step3ApprovalScreen({
    super.key,
    required this.title,
    required this.description,
    required this.departmentIds,
    this.posterFile,
    required this.planningStart,
    required this.planningEnd,
    required this.executionDate,
  });

  @override
  State<Step3ApprovalScreen> createState() => _Step3ApprovalScreenState();
}

class _Step3ApprovalScreenState extends State<Step3ApprovalScreen> {
  List<ApprovalModel> _approvals = [];

  void _addApproval() {
    showDialog(
      context: context,
      builder: (context) => _ApprovalDialog(
        order: _approvals.length + 1,
        onSave: (approval) {
          setState(() {
            _approvals.add(approval);
          });
        },
      ),
    );
  }

  void _removeApproval(int index) {
    setState(() {
      _approvals.removeAt(index);
      // Re-order
      for (int i = 0; i < _approvals.length; i++) {
        _approvals[i] = ApprovalModel(
          id: _approvals[i].id,
          order: i + 1,
          title: _approvals[i].title,
          requiredFrom: _approvals[i].requiredFrom,
          roleRequired: _approvals[i].roleRequired,
          personId: _approvals[i].personId,
          status: _approvals[i].status,
        );
      }
    });
  }

  void _goToStep4() {
    if (_approvals.isEmpty) {
      context.showErrorSnackbar('Tambahkan minimal 1 persetujuan');
      return;
    }

    context.router.push(
      Step4PreparationRoute(
        title: widget.title,
        description: widget.description,
        departmentIds: widget.departmentIds,
        posterFile: widget.posterFile,
        planningStart: widget.planningStart,
        planningEnd: widget.planningEnd,
        executionDate: widget.executionDate,
        approvals: _approvals,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Proker Baru')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        children: [
          _buildProgressIndicator(3),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Persetujuan', style: AppTextStyles.titleLarge),
              TextButton.icon(
                onPressed: _addApproval,
                icon: const Icon(Icons.add),
                label: const Text('Tambah'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Persetujuan akan diproses secara berurutan',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),

          if (_approvals.isEmpty)
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 48),
                  Icon(Icons.approval, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada persetujuan',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _addApproval,
                    child: const Text('Tambah Persetujuan'),
                  ),
                ],
              ),
            )
          else
            ..._approvals.asMap().entries.map((entry) {
              final index = entry.key;
              final approval = entry.value;
              return _buildApprovalCard(approval, index);
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
                  onPressed: () => context.router.pop(),
                  child: const Text('Kembali'),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _approvals.isNotEmpty ? _goToStep4 : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.textSecondary,
                  ),
                  child: const Text('Lanjut'),
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

  Widget _buildApprovalCard(ApprovalModel approval, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
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
                        ? 'Dari: ${approval.roleRequired}'
                        : 'Dari: Person ID ${approval.personId}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _removeApproval(index),
              color: AppColors.statusError,
            ),
          ],
        ),
      ),
    );
  }
}

class _ApprovalDialog extends StatefulWidget {
  final int order;
  final Function(ApprovalModel) onSave;

  const _ApprovalDialog({required this.order, required this.onSave});

  @override
  State<_ApprovalDialog> createState() => _ApprovalDialogState();
}

class _ApprovalDialogState extends State<_ApprovalDialog> {
  final _titleController = TextEditingController();
  String _requiredFrom = 'ROLE';
  String? _selectedRole;
  String? _selectedPersonId;

  final List<String> _availableRoles = [
    'KETUA_ORGANISASI',
    'WAKIL_ORGANISASI',
    'KETUA_DEPARTEMEN',
    'BENDAHARA',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _save() {
    if (_titleController.text.trim().isEmpty) {
      context.showErrorSnackbar('Judul tidak boleh kosong');
      return;
    }

    if (_requiredFrom == 'ROLE' && _selectedRole == null) {
      context.showErrorSnackbar('Pilih role');
      return;
    }

    if (_requiredFrom == 'PERSON' && _selectedPersonId == null) {
      context.showErrorSnackbar('Pilih person');
      return;
    }

    final approval = ApprovalModel(
      id: const Uuid().v4(),
      order: widget.order,
      title: _titleController.text.trim(),
      requiredFrom: _requiredFrom,
      roleRequired: _selectedRole,
      personId: _selectedPersonId,
      status: ApprovalStatus.pending,
    );

    widget.onSave(approval);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Persetujuan #${widget.order}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Judul *',
                hintText: 'Contoh: Persetujuan Ketua BEM',
              ),
            ),
            const SizedBox(height: 16),
            Text('Persetujuan dari', style: AppTextStyles.labelLarge),
            RadioListTile<String>(
              value: 'ROLE',
              groupValue: _requiredFrom,
              onChanged: (value) {
                setState(() {
                  _requiredFrom = value!;
                  _selectedPersonId = null;
                });
              },
              title: const Text('Role'),
              contentPadding: EdgeInsets.zero,
            ),
            if (_requiredFrom == 'ROLE')
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(hintText: 'Pilih role'),
                items: _availableRoles.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role.replaceAll('_', ' ')),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedRole = value);
                },
              ),
            RadioListTile<String>(
              value: 'PERSON',
              groupValue: _requiredFrom,
              onChanged: (value) {
                setState(() {
                  _requiredFrom = value!;
                  _selectedRole = null;
                });
              },
              title: const Text('Person'),
              contentPadding: EdgeInsets.zero,
            ),
            if (_requiredFrom == 'PERSON')
              DropdownButtonFormField<String>(
                value: _selectedPersonId,
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
                  setState(() => _selectedPersonId = value);
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
