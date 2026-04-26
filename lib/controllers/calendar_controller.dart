import 'package:flutter/material.dart';
import '../models/calendar_event_model.dart';
import '../services/calendar_service.dart';

class CalendarController extends ChangeNotifier {
  final CalendarService _calendarService = CalendarService();

  // On change le type de retour pour Stream
  Stream<List<CalendarEvent>> get events => _calendarService.getEventsStream();

  void addEvent(DateTime date, String title) {
    // On crée un CalendarEvent avant d'ajouter
    final event = CalendarEvent(date: date, title: title);
    _calendarService.addEvent(event);
    notifyListeners();
  }

  void removeEvent(CalendarEvent event) {
    _calendarService.removeEvent(event);
    notifyListeners();
  }
}
