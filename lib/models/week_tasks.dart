import 'day_tasks.dart';

class WeekTasks {
  final int weekOfTheYear;
  final int year;
  final String? title;
  final String? description;
  final List<DayTasks>? dayTasks;

  WeekTasks({
    required this.weekOfTheYear,
    required this.year,
    this.title,
    this.description,
    this.dayTasks,
  });
}
