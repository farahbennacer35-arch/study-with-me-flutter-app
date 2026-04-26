import 'dart:async';
import '../models/calendar_event_model.dart';

class CalendarService {
  final StreamController<List<CalendarEvent>> _eventController = StreamController.broadcast();
  final List<CalendarEvent> _events = [];

  Stream<List<CalendarEvent>> getEventsStream() => _eventController.stream;

  void addEvent(CalendarEvent event) {
    _events.add(event);
    _eventController.add(List.from(_events));
  }

  void removeEvent(CalendarEvent event) {
    _events.remove(event);
    _eventController.add(List.from(_events));
  }
}
