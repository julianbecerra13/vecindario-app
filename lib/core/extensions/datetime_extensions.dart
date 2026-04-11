import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

extension DateTimeExtensions on DateTime {
  String get timeAgoText => timeago.format(this, locale: 'es');

  String get formatDate => DateFormat('dd/MM/yyyy').format(this);

  String get formatDateTime => DateFormat('dd/MM/yyyy HH:mm').format(this);

  String get formatTime => DateFormat('HH:mm').format(this);

  String get formatDateLong => DateFormat("d 'de' MMMM, yyyy", 'es').format(this);

  String get formatDateShort => DateFormat('d MMM', 'es').format(this);

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  String get smartDate {
    if (isToday) return 'Hoy ${formatTime}';
    if (isYesterday) return 'Ayer ${formatTime}';
    final diff = DateTime.now().difference(this);
    if (diff.inDays < 7) return timeAgoText;
    return formatDate;
  }
}
