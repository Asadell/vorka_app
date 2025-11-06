import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../core/utils/qr_helper.dart';
import '../../providers/meeting_provider.dart';
import '../../providers/auth_provider.dart';

@RoutePage()
class QrAttendanceScreen extends StatefulWidget {
  final String meetingId;

  const QrAttendanceScreen({super.key, required this.meetingId});

  @override
  State<QrAttendanceScreen> createState() => _QrAttendanceScreenState();
}

class _QrAttendanceScreenState extends State<QrAttendanceScreen> {
  MobileScannerController? _scannerController;
  bool _isProcessing = false;
  bool _hasScanned = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing || _hasScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? qrData = barcodes.first.rawValue;
    if (qrData == null) return;

    setState(() {
      _isProcessing = true;
      _hasScanned = true;
    });

    await _processQrCode(qrData);
  }

  Future<void> _processQrCode(String qrData) async {
    try {
      // Parse QR data
      final data = QrHelper.parseQrData(qrData);

      if (data == null || !QrHelper.isValidAttendanceQr(data)) {
        _showError('QR Code tidak valid');
        return;
      }

      // Validate meeting ID
      if (data['meetingId'] != widget.meetingId) {
        _showError('QR Code untuk meeting yang berbeda');
        return;
      }

      // TODO: Validate QR timing (meeting start to 30 min after end)
      // final qrCreatedTime = DateTime.fromMillisecondsSinceEpoch(data['createdAt']);
      // if (!QrHelper.isAttendanceQrValid(data, meetingStart, meetingEnd)) {
      //   _showError('QR Code sudah tidak valid');
      //   return;
      // }

      // Mark attendance
      final currentUser = context.read<AuthProvider>().currentUser;
      if (currentUser == null) {
        _showError('User tidak ditemukan');
        return;
      }

      final success = await context.read<MeetingProvider>().markAttendance(
        widget.meetingId,
        currentUser.uid,
      );

      if (success) {
        _showSuccess();
      } else {
        _showError('Gagal mencatat kehadiran');
      }
    } catch (e) {
      _showError('Terjadi kesalahan: $e');
    }
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.statusSuccess.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.statusSuccess,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Kehadiran Tercatat!',
              style: AppTextStyles.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Terima kasih sudah hadir di meeting ini',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              context.router.pop(); // Close QR screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.statusError.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: AppColors.statusError,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal!',
              style: AppTextStyles.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _isProcessing = false;
                _hasScanned = false;
              });
            },
            child: const Text('Coba Lagi'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.router.pop();
            },
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Absensi'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Camera preview
          MobileScanner(controller: _scannerController, onDetect: _onDetect),

          // Overlay with scan area
          CustomPaint(painter: ScannerOverlay(), child: Container()),

          // Instructions
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Arahkan kamera ke QR Code',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Cancel button
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () => context.router.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text('Batal'),
              ),
            ),
          ),

          // Processing indicator
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    // Draw dark overlay
    canvas.drawRect(rect, paint);

    // Calculate scan area
    final scanSize = size.width * 0.7;
    final left = (size.width - scanSize) / 2;
    final top = (size.height - scanSize) / 2;
    final scanRect = Rect.fromLTWH(left, top, scanSize, scanSize);

    // Clear scan area
    canvas.drawRect(
      scanRect,
      Paint()
        ..color = Colors.transparent
        ..blendMode = BlendMode.clear,
    );

    // Draw corners
    final cornerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final cornerLength = 30.0;

    // Top-left
    canvas.drawLine(
      Offset(left, top),
      Offset(left + cornerLength, top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left, top),
      Offset(left, top + cornerLength),
      cornerPaint,
    );

    // Top-right
    canvas.drawLine(
      Offset(left + scanSize - cornerLength, top),
      Offset(left + scanSize, top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left + scanSize, top),
      Offset(left + scanSize, top + cornerLength),
      cornerPaint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(left, top + scanSize - cornerLength),
      Offset(left, top + scanSize),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left, top + scanSize),
      Offset(left + cornerLength, top + scanSize),
      cornerPaint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(left + scanSize - cornerLength, top + scanSize),
      Offset(left + scanSize, top + scanSize),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left + scanSize, top + scanSize - cornerLength),
      Offset(left + scanSize, top + scanSize),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
