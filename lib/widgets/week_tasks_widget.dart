import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:week_task/models/week_tasks.dart';
import 'package:week_task/widgets/day_tasks_widgets.dart';

class WeekTasksWidget extends StatelessWidget {
  const WeekTasksWidget({
    required this.weekTasks,
    super.key,
  });

  final WeekTasks weekTasks;

  @override
  Widget build(BuildContext context) {
    final format1 = DateFormat('dd MMM');

    const titleStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );
    final startOfTheWeek = DateTime(weekTasks.year, 1, 1).add(Duration(days: 7 * (weekTasks.weekOfTheYear) - 6));
    final endOfTheWeek = DateTime(weekTasks.year, 1, 1).add(Duration(days: 7 * (weekTasks.weekOfTheYear)));
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            " Week ${weekTasks.weekOfTheYear}"
            " (${format1.format(startOfTheWeek)} - "
            " ${format1.format(endOfTheWeek)})",
            style: weekTasks.title == null
                ? titleStyle
                : const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          weekTasks.title == null
              ? const SizedBox()
              : Text(
                  weekTasks.title!,
                  style: titleStyle,
                ),
          weekTasks.description == null
              ? const SizedBox()
              : Text(weekTasks.description!),
          const SizedBox(height: 10),
          ListView(
            shrinkWrap: true,
            children: weekTasks.dayTasks?.map((dayTask) {
                  return DayTasksWidget(
                    startOfWeek: startOfTheWeek,
                    dayTasks: dayTask,
                  );
                }).toList() ??
                [],
          )
        ],
      ),
    );
  }
}
