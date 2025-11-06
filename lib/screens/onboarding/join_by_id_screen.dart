import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vorka_app2/config/routes/app_router.dart';
import 'package:vorka_app2/config/theme/app_colors.dart';
import 'package:vorka_app2/core/constants/app_sizes.dart';
import 'package:vorka_app2/core/utils/validators.dart';
import 'package:vorka_app2/providers/organization_provider.dart';

@RoutePage()
class JoinByIdScreen extends StatefulWidget {
  const JoinByIdScreen({super.key});

  @override
  State<JoinByIdScreen> createState() => _JoinByIdScreenState();
}

class _JoinByIdScreenState extends State<JoinByIdScreen> {
  final _formKey = GlobalKey<FormState>();
  final _orgIdController = TextEditingController();

  @override
  void dispose() {
    _orgIdController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final orgProvider = context.read<OrganizationProvider>();
    await orgProvider.loadOrganization(_orgIdController.text.trim());

    if (!mounted) return;

    if (orgProvider.currentOrganization != null) {
      // Organization found, navigate to select role
      context.router.push(
        SelectRoleRoute(organization: orgProvider.currentOrganization!),
      );
    } else {
      // Organization not found
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(orgProvider.error ?? 'Organisasi tidak ditemukan'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join dengan ID')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.tag,
                size: AppSizes.iconXl * 2,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSizes.paddingL),
              Text(
                'Masukkan ID Organisasi',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.paddingS),
              Text(
                'Dapatkan ID organisasi dari admin organisasi Anda',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSizes.paddingL),

              // Org ID Field
              TextFormField(
                controller: _orgIdController,
                decoration: const InputDecoration(
                  labelText: 'ID Organisasi',
                  hintText: 'ORG-12345',
                  prefixIcon: Icon(Icons.numbers),
                ),
                textCapitalization: TextCapitalization.characters,
                validator: Validators.validateOrgId,
              ),
              const SizedBox(height: AppSizes.paddingXl),

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
                          : const Text('Cari Organisasi'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
