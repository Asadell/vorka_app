import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/extensions/context_extension.dart';
import '../../core/utils/validators.dart';
import '../../models/meeting_model.dart';
import '../../models/user_model.dart';
import '../../providers/meeting_provider.dart';
import '../../providers/auth_provider.dart';

@RoutePage()
class CreateMeetingScreen extends StatefulWidget {
  const CreateMeetingScreen({super.key});

  @override
  State<CreateMeetingScreen> createState() => _CreateMeetingScreenState();
}

class _CreateMeetingScreenState extends State<CreateMeetingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _agendaTitleController = TextEditingController();
  final _agendaDurationController = TextEditingController();

  DateTime? _date;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _type = 'Rapat Koordinasi';
  List<String> _selectedAttendees = [];
  List<Map<String, String>> _agenda = [];

  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _agendaTitleController.dispose();
    _agendaDurationController.dispose();
    super.dispose();
  }

  List<UserModel> _getInvitableUsers() {
    // For demo, return mock users
    // In real app, fetch from Firestore based on organization
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
      UserModel(
        uid: 'user3',
        email: 'user3@test.com',
        name: 'Citra Dewi',
        createdAt: DateTime.now(),
      ),
    ];
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() => _date = date);
    }
  }

  Future<void> _pickTime(bool isStartTime) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        if (isStartTime) {
          _startTime = time;
        } else {
          _endTime = time;
        }
      });
    }
  }

  void _addAgenda() {
    if (_agendaTitleController.text.trim().isNotEmpty &&
        _agendaDurationController.text.trim().isNotEmpty) {
      setState(() {
        _agenda.add({
          'title': _agendaTitleController.text.trim(),
          'duration': _agendaDurationController.text.trim(),
        });
        _agendaTitleController.clear();
        _agendaDurationController.clear();
      });
    }
  }

  void _removeAgenda(int index) {
    setState(() {
      _agenda.removeAt(index);
    });
  }

  Future<void> _createMeeting() async {
    if (!_formKey.currentState!.validate()) return;

    if (_date == null || _startTime == null || _endTime == null) {
      context.showErrorSnackbar('Lengkapi tanggal dan waktu');
      return;
    }

    if (_selectedAttendees.isEmpty) {
      context.showErrorSnackbar('Pilih minimal 1 peserta');
      return;
    }

    setState(() => _isLoading = true);

    final startDateTime = DateTime(
      _date!.year,
      _date!.month,
      _date!.day,
      _startTime!.hour,
      _startTime!.minute,
    );

    final endDateTime = DateTime(
      _date!.year,
      _date!.month,
      _date!.day,
      _endTime!.hour,
      _endTime!.minute,
    );

    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser!;

    final meeting = MeetingModel(
      id: '',
      organizationId: user.activeOrganizationId!,
      title: _titleController.text.trim(),
      dateTime: startDateTime,
      endTime: endDateTime,
      location: _locationController.text.trim(),
      type: _type,
      attendeeIds: _selectedAttendees,
      attendeeDepartments: [],
      agenda: _agenda
          .map((a) => '${a['title']} (${a['duration']} menit)')
          .toList(),
      createdBy: user.uid,
      createdAt: DateTime.now(),
    );

    final success = await context.read<MeetingProvider>().createMeeting(
      meeting,
    );

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        context.showSuccessSnackbar('Meeting berhasil dibuat');
        context.router.pop();
      }
    } else {
      if (mounted) {
        context.showErrorSnackbar('Gagal membuat meeting');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.router.pop(),
        ),
        title: const Text('Buat Meeting Baru'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Judul Meeting *',
                hintText: 'Masukkan judul meeting',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
              ),
              validator: (value) => Validators.validateRequired(value, 'Judul'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSizes.paddingM),

            // Date picker
            Text('Tanggal *', style: AppTextStyles.labelLarge),
            const SizedBox(height: AppSizes.paddingS),
            InkWell(
              onTap: _pickDate,
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
                      _date != null
                          ? '${_date!.day}/${_date!.month}/${_date!.year}'
                          : 'Pilih tanggal',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: _date == null
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.paddingM),

            // Time pickers
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Waktu Mulai *', style: AppTextStyles.labelLarge),
                      const SizedBox(height: AppSizes.paddingS),
                      InkWell(
                        onTap: () => _pickTime(true),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusM,
                            ),
                          ),
                          child: Text(
                            _startTime?.format(context) ?? 'Pilih',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: _startTime == null
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Waktu Selesai *', style: AppTextStyles.labelLarge),
                      const SizedBox(height: AppSizes.paddingS),
                      InkWell(
                        onTap: () => _pickTime(false),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusM,
                            ),
                          ),
                          child: Text(
                            _endTime?.format(context) ?? 'Pilih',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: _endTime == null
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingM),

            // Location
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Lokasi *',
                hintText: 'Masukkan lokasi meeting',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
              ),
              validator: (value) =>
                  Validators.validateRequired(value, 'Lokasi'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSizes.paddingM),

            // Type dropdown
            Text('Tipe Meeting', style: AppTextStyles.labelLarge),
            const SizedBox(height: AppSizes.paddingS),
            DropdownButtonFormField<String>(
              value: _type,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Rapat Koordinasi',
                  child: Text('Rapat Koordinasi'),
                ),
                DropdownMenuItem(value: 'Evaluasi', child: Text('Evaluasi')),
                DropdownMenuItem(
                  value: 'Brainstorming',
                  child: Text('Brainstorming'),
                ),
                DropdownMenuItem(value: 'Lainnya', child: Text('Lainnya')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _type = value);
              },
            ),
            const SizedBox(height: AppSizes.paddingM),

            // Attendees
            Text('Peserta *', style: AppTextStyles.labelLarge),
            const SizedBox(height: AppSizes.paddingS),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: ListView(
                shrinkWrap: true,
                children: _getInvitableUsers().map((user) {
                  return CheckboxListTile(
                    value: _selectedAttendees.contains(user.uid),
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          _selectedAttendees.add(user.uid);
                        } else {
                          _selectedAttendees.remove(user.uid);
                        }
                      });
                    },
                    title: Row(
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
              ),
            ),
            const SizedBox(height: AppSizes.paddingM),

            // Agenda
            Text('Agenda', style: AppTextStyles.labelLarge),
            const SizedBox(height: AppSizes.paddingS),

            // Agenda list
            if (_agenda.isNotEmpty) ...[
              ..._agenda.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return ListTile(
                  leading: CircleAvatar(
                    radius: 16,
                    child: Text('${index + 1}'),
                  ),
                  title: Text(item['title']!),
                  subtitle: Text('${item['duration']} menit'),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => _removeAgenda(index),
                  ),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                );
              }),
              const SizedBox(height: AppSizes.paddingS),
            ],

            // Add agenda input
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _agendaTitleController,
                    decoration: InputDecoration(
                      hintText: 'Judul agenda',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _agendaDurationController,
                    decoration: InputDecoration(
                      hintText: 'Durasi',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  color: AppColors.primary,
                  onPressed: _addAgenda,
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingXl),

            // Submit button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createMeeting,
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
                        'Buat Meeting & Kirim Undangan',
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
