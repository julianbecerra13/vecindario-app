extension StringExtensions on String {
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String get toTitleCase {
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - suffix.length)}$suffix';
  }

  String get formatPhoneColombia {
    final digits = replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length == 10) {
      return '+57 ${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6)}';
    }
    if (digits.length == 12 && digits.startsWith('57')) {
      final local = digits.substring(2);
      return '+57 ${local.substring(0, 3)} ${local.substring(3, 6)} ${local.substring(6)}';
    }
    return this;
  }

  String get whatsappNumber {
    final digits = replaceAll(RegExp(r'[^\d]'), '');
    if (digits.startsWith('57')) return digits;
    if (digits.length == 10) return '57$digits';
    return digits;
  }

  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  bool get isValidPhone {
    final digits = replaceAll(RegExp(r'[^\d]'), '');
    return digits.length == 10 || (digits.length == 12 && digits.startsWith('57'));
  }

  bool get isValidInviteCode {
    return RegExp(r'^[A-Za-z0-9]{6}$').hasMatch(this);
  }
}
