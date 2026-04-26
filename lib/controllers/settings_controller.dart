// lib/controllers/settings_controller.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends ChangeNotifier {
  // Paramètres généraux
  bool _darkMode = false;
  bool _notifications = true;
  bool _soundEffects = true;
  bool _vibration = true;
  String _language = "fr";

  // ✅ NOUVEAU : Paramètres de notifications spécifiques
  bool _pomodoroNotifications = true;
  bool _studyReminders = true;
  bool _examReminders = true;
  bool _dailyMotivation = true;
  bool _moodReminder = true;

  // Getters pour les paramètres généraux
  bool get darkMode => _darkMode;
  bool get notifications => _notifications;
  bool get soundEffects => _soundEffects;
  bool get vibration => _vibration;
  String get language => _language;

  // ✅ NOUVEAU : Getters pour les paramètres de notifications spécifiques
  bool get pomodoroNotifications => _pomodoroNotifications;
  bool get studyReminders => _studyReminders;
  bool get examReminders => _examReminders;
  bool get dailyMotivation => _dailyMotivation;
  bool get moodReminder => _moodReminder;

  SettingsController() {
    _loadSettings();
  }

  // Charger les paramètres sauvegardés
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _darkMode = prefs.getBool("darkMode") ?? false;
    _notifications = prefs.getBool("notifications") ?? true;
    _soundEffects = prefs.getBool("soundEffects") ?? true;
    _vibration = prefs.getBool("vibration") ?? true;
    _language = prefs.getString("language") ?? "fr";

    // ✅ NOUVEAU : Charger les paramètres de notifications spécifiques
    _pomodoroNotifications = prefs.getBool('pomodoroNotifications') ?? true;
    _studyReminders = prefs.getBool('studyReminders') ?? true;
    _examReminders = prefs.getBool('examReminders') ?? true;
    _dailyMotivation = prefs.getBool('dailyMotivation') ?? true;
    _moodReminder = prefs.getBool('moodReminder') ?? true;

    notifyListeners();
  }

  // Sauvegarder un paramètre
  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    }
  }

  // Toggle methods pour paramètres généraux
  Future<void> toggleDarkMode(bool value) async {
    _darkMode = value;
    await _saveSetting("darkMode", value);
    notifyListeners();
  }

  Future<void> toggleNotifications(bool value) async {
    _notifications = value;
    await _saveSetting("notifications", value);
    notifyListeners();
  }

  Future<void> toggleSoundEffects(bool value) async {
    _soundEffects = value;
    await _saveSetting("soundEffects", value);
    notifyListeners();
  }

  Future<void> toggleVibration(bool value) async {
    _vibration = value;
    await _saveSetting("vibration", value);
    notifyListeners();
  }

  Future<void> changeLanguage(String code) async {
    _language = code;
    await _saveSetting("language", code);
    notifyListeners();
  }

  // ✅ NOUVEAU : Toggle methods pour notifications spécifiques
  Future<void> togglePomodoroNotifications(bool value) async {
    _pomodoroNotifications = value;
    await _saveSetting('pomodoroNotifications', value);
    notifyListeners();
  }

  Future<void> toggleStudyReminders(bool value) async {
    _studyReminders = value;
    await _saveSetting('studyReminders', value);
    notifyListeners();
  }

  Future<void> toggleExamReminders(bool value) async {
    _examReminders = value;
    await _saveSetting('examReminders', value);
    notifyListeners();
  }

  Future<void> toggleDailyMotivation(bool value) async {
    _dailyMotivation = value;
    await _saveSetting('dailyMotivation', value);
    notifyListeners();
  }

  Future<void> toggleMoodReminder(bool value) async {
    _moodReminder = value;
    await _saveSetting('moodReminder', value);
    notifyListeners();
  }

  // ✅ NOUVEAU : Réinitialiser tous les paramètres
  Future<void> resetSettings() async {
    _darkMode = false;
    _notifications = true;
    _soundEffects = true;
    _vibration = true;
    _language = "fr";
    _pomodoroNotifications = true;
    _studyReminders = true;
    _examReminders = true;
    _dailyMotivation = true;
    _moodReminder = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    notifyListeners();
  }

  // ✅ NOUVEAU : Sauvegarder tous les paramètres en une fois
  Future<void> saveAllSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool("darkMode", _darkMode);
    await prefs.setBool("notifications", _notifications);
    await prefs.setBool("soundEffects", _soundEffects);
    await prefs.setBool("vibration", _vibration);
    await prefs.setString("language", _language);
    await prefs.setBool('pomodoroNotifications', _pomodoroNotifications);
    await prefs.setBool('studyReminders', _studyReminders);
    await prefs.setBool('examReminders', _examReminders);
    await prefs.setBool('dailyMotivation', _dailyMotivation);
    await prefs.setBool('moodReminder', _moodReminder);
  }

  // ✅ NOUVEAU : Vérifier si les notifications sont complètement activées
  bool get areNotificationsEnabled => 
      _notifications && 
      (_pomodoroNotifications || _studyReminders || _examReminders || 
       _dailyMotivation || _moodReminder);

  // ✅ NOUVEAU : Obtenir un résumé des notifications actives
  String getActiveNotificationsSummary() {
    final List<String> active = [];
    
    if (_pomodoroNotifications) active.add('Pomodoro');
    if (_studyReminders) active.add('Révisions');
    if (_examReminders) active.add('Examens');
    if (_dailyMotivation) active.add('Motivation');
    if (_moodReminder) active.add('Humeur');
    
    if (active.isEmpty) return 'Aucune notification active';
    if (active.length == 1) return active[0];
    if (active.length == 5) return 'Toutes les notifications';
    
    return '${active.length} notifications actives';
  }
}