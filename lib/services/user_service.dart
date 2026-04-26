// lib/services/user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // Créer un utilisateur dans Firestore après inscription
  Future<void> createUser(User firebaseUser) async {
    final userModel = UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email!,
      displayName: firebaseUser.displayName,
      xp: 0,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .set(userModel.toMap());
  }

  // Récupérer un utilisateur
  Stream<UserModel?> getUserStream() {
    if (currentUserId == null) return Stream.value(null);

    return _firestore
        .collection('users')
        .doc(currentUserId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    });
  }

  // Ajouter des XP
  Future<void> addXP(int xp) async {
    if (currentUserId == null) return;

    await _firestore.collection('users').doc(currentUserId).update({
      'xp': FieldValue.increment(xp),
    });
  }

  // Mettre à jour le profil
  Future<void> updateProfile(String displayName) async {
    if (currentUserId == null) return;

    await _firestore.collection('users').doc(currentUserId).update({
      'displayName': displayName,
    });
  }
}