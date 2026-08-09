import 'package:add_2_calendar/add_2_calendar.dart';

Future<void> addDeadlineToCalendar({
  required String title,
  String? description,
  required DateTime dueDate,
}) {
  final event = Event(
    title: title,
    description: description ?? '',
    startDate: dueDate,
    endDate: dueDate.add(const Duration(days: 1)),
    allDay: true,
  );
  return Add2Calendar.addEvent2Cal(event);
}
