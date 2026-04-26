import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/subject_model.dart';

class SubjectService {
  final _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _subjectsRef =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('subjects');

  Future<List<SubjectModel>> getSubjects() async {
    final snap = await _subjectsRef.get();
    return snap.docs
        .map((d) => SubjectModel.fromDoc(d.id, d.data()))
        .toList();
  }

  Future<void> addSubject(SubjectModel s) async {
    await _subjectsRef.add(s.toMap());
  }

  Future<void> deleteSubject(String id) async {
    await _subjectsRef.doc(id).delete();
  }
}
