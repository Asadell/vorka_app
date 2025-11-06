import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:vorka_app2/config/routes/app_router.dart';
import 'package:vorka_app2/config/theme/app_colors.dart';
import 'package:vorka_app2/core/constants/app_sizes.dart';
import 'package:vorka_app2/core/utils/validators.dart';

@RoutePage()
class CreateOrgScreen extends StatefulWidget {
  const CreateOrgScreen({super.key});

  @override
  State<CreateOrgScreen> createState() => _CreateOrgScreenState();
}

class _CreateOrgScreenState extends State<CreateOrgScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _next() {
    if (_formKey.currentState!.validate()) {
      context.router.push(
        AddDepartmentsRoute(
          orgName: _nameController.text.trim(),
          orgDescription: _descriptionController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Organisasi')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Langkah 1 dari 2',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSizes.paddingXs),
              Text(
                'Informasi Organisasi',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.paddingL),

              // Organization Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Organisasi',
                  hintText: 'Contoh: BEM FT Polnes',
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) =>
                    Validators.validateRequired(value, 'Nama organisasi'),
              ),
              const SizedBox(height: AppSizes.paddingM),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  hintText: 'Jelaskan tentang organisasi Anda',
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                validator: (value) =>
                    Validators.validateRequired(value, 'Deskripsi'),
              ),
              const SizedBox(height: AppSizes.paddingXl),

              // Next Button
              SizedBox(
                width: double.infinity,
                height: AppSizes.buttonHeightM,
                child: ElevatedButton(
                  onPressed: _next,
                  child: const Text('Selanjutnya'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
