import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../../config/routes/app_router.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/extensions/date_extension.dart';

@RoutePage()
class Step2TimelineScreen extends StatefulWidget {
  final String title;
  final String description;
  final List<String> departmentIds;
  final File? posterFile;

  const Step2TimelineScreen({
    super.key,
    required this.title,
    required this.description,
    required this.departmentIds,
    this.posterFile,
  });

  @override
  State<Step2TimelineScreen> createState() => _Step2TimelineScreenState();
}

class _Step2TimelineScreenState extends State<Step2TimelineScreen> {
  DateTime? _planningStart;
  DateTime? _planningEnd;
  DateTime? _executionDate;

  Future<DateTime?> _showDatePicker(DateTime? initialDate) async {
    return await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
  }

  bool _canProceed() {
    if (_planningStart == null ||
        _planningEnd == null ||
        _executionDate == null) {
      return false;
    }
    return _executionDate!.isAfter(_planningEnd!);
  }

  void _goToStep3() {
    if (!_canProceed()) {
      context.showErrorSnackbar('Lengkapi semua tanggal dengan benar');
      return;
    }

    context.router.push(
      Step3ApprovalRoute(
        title: widget.title,
        description: widget.description,
        departmentIds: widget.departmentIds,
        posterFile: widget.posterFile,
        planningStart: _planningStart!,
        planningEnd: _planningEnd!,
        executionDate: _executionDate!,
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
          _buildProgressIndicator(2),
          const SizedBox(height: 24),

          Text('Timeline Proker', style: AppTextStyles.titleLarge),
          const SizedBox(height: AppSizes.paddingM),

          // Planning start
          _buildDatePicker(
            label: 'Tanggal Mulai Perencanaan *',
            value: _planningStart,
            onTap: () async {
              final date = await _showDatePicker(_planningStart);
              if (date != null) setState(() => _planningStart = date);
            },
          ),
          const SizedBox(height: AppSizes.paddingM),

          // Planning end
          _buildDatePicker(
            label: 'Tanggal Selesai Perencanaan *',
            value: _planningEnd,
            onTap: () async {
              final date = await _showDatePicker(_planningEnd);
              if (date != null) setState(() => _planningEnd = date);
            },
          ),
          const SizedBox(height: AppSizes.paddingM),

          // Execution date
          _buildDatePicker(
            label: 'Tanggal Pelaksanaan *',
            value: _executionDate,
            onTap: () async {
              final date = await _showDatePicker(_executionDate);
              if (date != null) setState(() => _executionDate = date);
            },
          ),

          if (_executionDate != null && _planningEnd != null)
            if (_executionDate!.isBefore(_planningEnd!))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '⚠️ Tanggal pelaksanaan harus setelah perencanaan selesai',
                  style: TextStyle(color: AppColors.statusError, fontSize: 12),
                ),
              ),
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
                  onPressed: _canProceed() ? _goToStep3 : null,
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

  Widget _buildDatePicker({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 12),
                Text(
                  value?.toFormattedDate() ?? 'Pilih tanggal',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: value == null
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
