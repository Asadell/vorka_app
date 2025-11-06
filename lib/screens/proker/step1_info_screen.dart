import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../../config/routes/app_router.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/organization_provider.dart';

@RoutePage()
class Step1InfoScreen extends StatefulWidget {
  const Step1InfoScreen({super.key});

  @override
  State<Step1InfoScreen> createState() => _Step1InfoScreenState();
}

class _Step1InfoScreenState extends State<Step1InfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  File? _posterFile;
  List<String> _selectedDepartments = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  List<dynamic> _getAvailableDepartments() {
    final orgProvider = context.read<OrganizationProvider>();
    final authProvider = context.read<AuthProvider>();

    final user = authProvider.currentUser;
    if (user == null) return [];

    final orgId = user.activeOrganizationId;
    if (orgId == null) return [];

    final userOrg = user.organizations.firstWhere(
      (org) => org.organizationId == orgId,
    );

    final org = orgProvider.currentOrganization;
    if (org == null) return [];

    // Super Admin & Ketua Org can select all departments
    if (userOrg.role.index <= 1) {
      return org.departments;
    }

    // Ketua Dept only own department
    if (userOrg.departmentId != null) {
      return org.departments
          .where((d) => d.id == userOrg.departmentId)
          .toList();
    }

    return [];
  }

  Future<void> _pickPoster() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      setState(() {
        _posterFile = File(result.files.single.path!);
      });
    }
  }

  bool _canProceed() {
    return _titleController.text.trim().isNotEmpty &&
        _selectedDepartments.isNotEmpty;
  }

  void _goToStep2() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDepartments.isEmpty) {
      context.showErrorSnackbar('Pilih minimal 1 departemen');
      return;
    }

    context.router.push(
      Step2TimelineRoute(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        departmentIds: _selectedDepartments,
        posterFile: _posterFile,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.router.pop(),
        ),
        title: const Text('Buat Proker Baru'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          children: [
            // Progress indicator
            _buildProgressIndicator(1),
            const SizedBox(height: 24),

            // Upload poster
            Text('Upload Poster', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickPoster,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderDefault, width: 2),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: _posterFile != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusM,
                            ),
                            child: Image.file(
                              _posterFile!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black54,
                              ),
                              onPressed: () {
                                setState(() => _posterFile = null);
                              },
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.cloud_upload,
                              size: 48,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap untuk upload poster',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: AppSizes.paddingM),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Judul Proker *',
                hintText: 'Masukkan judul proker',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
              ),
              validator: (value) => Validators.validateRequired(value, 'Judul'),
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSizes.paddingM),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Deskripsi',
                hintText: 'Masukkan deskripsi proker',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
              ),
              maxLines: 4,
              textInputAction: TextInputAction.newline,
            ),
            const SizedBox(height: AppSizes.paddingM),

            // Departments
            Text('Departemen *', style: AppTextStyles.labelLarge),
            const SizedBox(height: AppSizes.paddingS),
            ..._getAvailableDepartments().map((dept) {
              return CheckboxListTile(
                value: _selectedDepartments.contains(dept.id),
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      _selectedDepartments.add(dept.id);
                    } else {
                      _selectedDepartments.remove(dept.id);
                    }
                  });
                },
                title: Row(
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
                contentPadding: EdgeInsets.zero,
              );
            }),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: _canProceed() ? _goToStep2 : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.textSecondary,
            ),
            child: const Text('Lanjut'),
          ),
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
}
