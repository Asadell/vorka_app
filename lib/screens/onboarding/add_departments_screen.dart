import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vorka_app2/config/routes/app_router.dart';
import 'package:vorka_app2/config/theme/app_colors.dart';
import 'package:vorka_app2/core/constants/app_sizes.dart';
import 'package:vorka_app2/models/organization_model.dart';
import 'package:vorka_app2/providers/auth_provider.dart';
import 'package:vorka_app2/providers/organization_provider.dart';

@RoutePage()
class AddDepartmentsScreen extends StatefulWidget {
  const AddDepartmentsScreen({
    super.key,
    required this.orgName,
    required this.orgDescription,
  });

  final String orgName;
  final String orgDescription;

  @override
  State<AddDepartmentsScreen> createState() => _AddDepartmentsScreenState();
}

class _AddDepartmentsScreenState extends State<AddDepartmentsScreen> {
  final _departments = <String>[];
  final _departmentController = TextEditingController();

  @override
  void dispose() {
    _departmentController.dispose();
    super.dispose();
  }

  void _addDepartment() {
    if (_departmentController.text.isNotEmpty) {
      setState(() {
        _departments.add(_departmentController.text.trim());
        _departmentController.clear();
      });
    }
  }

  void _removeDepartment(int index) {
    setState(() {
      _departments.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (_departments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tambahkan minimal 1 departemen'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final userId = context.read<AuthProvider>().currentUser?.uid;
    if (userId == null) return;

    // Create department models
    final deptModels = _departments
        .asMap()
        .entries
        .map(
          (entry) => DepartmentModel(
            id:
                DateTime.now().millisecondsSinceEpoch.toString() +
                entry.key.toString(),
            name: entry.value,
          ),
        )
        .toList();

    final orgProvider = context.read<OrganizationProvider>();
    final success = await orgProvider.createOrganization(
      name: widget.orgName,
      description: widget.orgDescription,
      departments: deptModels,
      createdBy: userId,
    );

    if (!mounted) return;

    if (success) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Organisasi berhasil dibuat!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Wait a bit for the message to show
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // Refresh auth state to get updated user data
      await context.read<AuthProvider>().loadCurrentUser();

      if (!mounted) return;

      // Navigate to home
      context.router.replaceAll([const MainRoute()]);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(orgProvider.error ?? 'Gagal membuat organisasi'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Departemen')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Langkah 2 dari 2',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSizes.paddingXs),
            Text(
              'Tambahkan Departemen',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.paddingS),
            Text(
              'Minimal 1 departemen',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSizes.paddingL),

            // Add Department Field
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _departmentController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Departemen',
                      hintText: 'Contoh: PSDM',
                      prefixIcon: Icon(Icons.group),
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _addDepartment(),
                  ),
                ),
                const SizedBox(width: AppSizes.paddingM),
                IconButton(
                  onPressed: _addDepartment,
                  icon: const Icon(Icons.add_circle),
                  color: AppColors.primary,
                  iconSize: AppSizes.iconL,
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingL),

            // Departments List
            if (_departments.isNotEmpty) ...[
              Text(
                'Departemen (${_departments.length})',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSizes.paddingM),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _departments.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSizes.paddingS),
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(_departments[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: Colors.red,
                        onPressed: () => _removeDepartment(index),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSizes.paddingL),
            ],

            // Submit Button
            Consumer<OrganizationProvider>(
              builder: (context, org, _) {
                return SizedBox(
                  width: double.infinity,
                  height: AppSizes.buttonHeightM,
                  child: ElevatedButton(
                    onPressed: org.isLoading ? null : _submit,
                    child: org.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text('Buat Organisasi'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
