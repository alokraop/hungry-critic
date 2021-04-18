import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatTime(DateTime time) {
  final format = DateFormat('Hm');
  return format.format(time);
}

String formatDate(DateTime date, [DateTime? yesterday]) {
  if (yesterday == null) {
    final now = DateTime.now();
    yesterday = DateTime(now.year, now.month, now.day);
  }
  if (date.isAfter(yesterday)) {
    return 'Today';
  } else {
    if (yesterday.difference(date).inDays == 0) {
      return 'Yesterday';
    } else {
      final format = date.year == yesterday.year ? DateFormat('MMMMd') : DateFormat('dd-MM-yy');
      return format.format(date);
    }
  }
}

String formatDateTime(DateTime time) {
  final now = DateTime.now();
  final yesterday = DateTime(now.year, now.month, now.day);
  if (time.isAfter(yesterday)) {
    final elapsed = now.difference(time);
    if (elapsed.inHours > 0) {
      return formatTime(time);
    } else if (elapsed.inMinutes > 0) {
      return '${elapsed.inMinutes} min ago';
    } else {
      return 'Just Now';
    }
  } else {
    return formatDate(time);
  }
}

class Timestamp extends StatelessWidget {
  Timestamp({
    this.time,
    this.ignoreDate = true,
    this.relative = false,
  });

  final DateTime? time;

  final bool ignoreDate;

  final bool relative;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final time = _buildTimestamp();
    return Text(time, style: theme.textTheme.caption);
  }

  String _buildTimestamp() {
    if (ignoreDate) {
      return relative ? '' : formatTime(time!);
    } else {
      return relative ? formatDateTime(time!) : '';
    }
  }
}
