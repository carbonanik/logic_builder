int getWeekNumberOfTheYear(DateTime dateTime) {
  int weekNumber =
      ((dateTime.difference(DateTime(dateTime.year, 1, 1)).inDays) / 7).ceil();
  return weekNumber;
}

DateTime getStartOfThisWeek(DateTime dateTime) {
  return dateTime.subtract(Duration(days: dateTime.weekday - 1));
}

DateTime getEndOfThisWeek(DateTime dateTime) {
  return dateTime.add(Duration(days: DateTime.daysPerWeek - dateTime.weekday));
}

String getWeekDayName(int dayOfWeek) {

  switch (dayOfWeek) {
    case 1:
      return 'Monday';
    case 2:
      return 'Tuesday';
    case 3:
      return 'Wednesday';
    case 4:
      return 'Thursday';
    case 5:
      return 'Friday';
    case 6:
      return 'Saturday';
    default:
      return 'Sunday';
  }
}
