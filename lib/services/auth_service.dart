import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // REGISTER
  static Future<bool> register(String name, String email, String password) async {
    try {
      UserCredential cred = await auth.createUserWithEmailAndPassword(
          email: email, password: password);

      // Mettre à jour le displayName dans Firebase Auth
      await cred.user!.updateDisplayName(name);

      // Ajouter l'utilisateur dans Firestore avec infos supplémentaires
      await firestore.collection("users").doc(cred.user!.uid).set({
        "name": name,
        "email": email,
        "xp": 0,
        "level": 1,
        "mood": "neutral",
        "createdAt": FieldValue.serverTimestamp(),
      });

      return true;
    } on FirebaseAuthException catch (e) {
      print('Register error: ${e.code}');
      return false;
    }
  }

  // LOGIN
  static Future<bool> login(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      print('Login error: ${e.code}');
      return false;
    }
  }

  // LOGOUT
  static Future<void> logout() async {
    await auth.signOut();
  }
}
