import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:vorka_app2/config/theme/app_colors.dart';
import 'package:vorka_app2/core/constants/app_sizes.dart';

@RoutePage()
class JoinByQrScreen extends StatelessWidget {
  const JoinByQrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join dengan QR')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.qr_code_scanner,
                size: AppSizes.iconXl * 3,
                color: Colors.grey,
              ),
              const SizedBox(height: AppSizes.paddingL),
              Text(
                'QR Scanner',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.paddingS),
              Text(
                'Fitur QR Scanner akan segera tersedia',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.paddingL),
              Text(
                'Untuk sementara, gunakan Join dengan ID',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
