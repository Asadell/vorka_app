import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/routes/app_router.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/enums.dart';
import '../../core/extensions/context_extension.dart';
import '../../core/extensions/date_extension.dart';
import '../../models/proker_model.dart';
import '../../providers/proker_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/organization_provider.dart';

@RoutePage()
class ProkerListScreen extends StatefulWidget {
  const ProkerListScreen({super.key});

  @override
  State<ProkerListScreen> createState() => _ProkerListScreenState();
}

class _ProkerListScreenState extends State<ProkerListScreen> {
  String? _selectedDepartmentId;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadProker();
  }

  void _loadProker() {
    final authProvider = context.read<AuthProvider>();
    final orgId = authProvider.currentUser?.activeOrganizationId;

    if (orgId != null) {
      context.read<ProkerProvider>().watchProker(orgId);
    }
  }

  bool _canCreateProker() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;
    if (user == null) return false;

    final orgId = user.activeOrganizationId;
    if (orgId == null) return false;

    final userOrg = user.organizations.firstWhere(
      (org) => org.organizationId == orgId,
      orElse: () => throw Exception('Organization not found'),
    );

    // Super Admin, Ketua Org, Ketua Dept can create
    return userOrg.role.index <= 3; // superAdmin to ketuaDepartemen
  }

  int _getActiveCount() {
    return context.watch<ProkerProvider>().activeProkers.length;
  }

  int _getPlanningCount() {
    return context.watch<ProkerProvider>().planningProkers.length;
  }

  int _getCompletedCount() {
    return context.watch<ProkerProvider>().completedProkers.length;
  }

  @override
  Widget build(BuildContext context) {
    final orgProvider = context.watch<OrganizationProvider>();
    final departments = orgProvider.currentOrganization?.departments ?? [];

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Program Kerja'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(120),
            child: Column(
              children: [
                // Department filter
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButtonFormField<String?>(
                    value: _selectedDepartmentId,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.filter_list),
                      hintText: 'Semua Departemen',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Semua Departemen'),
                      ),
                      ...departments.map((dept) {
                        return DropdownMenuItem(
                          value: dept.id,
                          child: Text(dept.name),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedDepartmentId = value);
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Cari proker...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Tabs
                TabBar(
                  tabs: [
                    Tab(text: 'Aktif (${_getActiveCount()})'),
                    Tab(text: 'Perencanaan (${_getPlanningCount()})'),
                    Tab(text: 'Selesai (${_getCompletedCount()})'),
                  ],
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
        body: Consumer<ProkerProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null) {
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
                      'Gagal memuat proker',
                      style: AppTextStyles.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.error!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadProker,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            }

            return TabBarView(
              children: [
                _buildProkerList(provider.activeProkers),
                _buildProkerList(provider.planningProkers),
                _buildProkerList(provider.completedProkers),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_canCreateProker()) {
              context.router.push(const Step1InfoRoute());
            } else {
              context.showErrorSnackbar('Hanya ketua yang bisa buat proker');
            }
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildProkerList(List<ProkerModel> prokers) {
    // Apply filters
    var filtered = prokers;

    if (_selectedDepartmentId != null) {
      filtered = filtered
          .where((p) => p.departmentIds.contains(_selectedDepartmentId))
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (p) => p.title.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Tidak ada proker', style: AppTextStyles.titleMedium),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Coba kata kunci lain'
                  : 'Belum ada proker di kategori ini',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return ProkerCard(proker: filtered[index]);
      },
    );
  }
}

class ProkerCard extends StatelessWidget {
  final ProkerModel proker;

  const ProkerCard({super.key, required this.proker});

  Color _getStatusColor() {
    switch (proker.status) {
      case ProkerStatus.inProgress:
        return AppColors.statusSuccess;
      case ProkerStatus.planning:
      case ProkerStatus.awaitingApproval:
        return AppColors.statusWarning;
      case ProkerStatus.completed:
        return AppColors.textSecondary;
    }
  }

  int _getApprovedCount() {
    return proker.approvals
        .where((a) => a.status == ApprovalStatus.approved)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.router.push(ProkerDetailRoute(prokerId: proker.id));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster image
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                children: [
                  if (proker.posterUrl != null)
                    Image.network(
                      proker.posterUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                  else
                    Container(
                      color: AppColors.backgroundBase,
                      child: const Icon(Icons.image, size: 48),
                    ),

                  // Status badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        proker.status.displayName.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Department badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          proker.title,
                          style: AppTextStyles.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${proker.departmentIds.length} Dept',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Progress bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Progress', style: AppTextStyles.bodySmall),
                          Text(
                            '${proker.progress}%',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: proker.progress / 100,
                        backgroundColor: AppColors.backgroundBase,
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Meta info
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        proker.executionDate.toFormattedDate(),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: AppColors.statusSuccess,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_getApprovedCount()}/${proker.approvals.length} Disetujui',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
