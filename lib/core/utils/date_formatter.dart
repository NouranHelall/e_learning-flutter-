class DateFormatter {
  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  static String time(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  static String day(DateTime date) => '${_days[date.weekday - 1]}, ${_months[date.month - 1]} ${date.day}';

  static String dayTime(DateTime date) => '${day(date)} · ${time(date)}';

  static String ago(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24) return '${difference.inHours} h ago';
    if (difference.inDays < 7) return '${difference.inDays} d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  static String startsIn(DateTime date) {
    final difference = date.difference(DateTime.now());
    if (difference.isNegative) return 'Started';
    if (difference.inMinutes < 60) return 'Starts in ${difference.inMinutes} min';
    if (difference.inHours < 24) return 'Starts in ${difference.inHours} hours';
    return 'Starts in ${difference.inDays} days';
  }

  static String greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }
}