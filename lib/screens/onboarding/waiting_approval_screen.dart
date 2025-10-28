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
class WaitingApprovalScreen extends StatelessWidget {
  const WaitingApprovalScreen({super.key, required this.organizationName});

  final String organizationName;

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthProvider>().currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menunggu Persetujuan'),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(FirebaseConstants.joinRequestsCollection)
            .where('userId', isEqualTo: userId)
            .where('status', whereIn: ['PENDING', 'APPROVED', 'REJECTED'])
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: AppSizes.paddingM),
                  const Text('Terjadi kesalahan'),
                  const SizedBox(height: AppSizes.paddingM),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Kembali'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data!.docs;
          final latestRequest = requests.first;
          final data = latestRequest.data() as Map<String, dynamic>;
          final status = data['status'] as String;

          // Handle APPROVED status
          if (status == 'APPROVED') {
            Future.delayed(Duration.zero, () async {
              await context.read<AuthProvider>().loadCurrentUser();
              if (context.mounted) {
                context.router.replaceAll([const MainRoute()]);
              }
            });
          }

          // Handle REJECTED status
          if (status == 'REJECTED') {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingL),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.cancel_outlined,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: AppSizes.paddingM),
                    Text(
                      'Permintaan Ditolak',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSizes.paddingS),
                    Text(
                      'Admin menolak permintaan join Anda ke $organizationName.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSizes.paddingXl),
                    SizedBox(
                      width: double.infinity,
                      height: AppSizes.buttonHeightM,
                      child: ElevatedButton(
                        onPressed: () {
                          context.router.replaceAll([const OnboardingRoute()]);
                        },
                        child: const Text('Kembali ke Beranda'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // PENDING status - waiting
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: AppSizes.paddingL),
                  Text(
                    'Menunggu Persetujuan Admin',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingS),
                  Text(
                    'Permintaan join Anda ke $organizationName sedang ditinjau oleh admin.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.paddingL),
                  Container(
                    padding: const EdgeInsets.all(AppSizes.paddingM),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: AppSizes.paddingS),
                            Text(
                              'Status: Menunggu',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.paddingS),
                        Text(
                          'Halaman ini akan otomatis berpindah saat permintaan Anda disetujui atau ditolak.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingXl),
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      final hasOrg =
                          auth.currentUser?.organizations.isNotEmpty == true;

                      return OutlinedButton(
                        onPressed: () {
                          if (hasOrg) {
                            // Has organization, go to home
                            context.router.replaceAll([const MainRoute()]);
                          } else {
                            // No organization, back to onboarding
                            context.router.replaceAll([
                              const OnboardingRoute(),
                            ]);
                          }
                        },
                        child: Text(hasOrg ? 'Kembali ke Beranda' : 'Kembali'),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
