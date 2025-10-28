import 'package:intl/intl.dart';

extension DateExtension on DateTime {
  // Format date to Indonesian
  String toFormattedDate() {
    return DateFormat('dd MMMM yyyy', 'id_ID').format(this);
  }

  String toFormattedDateTime() {
    return DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(this);
  }

  String toFormattedTime() {
    return DateFormat('HH:mm', 'id_ID').format(this);
  }

  String toShortDate() {
    return DateFormat('dd MMM yyyy', 'id_ID').format(this);
  }

  String toShortDateTime() {
    return DateFormat('dd MMM, HH:mm', 'id_ID').format(this);
  }

  // Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  // Check if date is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  // Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  // Get relative time (Today, Tomorrow, Yesterday, or date)
  String toRelativeDate() {
    if (isToday) return 'Hari ini';
    if (isTomorrow) return 'Besok';
    if (isYesterday) return 'Kemarin';
    return toShortDate();
  }

  // Get relative time with hour (Today 14:00, Tomorrow 09:00, or date)
  String toRelativeDateTime() {
    if (isToday) return 'Hari ini, ${toFormattedTime()}';
    if (isTomorrow) return 'Besok, ${toFormattedTime()}';
    if (isYesterday) return 'Kemarin, ${toFormattedTime()}';
    return toShortDateTime();
  }

  // Check if date is in past
  bool get isPast => isBefore(DateTime.now());

  // Check if date is in future
  bool get isFuture => isAfter(DateTime.now());

  // Get days until this date
  int get daysUntil {
    final now = DateTime.now();
    return difference(now).inDays;
  }

  // Get hours until this date
  int get hoursUntil {
    final now = DateTime.now();
    return difference(now).inHours;
  }

  // Time ago (5 menit lalu, 2 jam lalu, etc)
  String timeAgo() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks minggu lalu';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months bulan lalu';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years tahun lalu';
    }
  }

  // Start of day
  DateTime get startOfDay => DateTime(year, month, day);

  // End of day
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);
}
