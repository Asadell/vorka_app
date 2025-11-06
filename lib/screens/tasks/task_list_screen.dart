import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vorka_app2/config/routes/app_router.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/enums.dart';
import '../../core/extensions/context_extension.dart';
import '../../core/extensions/date_extension.dart';
import '../../core/extensions/string_extension.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../providers/auth_provider.dart';

enum TaskFilter { all, myTasks, highPriority }

@RoutePage()
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  TaskFilter _selectedFilter = TaskFilter.all;
  String _sortBy = 'deadline'; // deadline, priority, status

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    final authProvider = context.read<AuthProvider>();
    final orgId = authProvider.currentUser?.activeOrganizationId;

    if (orgId != null) {
      context.read<TaskProvider>().watchTasks(orgId);
    }
  }

  List<TaskModel> _getFilteredTasks(List<TaskModel> tasks) {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.uid;

    List<TaskModel> filtered = tasks;

    // Apply filter
    switch (_selectedFilter) {
      case TaskFilter.myTasks:
        filtered = filtered
            .where((t) => t.assigneeIds.contains(userId))
            .toList();
        break;
      case TaskFilter.highPriority:
        filtered = filtered
            .where((t) => t.priority == TaskPriority.high)
            .toList();
        break;
      case TaskFilter.all:
        break;
    }

    // Apply sort
    switch (_sortBy) {
      case 'deadline':
        filtered.sort((a, b) => a.deadline.compareTo(b.deadline));
        break;
      case 'priority':
        filtered.sort((a, b) => b.priority.index.compareTo(a.priority.index));
        break;
      case 'status':
        filtered.sort((a, b) => a.status.index.compareTo(b.status.index));
        break;
    }

    return filtered;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tugas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Navigate to notifications
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingM,
              vertical: AppSizes.paddingS,
            ),
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Semua',
                  isSelected: _selectedFilter == TaskFilter.all,
                  onSelected: () =>
                      setState(() => _selectedFilter = TaskFilter.all),
                ),
                const SizedBox(width: AppSizes.paddingS),
                _buildFilterChip(
                  label: 'Task Saya',
                  isSelected: _selectedFilter == TaskFilter.myTasks,
                  onSelected: () =>
                      setState(() => _selectedFilter = TaskFilter.myTasks),
                ),
                const SizedBox(width: AppSizes.paddingS),
                _buildFilterChip(
                  label: 'Prioritas Tinggi',
                  isSelected: _selectedFilter == TaskFilter.highPriority,
                  onSelected: () =>
                      setState(() => _selectedFilter = TaskFilter.highPriority),
                ),
                const SizedBox(width: AppSizes.paddingS),
                // Sort button
                PopupMenuButton<String>(
                  icon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.sort, size: 16),
                      const SizedBox(width: 4),
                      Text('Urutkan', style: AppTextStyles.labelSmall),
                    ],
                  ),
                  onSelected: (value) {
                    setState(() => _sortBy = value);
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'deadline',
                      child: Text('Deadline', style: AppTextStyles.bodyMedium),
                    ),
                    PopupMenuItem(
                      value: 'priority',
                      child: Text('Prioritas', style: AppTextStyles.bodyMedium),
                    ),
                    PopupMenuItem(
                      value: 'status',
                      child: Text('Status', style: AppTextStyles.bodyMedium),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Task list grouped by status
          Expanded(
            child: Consumer<TaskProvider>(
              builder: (context, taskProvider, child) {
                if (taskProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (taskProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Gagal memuat tugas',
                          style: AppTextStyles.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          taskProvider.error!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadTasks,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }

                final filteredTasks = _getFilteredTasks(taskProvider.tasks);

                if (filteredTasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada tugas',
                          style: AppTextStyles.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Buat tugas baru dengan tombol + di bawah',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                // Group tasks by status
                final groupedTasks = <TaskStatus, List<TaskModel>>{};
                for (final status in TaskStatus.values) {
                  groupedTasks[status] = filteredTasks
                      .where((t) => t.status == status)
                      .toList();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppSizes.paddingM),
                  itemCount: TaskStatus.values.length,
                  itemBuilder: (context, index) {
                    final status = TaskStatus.values[index];
                    final tasks = groupedTasks[status] ?? [];

                    if (tasks.isEmpty) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status header
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSizes.paddingS,
                          ),
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
                              Text(
                                status.displayName,
                                style: AppTextStyles.titleSmall,
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    status,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${tasks.length}',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: _getStatusColor(status),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Task cards
                        ...tasks.map(
                          (task) => _TaskCard(
                            task: task,
                            priorityColor: _getPriorityColor(task.priority),
                            onTap: () => _navigateToDetail(task.id),
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingM),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreate,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: AppColors.primary.withOpacity(0.1),
      checkmarkColor: AppColors.primary,
      labelStyle: AppTextStyles.labelMedium.copyWith(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
    );
  }

  void _navigateToCreate() {
    context.router.push(const CreateTaskRoute());
  }

  void _navigateToDetail(String taskId) {
    context.router.push(TaskDetailRoute(taskId: taskId));
  }
}

class _TaskCard extends StatelessWidget {
  final TaskModel task;
  final Color priorityColor;
  final VoidCallback onTap;

  const _TaskCard({
    required this.task,
    required this.priorityColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingS),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Priority dot + Title
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: priorityColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      task.title,
                      style: AppTextStyles.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  task.description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 12),

              // Assignee avatars
              SizedBox(
                height: 32,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: task.assigneeIds.length > 3
                      ? 4
                      : task.assigneeIds.length,
                  itemBuilder: (context, index) {
                    if (index == 3) {
                      return CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Text(
                          '+${task.assigneeIds.length - 3}',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          'U',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Footer
              Row(
                children: [
                  // Comments count
                  Icon(
                    Icons.comment_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '0',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Attachments count
                  Icon(
                    Icons.attach_file,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${task.attachments.length}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const Spacer(),

                  // Deadline
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    task.deadline.toRelativeDate(),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
