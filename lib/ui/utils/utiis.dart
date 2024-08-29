String formatDate(DateTime date) {
  return "${date.day}/${date.month}/${date.year}";
}

String formatHourAndMinute(DateTime date) {
  return "${date.hour}:${date.minute}";
}

String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  String minutes = twoDigits(duration.inMinutes.remainder(60));
  String seconds = twoDigits(duration.inSeconds.remainder(60));
  return "$minutes:$seconds";
}
