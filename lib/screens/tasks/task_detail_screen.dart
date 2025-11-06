import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/enums.dart';
import '../../core/extensions/context_extension.dart';
import '../../core/extensions/date_extension.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../providers/auth_provider.dart';

@RoutePage()
class TaskDetailScreen extends StatefulWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _commentController;

  TaskModel? _task;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _commentController = TextEditingController();
    _loadTask();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _loadTask() {
    // Get task from provider's task list
    final taskProvider = context.read<TaskProvider>();
    final task = taskProvider.tasks.firstWhere(
      (t) => t.id == widget.taskId,
      orElse: () => TaskModel(
        id: '',
        organizationId: '',
        departmentId: '',
        title: '',
        description: '',
        assignedTo: 'INDIVIDUAL',
        assigneeIds: [],
        createdBy: '',
        priority: TaskPriority.medium,
        status: TaskStatus.backlog,
        deadline: DateTime.now(),
        createdAt: DateTime.now(),
      ),
    );

    setState(() {
      _task = task;
      _titleController.text = task.title;
      _descriptionController.text = task.description;
      _isLoading = false;
    });
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

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.backlog:
        return Colors.grey;
      case TaskStatus.inProgress:
        return AppColors.accent;
      case TaskStatus.review:
        return AppColors.statusWarning;
      case TaskStatus.done:
        return AppColors.statusSuccess;
    }
  }

  Future<void> _updateStatus(TaskStatus newStatus) async {
    if (_task == null) return;

    await context.read<TaskProvider>().updateTaskStatus(_task!.id, newStatus);

    if (mounted) {
      context.showSuccessSnackbar('Status berhasil diupdate');
      setState(() {
        _task = _task!.copyWith(status: newStatus);
      });
    }
  }

  Future<void> _toggleSubtask(String subtaskId, bool isCompleted) async {
    if (_task == null) return;

    await context.read<TaskProvider>().toggleSubtask(
      _task!.id,
      subtaskId,
      isCompleted,
    );

    // Update local state
    setState(() {
      final subtasks = _task!.subtasks.map((sub) {
        if (sub.id == subtaskId) {
          return sub.copyWith(
            isCompleted: isCompleted,
            completedBy: isCompleted
                ? context.read<AuthProvider>().currentUser?.uid
                : null,
            completedAt: isCompleted ? DateTime.now() : null,
          );
        }
        return sub;
      }).toList();

      _task = _task!.copyWith(subtasks: subtasks);
    });
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Task?'),
        content: const Text('Task yang dihapus tidak dapat dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => context.router.pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => context.router.pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.statusError),
            child: const Text('Ya, Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await context.read<TaskProvider>().deleteTask(_task!.id);

      if (success && mounted) {
        context.showSuccessSnackbar('Task berhasil dihapus');
        context.router.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_task == null || _task!.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text('Task tidak ditemukan', style: AppTextStyles.titleMedium),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      );
    }

    final completedSubtasks = _task!.subtasks
        .where((s) => s.isCompleted)
        .length;
    final totalSubtasks = _task!.subtasks.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Task'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_outlined),
            onPressed: () {
              context.showSnackbar('Chat PDF coming soon!');
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        children: [
          // Title (editable)
          TextFormField(
            controller: _titleController,
            style: AppTextStyles.titleLarge,
            decoration: InputDecoration(
              labelText: 'Judul Task',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
            ),
            onChanged: (value) {
              // TODO: Auto-save with debounce
            },
          ),
          const SizedBox(height: AppSizes.paddingM),

          // Priority selector
          Text('Prioritas', style: AppTextStyles.labelLarge),
          const SizedBox(height: AppSizes.paddingS),
          Row(
            children: TaskPriority.values.map((priority) {
              final isSelected = _task!.priority == priority;
              final color = _getPriorityColor(priority);

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: OutlinedButton(
                    onPressed: () {
                      setState(
                        () => _task = _task!.copyWith(priority: priority),
                      );
                      // TODO: Save to Firestore
                    },
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
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSizes.paddingM),

          // Status dropdown
          Text('Status', style: AppTextStyles.labelLarge),
          const SizedBox(height: AppSizes.paddingS),
          DropdownButtonFormField<TaskStatus>(
            value: _task!.status,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
            ),
            items: TaskStatus.values.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getStatusColor(status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(status.displayName),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                _updateStatus(value);
              }
            },
          ),
          const SizedBox(height: AppSizes.paddingM),

          // Assignee (read-only)
          _buildInfoRow(
            icon: Icons.person,
            label: 'Ditugaskan ke',
            value: 'User', // TODO: Get actual user name
          ),
          const SizedBox(height: 12),

          // Deadline (read-only)
          _buildInfoRow(
            icon: Icons.calendar_today,
            label: 'Deadline',
            value: _task!.deadline.toFormattedDate(),
          ),
          const SizedBox(height: AppSizes.paddingM),

          // Description (editable)
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Deskripsi',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
            ),
            maxLines: 4,
            onChanged: (value) {
              // TODO: Auto-save with debounce
            },
          ),
          const SizedBox(height: AppSizes.paddingL),

          // Subtasks section
          if (totalSubtasks > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtasks', style: AppTextStyles.titleMedium),
                Text(
                  '$completedSubtasks/$totalSubtasks selesai',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingM),
            ..._task!.subtasks.map((subtask) {
              return CheckboxListTile(
                value: subtask.isCompleted,
                onChanged: (value) {
                  _toggleSubtask(subtask.id, value ?? false);
                },
                title: Text(
                  subtask.title,
                  style: subtask.isCompleted
                      ? TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: AppColors.textSecondary,
                        )
                      : null,
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              );
            }),
            const SizedBox(height: AppSizes.paddingL),
          ],

          // Comments section
          Text('Komentar (0)', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppSizes.paddingM),
          Text(
            'Fitur komentar akan segera hadir',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),

          // Comment input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Tulis komentar...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                  ),
                  enabled: false, // Disabled for now
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: null, // Disabled for now
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingL),

          // Attachments section
          Text('Lampiran', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppSizes.paddingM),
          Text(
            'Fitur lampiran akan diimplementasi dengan Digital Ocean Spaces',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingXl),

          // Action buttons
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                context.showSuccessSnackbar('Task berhasil diupdate');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Update Task',
                style: AppTextStyles.titleSmall.copyWith(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),

          SizedBox(
            height: 50,
            child: OutlinedButton(
              onPressed: _confirmDelete,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.statusError,
                side: const BorderSide(color: AppColors.statusError),
              ),
              child: Text(
                'Hapus Task',
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.statusError,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
