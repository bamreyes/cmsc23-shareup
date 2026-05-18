String timeAgo(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inSeconds < 60) return 'Just now';

  final minutes = difference.inMinutes;
  if (minutes < 60) return '$minutes ${minutes == 1 ? 'min' : 'mins'} ago';

  final hours = difference.inHours;
  if (hours < 24) return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';

  final days = difference.inDays;
  if (days < 7) return '$days ${days == 1 ? 'day' : 'days'} ago';

  final weeks = (days / 7).floor();
  if (days < 30) return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';

  final months = (days / 30).floor();
  if (days < 365) return '$months ${months == 1 ? 'month' : 'months'} ago';

  final years = (days / 365).floor();
  return '$years ${years == 1 ? 'year' : 'years'} ago';
}
