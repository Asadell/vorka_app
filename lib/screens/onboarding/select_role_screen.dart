import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vorka_app2/config/routes/app_router.dart';
import 'package:vorka_app2/config/theme/app_colors.dart';
import 'package:vorka_app2/core/constants/app_sizes.dart';
import 'package:vorka_app2/core/constants/enums.dart';
import 'package:vorka_app2/models/organization_model.dart';
import 'package:vorka_app2/providers/auth_provider.dart';
import 'package:vorka_app2/providers/notification_provider.dart';

@RoutePage()
class SelectRoleScreen extends StatefulWidget {
  const SelectRoleScreen({super.key, required this.organization});

  final OrganizationModel organization;

  @override
  State<SelectRoleScreen> createState() => _SelectRoleScreenState();
}

class _SelectRoleScreenState extends State<SelectRoleScreen> {
  String? _selectedDepartmentId;
  UserRole? _selectedRole;

  List<Map<String, dynamic>> _getAvailableRoles() {
    final roles = <Map<String, dynamic>>[];

    // Check org-level roles
    if (widget.organization.ketuaOrganisasi == null) {
      roles.add({
        'role': UserRole.ketuaOrganisasi,
        'label': 'Ketua Organisasi',
        'departmentId': null,
      });
    }
    if (widget.organization.wakilOrganisasi == null) {
      roles.add({
        'role': UserRole.wakilOrganisasi,
        'label': 'Wakil Organisasi',
        'departmentId': null,
      });
    }

    // Check department-level roles if department selected
    if (_selectedDepartmentId != null) {
      final dept = widget.organization.departments.firstWhere(
        (d) => d.id == _selectedDepartmentId,
      );

      if (dept.ketuaDepartemen == null) {
        roles.add({
          'role': UserRole.ketuaDepartemen,
          'label': 'Ketua Departemen',
          'departmentId': dept.id,
        });
      }
      if (dept.wakilDepartemen == null) {
        roles.add({
          'role': UserRole.wakilDepartemen,
          'label': 'Wakil Departemen',
          'departmentId': dept.id,
        });
      }
    }

    // Anggota always available
    roles.add({
      'role': UserRole.anggota,
      'label': 'Anggota',
      'departmentId': _selectedDepartmentId,
    });

    return roles;
  }

  Future<void> _submit() async {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih role terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    final notifProvider = context.read<NotificationProvider>();
    final success = await notifProvider.createJoinRequest(
      userId: user.uid,
      userName: user.name,
      userEmail: user.email,
      userPhotoUrl: user.photoURL,
      organizationId: widget.organization.id,
      departmentId: _selectedDepartmentId,
      requestedRole: _selectedRole!,
    );

    if (!mounted) return;

    if (success) {
      // Navigate to waiting approval screen
      context.router.push(
        WaitingApprovalRoute(organizationName: widget.organization.name),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(notifProvider.error ?? 'Gagal mengirim permintaan'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Departemen & Role')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Organization Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingM),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: AppSizes.iconL,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: const Icon(
                        Icons.business,
                        size: AppSizes.iconL,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.organization.name,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: AppSizes.paddingXs),
                          Text(
                            widget.organization.description,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.paddingL),

            // Department Selection
            Text(
              'Pilih Departemen (Opsional)',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.paddingS),
            Text(
              'Pilih departemen jika ingin bergabung sebagai anggota departemen',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSizes.paddingM),

            ...widget.organization.departments.map((dept) {
              return RadioListTile<String>(
                value: dept.id,
                groupValue: _selectedDepartmentId,
                onChanged: (value) {
                  setState(() {
                    _selectedDepartmentId = value;
                    _selectedRole = null; // Reset role selection
                  });
                },
                title: Text(dept.name),
                activeColor: AppColors.primary,
              );
            }),
            const SizedBox(height: AppSizes.paddingL),

            // Role Selection
            Text(
              'Pilih Role',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.paddingS),
            Text(
              'Hanya role yang tersedia yang akan ditampilkan',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSizes.paddingM),

            ..._getAvailableRoles().map((roleData) {
              return RadioListTile<UserRole>(
                value: roleData['role'] as UserRole,
                groupValue: _selectedRole,
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value;
                  });
                },
                title: Text(roleData['label'] as String),
                activeColor: AppColors.primary,
              );
            }),
            const SizedBox(height: AppSizes.paddingXl),

            // Submit Button
            Consumer<NotificationProvider>(
              builder: (context, notif, _) {
                return SizedBox(
                  width: double.infinity,
                  height: AppSizes.buttonHeightM,
                  child: ElevatedButton(
                    onPressed: notif.isLoading ? null : _submit,
                    child: notif.isLoading
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
                        : const Text('Kirim Permintaan'),
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
