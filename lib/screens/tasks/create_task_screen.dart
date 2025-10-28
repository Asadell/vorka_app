import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/enums.dart';
import '../../core/extensions/context_extension.dart';
import '../../core/extensions/date_extension.dart';
import '../../core/utils/validators.dart';
import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../../models/organization_model.dart';
import '../../providers/task_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/organization_provider.dart';

@RoutePage()
class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _subtaskController = TextEditingController();

  String? _selectedUserId;
  String? _selectedDepartmentId;
  TaskPriority _priority = TaskPriority.medium;
  DateTime? _deadline;
  List<String> _subtasks = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }

  bool _canAssignToAllUsers() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;
    if (user == null) return false;

    final orgId = user.activeOrganizationId;
    if (orgId == null) return false;

    final userOrg = user.organizations.firstWhere(
      (org) => org.organizationId == orgId,
      orElse: () => UserOrganization(
        organizationId: '',
        role: UserRole.anggota,
        status: 'INACTIVE',
        joinedAt: DateTime.now(),
      ),
    );

    return userOrg.role == UserRole.superAdmin ||
        userOrg.role == UserRole.ketuaOrganisasi ||
        userOrg.role == UserRole.wakilOrganisasi;
  }

  bool _canAssignToDepartment() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;
    if (user == null) return false;

    final orgId = user.activeOrganizationId;
    if (orgId == null) return false;

    final userOrg = user.organizations.firstWhere(
      (org) => org.organizationId == orgId,
      orElse: () => UserOrganization(
        organizationId: '',
        role: UserRole.anggota,
        status: 'INACTIVE',
        joinedAt: DateTime.now(),
      ),
    );

    return userOrg.role == UserRole.superAdmin ||
        userOrg.role == UserRole.ketuaOrganisasi ||
        userOrg.role == UserRole.wakilOrganisasi ||
        userOrg.role == UserRole.ketuaDepartemen;
  }

  List<UserModel> _getAssignableUsers() {
    final authProvider = context.read<AuthProvider>();
    final orgProvider = context.read<OrganizationProvider>();
    final user = authProvider.currentUser;

    if (user == null) return [];

    final orgId = user.activeOrganizationId;
    if (orgId == null) return [];

    final userOrg = user.organizations.firstWhere(
      (org) => org.organizationId == orgId,
    );

    // For demo purposes, return mock users
    // In real app, you should fetch from Firestore
    return [
      UserModel(
        uid: 'user1',
        email: 'user1@test.com',
        name: 'Ahmad Rizki',
        createdAt: DateTime.now(),
      ),
      UserModel(
        uid: 'user2',
        email: 'user2@test.com',
        name: 'Budi Santoso',
        createdAt: DateTime.now(),
      ),
    ];
  }

  List<DepartmentModel> _getDepartments() {
    final orgProvider = context.read<OrganizationProvider>();
    final org = orgProvider.currentOrganization;

    if (org == null) return [];

    return org.departments;
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return AppColors.statusError;
      case TaskPriority.medium:
        return AppColors.statusWarning;
      case TaskPriority.low:
        return AppColors.statusSuccess;
    }
  }

  void _addSubtask() {
    if (_subtaskController.text.trim().isNotEmpty) {
      setState(() {
        _subtasks.add(_subtaskController.text.trim());
        _subtaskController.clear();
      });
    }
  }

  void _removeSubtask(int index) {
    setState(() {
      _subtasks.removeAt(index);
    });
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

  Future<void> _createTask() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedUserId == null) {
      context.showErrorSnackbar('Pilih pengguna yang akan ditugaskan');
      return;
    }

    if (_deadline == null) {
      context.showErrorSnackbar('Pilih tanggal deadline');
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser!;
    final orgId = user.activeOrganizationId!;

    final task = TaskModel(
      id: '', // Will be generated by Firestore
      organizationId: orgId,
      departmentId: _selectedDepartmentId ?? '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      assignedTo: 'INDIVIDUAL',
      assigneeIds: [_selectedUserId!],
      createdBy: user.uid,
      priority: _priority,
      status: TaskStatus.backlog,
      deadline: _deadline!,
      subtasks: _subtasks
          .map((title) => SubtaskModel(id: const Uuid().v4(), title: title))
          .toList(),
      createdAt: DateTime.now(),
    );

    final success = await context.read<TaskProvider>().createTask(task);

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        context.showSuccessSnackbar('Task berhasil dibuat');
        context.router.pop(context);
      }
    } else {
      if (mounted) {
        context.showErrorSnackbar('Gagal membuat task');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Buat Task Baru'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          children: [
            // Title field
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Judul Task *',
                hintText: 'Masukkan judul task',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
              ),
              validator: (value) => Validators.validateRequired(value, 'Judul'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSizes.paddingM),

            // Description field
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Deskripsi',
                hintText: 'Masukkan deskripsi task (opsional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
              ),
              maxLines: 4,
              textInputAction: TextInputAction.newline,
            ),
            const SizedBox(height: AppSizes.paddingM),

            // Assign to dropdown
            Text('Tugaskan ke *', style: AppTextStyles.labelLarge),
            const SizedBox(height: AppSizes.paddingS),
            DropdownButtonFormField<String>(
              value: _selectedUserId,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.person),
                hintText: 'Pilih pengguna',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
              ),
              items: _getAssignableUsers().map((user) {
                return DropdownMenuItem(
                  value: user.uid,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          user.name[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(user.name),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedUserId = value);
              },
              validator: (value) => value == null ? 'Pilih pengguna' : null,
            ),
            const SizedBox(height: AppSizes.paddingM),

            // Priority selector
            Text('Prioritas *', style: AppTextStyles.labelLarge),
            const SizedBox(height: AppSizes.paddingS),
            Row(
              children: TaskPriority.values.map((priority) {
                final isSelected = _priority == priority;
                final color = _getPriorityColor(priority);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: OutlinedButton(
                      onPressed: () => setState(() => _priority = priority),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isSelected
                            ? color.withOpacity(0.1)
                            : null,
                        side: BorderSide(
                          color: isSelected ? color : Colors.grey[300]!,
                        ),
                      ),
                      child: Text(
                        priority.displayName,
                        style: TextStyle(
                          color: isSelected ? color : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSizes.paddingM),

            // Deadline picker
            Text('Deadline *', style: AppTextStyles.labelLarge),
            const SizedBox(height: AppSizes.paddingS),
            InkWell(
              onTap: _pickDeadline,
              child: Container(
                padding: const EdgeInsets.all(AppSizes.paddingM),
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
            const SizedBox(height: AppSizes.paddingM),

            // Department dropdown (optional)
            if (_canAssignToDepartment()) ...[
              Text('Departemen (opsional)', style: AppTextStyles.labelLarge),
              const SizedBox(height: AppSizes.paddingS),
              DropdownButtonFormField<String>(
                value: _selectedDepartmentId,
                decoration: InputDecoration(
                  hintText: 'Pilih departemen',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                ),
                items: _getDepartments().map((dept) {
                  return DropdownMenuItem(
                    value: dept.id,
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(dept.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedDepartmentId = value);
                },
              ),
              const SizedBox(height: AppSizes.paddingM),
            ],

            // Subtasks
            Text('Subtasks (opsional)', style: AppTextStyles.labelLarge),
            const SizedBox(height: AppSizes.paddingS),

            // Subtask list
            if (_subtasks.isNotEmpty) ...[
              ..._subtasks.asMap().entries.map((entry) {
                return ListTile(
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text(entry.value),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => _removeSubtask(entry.key),
                  ),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                );
              }),
              const SizedBox(height: AppSizes.paddingS),
            ],

            // Add subtask input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _subtaskController,
                    decoration: InputDecoration(
                      hintText: 'Tambah subtask',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      ),
                    ),
                    onSubmitted: (_) => _addSubtask(),
                  ),
                ),
                const SizedBox(width: AppSizes.paddingS),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  color: AppColors.primary,
                  onPressed: _addSubtask,
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingXl),

            // Submit button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
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
                    : Text(
                        'Buat Task',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
