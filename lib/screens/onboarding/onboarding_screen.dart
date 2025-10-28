import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vorka_app2/config/routes/app_router.dart';
import 'package:vorka_app2/config/theme/app_colors.dart';
import 'package:vorka_app2/core/constants/app_sizes.dart';
import 'package:vorka_app2/core/constants/firebase_constants.dart';
import 'package:vorka_app2/providers/auth_provider.dart';

@RoutePage()
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthProvider>().currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Tindakan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
              if (context.mounted) {
                context.router.replace(const LoginRoute());
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          children: [
            Icon(
              Icons.account_balance,
              size: AppSizes.iconXl * 2,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSizes.paddingL),
            Text(
              'Selamat Datang!',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.paddingS),
            Text(
              'Pilih salah satu opsi di bawah untuk memulai',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.paddingXl),

            // Pending Requests Section
            if (userId != null)
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection(FirebaseConstants.joinRequestsCollection)
                    .where('userId', isEqualTo: userId)
                    .where('status', isEqualTo: 'PENDING')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSizes.paddingM),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.pending_actions,
                                  color: Colors.orange.shade700,
                                ),
                                const SizedBox(width: AppSizes.paddingS),
                                Expanded(
                                  child: Text(
                                    'Permintaan Menunggu Persetujuan',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange.shade900,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSizes.paddingS),
                            Text(
                              'Anda memiliki ${snapshot.data!.docs.length} permintaan bergabung yang menunggu persetujuan admin.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingL),
                    ],
                  );
                },
              ),

            // Create Organization Card
            _OptionCard(
              icon: Icons.add_business,
              title: 'Buat Organisasi',
              description: 'Buat organisasi baru dan kelola strukturnya',
              onTap: () {
                context.router.push(const CreateOrgRoute());
              },
            ),
            const SizedBox(height: AppSizes.paddingM),

            // Join by QR Card
            _OptionCard(
              icon: Icons.qr_code_scanner,
              title: 'Join dengan QR',
              description: 'Scan QR code untuk bergabung ke organisasi',
              onTap: () {
                context.router.push(const JoinByQrRoute());
              },
            ),
            const SizedBox(height: AppSizes.paddingM),

            // Join by ID Card
            _OptionCard(
              icon: Icons.tag,
              title: 'Join dengan ID',
              description: 'Masukkan ID organisasi untuk bergabung',
              onTap: () {
                context.router.push(const JoinByIdRoute());
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: Icon(
                  icon,
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
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingXs),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: AppSizes.iconS,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
