class Helper {
  static String formatDate(DateTime dateTime) {
    String year = dateTime.year.toString();
    String month = dateTime.month.toString().padLeft(2, '0');
    String day = dateTime.day.toString().padLeft(2, '0');

    return '$year:$month:$day';
  }

  static String formatTime(DateTime dateTime) {
    String hour = dateTime.hour.toString().padLeft(2, '0');
    String minute = dateTime.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }
}
