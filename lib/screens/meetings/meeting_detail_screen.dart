import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../config/routes/app_router.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/extensions/context_extension.dart';
import '../../core/extensions/date_extension.dart';
import '../../core/utils/qr_helper.dart';
import '../../models/meeting_model.dart';
import '../../providers/meeting_provider.dart';
import '../../providers/auth_provider.dart';

@RoutePage()
class MeetingDetailScreen extends StatefulWidget {
  final String meetingId;

  const MeetingDetailScreen({super.key, required this.meetingId});

  @override
  State<MeetingDetailScreen> createState() => _MeetingDetailScreenState();
}

class _MeetingDetailScreenState extends State<MeetingDetailScreen> {
  MeetingModel? _meeting;
  bool _isLoading = true;
  bool _showQr = false;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMeeting();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadMeeting() async {
    // Get meeting from provider
    final meetingProvider = context.read<MeetingProvider>();
    final meeting = meetingProvider.meetings.firstWhere(
      (m) => m.id == widget.meetingId,
      orElse: () => MeetingModel(
        id: '',
        organizationId: '',
        title: '',
        dateTime: DateTime.now(),
        endTime: DateTime.now(),
        location: '',
        type: '',
        attendeeIds: [],
        attendeeDepartments: [],
        agenda: [],
        createdBy: '',
        createdAt: DateTime.now(),
      ),
    );

    setState(() {
      _meeting = meeting;
      _notesController.text = meeting.notes ?? '';
      _isLoading = false;
    });
  }

  bool _canGenerateQr() {
    final currentUser = context.read<AuthProvider>().currentUser;
    return currentUser?.uid == _meeting?.createdBy;
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_meeting == null || _meeting!.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text('Meeting tidak ditemukan', style: AppTextStyles.titleMedium),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.router.pop(),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      );
    }

    final isMeetingUpcoming = _meeting!.dateTime.isAfter(DateTime.now());

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Meeting')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        children: [
          // Title & Status
          Text(_meeting!.title, style: AppTextStyles.headlineSmall),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color:
                  (isMeetingUpcoming
                          ? AppColors.statusSuccess
                          : AppColors.textSecondary)
                      .withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isMeetingUpcoming ? 'MENDATANG' : 'SELESAI',
              style: TextStyle(
                color: isMeetingUpcoming
                    ? AppColors.statusSuccess
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date & Time
                  _buildInfoRow(
                    icon: Icons.calendar_today,
                    label: 'Tanggal & Waktu',
                    value:
                        '${_meeting!.dateTime.toFormattedDate()}, ${_formatTime(_meeting!.dateTime)}-${_formatTime(_meeting!.endTime)}',
                  ),
                  const Divider(height: 24),

                  // Location
                  _buildInfoRow(
                    icon: Icons.location_on,
                    label: 'Lokasi',
                    value: _meeting!.location,
                    trailing: TextButton(
                      onPressed: () {
                        context.showSnackbar('Buka di Maps (Coming soon)');
                      },
                      child: const Text('Buka di Maps'),
                    ),
                  ),
                  const Divider(height: 24),

                  // Type
                  _buildInfoRow(
                    icon: Icons.event_note,
                    label: 'Tipe',
                    value: _meeting!.type,
                  ),
                  const Divider(height: 24),

                  // Attendees count
                  _buildInfoRow(
                    icon: Icons.people,
                    label: 'Peserta',
                    value: '${_meeting!.attendeeIds.length} orang',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Agenda Section
          if (_meeting!.agenda.isNotEmpty) ...[
            Text('Agenda', style: AppTextStyles.titleLarge),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _meeting!.agenda.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '${entry.key + 1}. ${entry.value}',
                        style: AppTextStyles.bodyMedium,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // QR Attendance Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Peserta Hadir',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '0/${_meeting!.attendeeIds.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.qr_code_2, color: Colors.white, size: 48),
                  ],
                ),
                const SizedBox(height: 16),

                if (_showQr) ...[
                  // Show QR Code
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        QrImageView(
                          data: QrHelper.generateAttendanceQrData(
                            _meeting!.id,
                            _meeting!.organizationId,
                          ),
                          size: 200,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Scan QR code untuk absen',
                          style: AppTextStyles.bodySmall,
                        ),
                        TextButton(
                          onPressed: () {
                            context.router.push(
                              QrAttendanceRoute(meetingId: widget.meetingId),
                            );
                          },
                          child: const Text('Atau scan manual'),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Show button to generate QR
                  ElevatedButton(
                    onPressed: () {
                      if (_canGenerateQr()) {
                        setState(() => _showQr = true);
                      } else {
                        context.showErrorSnackbar(
                          'Hanya pembuat meeting yang bisa generate QR',
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('Tampilkan QR Code'),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Attendees List
          Text('Daftar Peserta', style: AppTextStyles.titleLarge),
          const SizedBox(height: 12),
          Card(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _meeting!.attendeeIds.length,
              itemBuilder: (context, index) {
                final userId = _meeting!.attendeeIds[index];
                // TODO: Get actual user data
                return ListTile(
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Text(
                          'U',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      // Attendance indicator (placeholder)
                      // if (isAttended)
                      //   Positioned(
                      //     right: 0,
                      //     bottom: 0,
                      //     child: Container(
                      //       width: 12,
                      //       height: 12,
                      //       decoration: BoxDecoration(
                      //         color: AppColors.statusSuccess,
                      //         shape: BoxShape.circle,
                      //         border: Border.all(color: Colors.white, width: 2),
                      //       ),
                      //     ),
                      //   ),
                    ],
                  ),
                  title: Text('User $userId'),
                  // trailing: isAttended
                  //     ? Chip(
                  //         label: Text('HADIR'),
                  //         backgroundColor: AppColors.statusSuccess.withOpacity(0.1),
                  //       )
                  //     : null,
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Notes Section
          Text('Catatan Meeting', style: AppTextStyles.titleLarge),
          const SizedBox(height: 12),
          TextFormField(
            controller: _notesController,
            decoration: InputDecoration(
              hintText: 'Tulis catatan meeting...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
            ),
            maxLines: 6,
            onChanged: (value) {
              // TODO: Auto-save notes (with debounce)
            },
          ),
          const SizedBox(height: 24),

          // Download Button
          SizedBox(
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () {
                context.showSnackbar('Download Notulen (Coming soon!)');
              },
              icon: const Icon(Icons.download),
              label: const Text('Download Notulen'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primary),
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
    Widget? trailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.labelLarge),
              const SizedBox(height: 4),
              Text(value, style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }
}
