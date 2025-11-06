extension StringExtension on String {
  // Capitalize first letter
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  // Capitalize each word
  String capitalizeWords() {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize()).join(' ');
  }

  // Check if email is valid
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  // Check if phone is valid (Indonesia)
  bool get isValidPhone {
    return RegExp(r'^(\+62|62|0)[0-9]{9,12}$').hasMatch(this);
  }

  // Remove whitespace
  String get removeWhitespace => replaceAll(RegExp(r'\s+'), '');

  // Truncate string
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$suffix';
  }

  // Check if string is empty or whitespace
  bool get isEmptyOrWhitespace => trim().isEmpty;

  // Get initials (max 2 letters)
  String get initials {
    if (isEmpty) return '';
    final words = trim().split(' ');
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    }
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  // Format org ID (ORG-12345)
  String get formatOrgId {
    if (startsWith('ORG-')) return this;
    return 'ORG-$this';
  }

  // Validate org ID format
  bool get isValidOrgId {
    return RegExp(r'^ORG-\d{5}$').hasMatch(this);
  }
}
