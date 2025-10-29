import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/routes/app_router.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/extensions/context_extension.dart';
import '../../core/extensions/date_extension.dart';
import '../../core/extensions/string_extension.dart';
import '../../models/meeting_model.dart';
import '../../providers/meeting_provider.dart';
import '../../providers/auth_provider.dart';

@RoutePage()
class MeetingListScreen extends StatefulWidget {
  const MeetingListScreen({super.key});

  @override
  State<MeetingListScreen> createState() => _MeetingListScreenState();
}

class _MeetingListScreenState extends State<MeetingListScreen> {
  @override
  void initState() {
    super.initState();
    _loadMeetings();
  }

  void _loadMeetings() {
    final authProvider = context.read<AuthProvider>();
    final orgId = authProvider.currentUser?.activeOrganizationId;

    if (orgId != null) {
      context.read<MeetingProvider>().watchMeetings(orgId);
    }
  }

  bool _canCreateMeeting() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;
    if (user == null) return false;

    final orgId = user.activeOrganizationId;
    if (orgId == null) return false;

    final userOrg = user.organizations.firstWhere(
      (org) => org.organizationId == orgId,
      orElse: () => throw Exception('Organization not found'),
    );

    // Super Admin, Ketua/Wakil Org, Ketua Dept can create
    return userOrg.role.index <= 4; // superAdmin to ketuaDepartemen
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Meetings'),
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Mendatang'),
              Tab(text: 'Selesai'),
            ],
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
          ),
        ),
        body: Consumer<MeetingProvider>(
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
                      'Gagal memuat meetings',
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
                      onPressed: _loadMeetings,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            }

            return TabBarView(
              children: [
                _buildMeetingList(provider.upcomingMeetings),
                _buildMeetingList(provider.pastMeetings),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_canCreateMeeting()) {
              context.router.push(const CreateMeetingRoute());
            } else {
              context.showErrorSnackbar('Hanya ketua yang bisa buat meeting');
            }
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildMeetingList(List<MeetingModel> meetings) {
    if (meetings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Tidak ada meeting', style: AppTextStyles.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Meeting akan muncul di sini',
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
      itemCount: meetings.length,
      itemBuilder: (context, index) {
        return MeetingCard(meeting: meetings[index]);
      },
    );
  }
}

class MeetingCard extends StatefulWidget {
  final MeetingModel meeting;

  const MeetingCard({super.key, required this.meeting});

  @override
  State<MeetingCard> createState() => _MeetingCardState();
}

class _MeetingCardState extends State<MeetingCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthProvider>().currentUser;
    final isAttending = widget.meeting.attendeeIds.contains(currentUser?.uid);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
      child: InkWell(
        onTap: () {
          context.router.push(MeetingDetailRoute(meetingId: widget.meeting.id));
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + RSVP badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.meeting.title,
                      style: AppTextStyles.titleMedium,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isAttending
                          ? AppColors.statusSuccess
                          : AppColors.backgroundCard,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isAttending ? 'HADIR' : 'BELUM KONFIRMASI',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isAttending
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Date & time
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.meeting.dateTime.toFormattedDate()}, ${_formatTime(widget.meeting.dateTime)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Location
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.meeting.location,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),

              const Divider(height: 24),

              // Attendees
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Avatar stack
                  Row(
                    children: [
                      ...widget.meeting.attendeeIds.take(4).map((id) {
                        return Container(
                          margin: const EdgeInsets.only(right: 4),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.primary,
                            child: Text(
                              'U',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      }),
                      if (widget.meeting.attendeeIds.length > 4)
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: Text(
                            '+${widget.meeting.attendeeIds.length - 4}',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  // Confirmation count (placeholder)
                  Text(
                    '${widget.meeting.attendeeIds.length} peserta',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              // Expandable agenda
              if (widget.meeting.agenda.isNotEmpty) ...[
                TextButton.icon(
                  onPressed: () {
                    setState(() => _isExpanded = !_isExpanded);
                  },
                  icon: Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 16,
                  ),
                  label: const Text('Agenda'),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                ),

                if (_isExpanded) _buildAgenda(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAgenda() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundBase,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.meeting.agenda.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '${entry.key + 1}. ${entry.value}',
              style: AppTextStyles.bodySmall,
            ),
          );
        }).toList(),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
