import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:week_task/utils/helpers_methods.dart';

import '../models/day_tasks.dart';

class DayTasksWidget extends StatelessWidget {
  const DayTasksWidget({
    required this.dayTasks,
    required this.startOfWeek,
    Key? key,
  }) : super(key: key);

  final DayTasks dayTasks;
  final DateTime startOfWeek;

  @override
  Widget build(BuildContext context) {
    final format1 = DateFormat('dd MMM');
    final format2 = DateFormat('EEEE');

    const titleStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );

    return Container(
      margin: const EdgeInsets.only(left: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${getWeekDayName(dayTasks.dayOfWeek)}"
            " (${format1.format(startOfWeek.add(Duration(days: dayTasks.dayOfWeek - 1)))})",
            style: dayTasks.title == null
                ? titleStyle
                : const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          dayTasks.title == null
              ? const SizedBox()
              : Text(
                  dayTasks.title!,
                  style: titleStyle,
                ),
          dayTasks.description == null
              ? const SizedBox()
              : Text(dayTasks.description!),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
