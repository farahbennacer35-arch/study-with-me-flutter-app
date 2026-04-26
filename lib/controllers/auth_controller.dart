import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthController {
  // Login
  static Future<void> login(
      BuildContext context, String email, String pass) async {
    try {
      final ok = await AuthService.login(email, pass);

      if (!context.mounted) return;

      if (ok) {
        Navigator.pushReplacementNamed(context, "/home");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email ou mot de passe incorrect")),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $e")),
      );
    }
  }

  // Register
  static Future<void> register(BuildContext context, String name,
      String email, String pass1, String pass2) async {
    if (pass1 != pass2) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Les mots de passe ne correspondent pas")),
      );
      return;
    }

    try {
      final ok = await AuthService.register(name, email, pass1);

      if (!context.mounted) return;

      if (ok) {
        Navigator.pushReplacementNamed(context, "/home");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Impossible de créer le compte")),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $e")),
      );
    }
  }
}
