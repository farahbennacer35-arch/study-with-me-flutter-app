class CalendarEvent {
  final DateTime date;
  final String title;

  CalendarEvent({required this.date, required this.title});

  CalendarEvent copyWith({DateTime? date, String? title}) {
    return CalendarEvent(
      date: date ?? this.date,
      title: title ?? this.title,
    );
  }
}
