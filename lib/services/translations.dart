import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'language_service.dart';

// Version standard pour le build context (listen = true par défaut)
String tr(BuildContext context, String key, {bool listen = true}) {
  final lang = Provider.of<LanguageService>(context, listen: listen).currentLanguage;
  return T.texts[key]?[lang] ?? key;
}

// Version courte pour les event handlers (équivalent à listen: false)
String trNoListen(BuildContext context, String key) {
  return tr(context, key, listen: false);
}

// Extension pour rendre l'utilisation encore plus simple
extension TranslationExtension on BuildContext {
  // Pour les widgets (écoute les changements)
  String tr(String key) => T.texts[key]?[
    Provider.of<LanguageService>(this, listen: true).currentLanguage
  ] ?? key;
  
  // Pour les event handlers (n'écoute pas les changements)
  String trNoListen(String key) => T.texts[key]?[
    Provider.of<LanguageService>(this, listen: false).currentLanguage
  ] ?? key;
}

class T {
  static Map<String, Map<String, String>> texts = {
    // General
    "home": {"fr": "Accueil", "en": "Home"},
    "settings": {"fr": "Paramètres", "en": "Settings"},
    "logout": {"fr": "Se déconnecter", "en": "Logout"},
    "language": {"fr": "Langue", "en": "Language"},
    "dark_mode": {"fr": "Mode sombre", "en": "Dark Mode"},
    "notifications": {"fr": "Notifications", "en": "Notifications"},
    "ok": {"fr": "OK", "en": "OK"},
    "cancel": {"fr": "Annuler", "en": "Cancel"},
    "add": {"fr": "Ajouter", "en": "Add"},
    "delete": {"fr": "Supprimer", "en": "Delete"},
    "today": {"fr": "Aujourd'hui", "en": "Today"},

    // CalendarPage
    "calendar": {"fr": "Calendrier", "en": "Calendar"},
    "new_subject": {"fr": "Nouvelle matière", "en": "New Subject"},
    "subject_name": {"fr": "Nom de la matière", "en": "Subject Name"},
    "choose_color": {"fr": "Choisir une couleur :", "en": "Choose a color:"},
    "subject_required": {"fr": "Le nom de la matière est requis", "en": "Subject name is required"},
    "subject_added": {"fr": "Matière ajoutée !", "en": "Subject added!"},
    "new_event": {"fr": "Nouvel événement", "en": "New Event"},
    "title": {"fr": "Titre", "en": "Title"},
    "event_type": {"fr": "Type d'événement", "en": "Event Type"},
    "study": {"fr": "Révision", "en": "Study"},
    "exam": {"fr": "DS/Examen", "en": "Exam"},
    "presentation": {"fr": "Présentation", "en": "Presentation"},
    "time": {"fr": "Heure", "en": "Time"},
    "event_added": {"fr": "Événement ajouté !", "en": "Event added!"},
    "confirm_delete": {"fr": "Confirmer la suppression", "en": "Confirm deletion"},
    "delete_confirmation": {"fr": "Voulez-vous vraiment supprimer cet élément ?", "en": "Do you really want to delete this item?"},
    "login_to_view_calendar": {"fr": "Connecte-toi pour voir ton calendrier", "en": "Login to view your calendar"},
    "view_day_sessions": {"fr": "Voir les sessions du jour", "en": "View day's sessions"},
    "no_event_today": {"fr": "Aucun événement pour ce jour", "en": "No events today"},
    "add_event": {"fr": "Ajouter un événement", "en": "Add Event"},
    "legend": {"fr": "Légende", "en": "Legend"},

    // MoodPage
    "mood_tracker": {"fr": "Suivi d'humeur", "en": "Mood Tracker"},
    "how_do_you_feel": {"fr": "Comment vous sentez-vous ?", "en": "How do you feel?"},
    "track_daily_wellbeing": {"fr": "Suivez votre bien-être quotidien", "en": "Track your daily wellbeing"},
    "select_your_mood": {"fr": "Sélectionnez votre humeur", "en": "Select your mood"},
    "mood_saved": {"fr": "Humeur enregistrée !", "en": "Mood saved!"},
    "history_last_7_days": {"fr": "Historique (7 derniers jours)", "en": "History (last 7 days)"},
    "no_history_yet": {"fr": "Aucun historique pour le moment", "en": "No history yet"},
    "wellbeing_tips": {"fr": "Conseils bien-être", "en": "Wellbeing Tips"},
    "action_close": {"fr": "Fermer", "en": "Close"},
    "mood_analysis": {"fr": "Analyse de votre humeur", "en": "Your Mood Analysis"},
    "stats_days_recorded": {"fr": "{count} jours enregistrés", "en": "{count} days recorded"},
    "recorded": {"fr": "Enregistré", "en": "Recorded"},
    "statistics": {"fr": "Statistiques", "en": "Statistics"},

    // Mood Types
    "happy": {"fr": "Heureux", "en": "Happy"},
    "tired": {"fr": "Fatigué", "en": "Tired"},
    "stressed": {"fr": "Stressé", "en": "Stressed"},
    "sad": {"fr": "Triste", "en": "Sad"},
    "motivated": {"fr": "Motivé", "en": "Motivated"},

    // Mood Suggestions
    "suggestion_happy": {
      "fr": "Profitez de cette énergie positive pour étudier !",
      "en": "Take advantage of this positive energy to study!"
    },
    "suggestion_tired": {
      "fr": "Prenez une pause, reposez-vous un peu.",
      "en": "Take a break, rest a little."
    },
    "suggestion_stressed": {
      "fr": "Respirez profondément et détendez-vous.",
      "en": "Breathe deeply and relax."
    },
    "suggestion_sad": {
      "fr": "C'est normal de se sentir ainsi. Prenez soin de vous.",
      "en": "It's normal to feel this way. Take care of yourself."
    },
    "suggestion_motivated": {
      "fr": "Excellente énergie ! Vous êtes prêt à tout accomplir !",
      "en": "Excellent energy! You're ready to accomplish anything!"
    },

    // Mood Actions
    "action_happy": {"fr": "Commencer une session Pomodoro", "en": "Start a Pomodoro session"},
    "action_tired": {"fr": "Faire une sieste de 20 min", "en": "Take a 20-min nap"},
    "action_stressed": {"fr": "Exercice de relaxation", "en": "Relaxation exercise"},
    "action_sad": {"fr": "Regarder un film inspirant", "en": "Watch an inspiring movie"},
    "action_motivated": {"fr": "Session intensive d'étude", "en": "Intensive study session"},

    // Mood Feedback
    "you_feel": {"fr": "Vous vous sentez", "en": "You feel"},
    "action_prefix": {"fr": "Action:", "en": "Action:"},

    // Wellbeing Tips
    "tip_water": {"fr": "Buvez de l'eau régulièrement", "en": "Drink water regularly"},
    "tip_breaks": {"fr": "Prenez des pauses de 5 min toutes les heures", "en": "Take 5-min breaks every hour"},
    "tip_sleep": {"fr": "Dormez 7-8 heures par nuit", "en": "Sleep 7-8 hours per night"},
    "tip_exercise": {"fr": "Faites de l'exercice quotidiennement", "en": "Exercise daily"},

    // Pomodoro
    "pomodoro": {"fr": "Pomodoro", "en": "Pomodoro"},
    "start": {"fr": "Démarrer", "en": "Start"},
    "pause": {"fr": "Pause", "en": "Pause"},
    "stop": {"fr": "Arrêter", "en": "Stop"},
    "session_completed": {"fr": "Session terminée !", "en": "Session completed!"},

    // Leaderboard
    "leaderboard": {"fr": "Classement", "en": "Leaderboard"},
    "rank": {"fr": "Rang", "en": "Rank"},
    "xp": {"fr": "XP", "en": "XP"},
    "level": {"fr": "Niveau", "en": "Level"},

    // Profile
    "profile": {"fr": "Profil", "en": "Profile"},
    "edit_profile": {"fr": "Modifier le profil", "en": "Edit Profile"},
    "username": {"fr": "Nom d'utilisateur", "en": "Username"},
    "email": {"fr": "Email", "en": "Email"},

    // Authentication
    "login": {"fr": "Connexion", "en": "Login"},
    "register": {"fr": "Inscription", "en": "Register"},
    "password": {"fr": "Mot de passe", "en": "Password"},
    "forgot_password": {"fr": "Mot de passe oublié ?", "en": "Forgot password?"},
    "login_success": {"fr": "Connexion réussie !", "en": "Login successful!"},
    "register_success": {"fr": "Inscription réussie !", "en": "Registration successful!"},

    // Errors
    "error": {"fr": "Erreur", "en": "Error"},
    "error_network": {"fr": "Erreur de connexion", "en": "Network error"},
    "error_auth": {"fr": "Erreur d'authentification", "en": "Authentication error"},
    "error_unknown": {"fr": "Erreur inconnue", "en": "Unknown error"},

    // Success Messages
    "success": {"fr": "Succès", "en": "Success"},
    "saved": {"fr": "Enregistré", "en": "Saved"},
    "updated": {"fr": "Mis à jour", "en": "Updated"},
    "deleted": {"fr": "Supprimé", "en": "Deleted"},
    "contact_us": {"fr": "Contactez-nous", "en": "Contact Us"},
"need_help": {"fr": "Besoin d'aide ?", "en": "Need help?"},
"send_us_message": {"fr": "Envoyez-nous un message", "en": "Send us a message"},
"your_email": {"fr": "Votre email", "en": "Your email"},
"your_message": {"fr": "Votre message", "en": "Your message"},
"describe_problem": {"fr": "Décrivez votre problème...", "en": "Describe your problem..."},
"fill_all_fields": {"fr": "Veuillez remplir tous les champs", "en": "Please fill all fields"},
"message_sent": {"fr": "Message envoyé avec succès !", "en": "Message sent successfully!"},
"sending": {"fr": "Envoi...", "en": "Sending..."},
"send": {"fr": "Envoyer", "en": "Send"},

  };
}