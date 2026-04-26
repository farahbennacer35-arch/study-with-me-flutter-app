// lib/models/user_model.dart
class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final int xp;
  final int level;
  final DateTime createdAt;
  
  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.xp = 0,
    required this.createdAt,
  }) : level = (xp / 1000).floor() + 1;

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'xp': xp,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      displayName: map['displayName'],
      xp: map['xp'] ?? 0,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}