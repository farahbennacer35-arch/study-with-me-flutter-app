class SubjectModel {
  final String id;
  final String name;
  final int colorIndex;

  SubjectModel({
    required this.id,
    required this.name,
    required this.colorIndex,
  });

  // ---------- Convert Firestore → Model ----------
  factory SubjectModel.fromMap(Map<String, dynamic> data, String documentId) {
    return SubjectModel(
      id: documentId,
      name: data['name'] ?? '',
      colorIndex: data['colorIndex'] ?? 0,
    );
  }

  // ---------- Convert Model → Firestore ----------
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'colorIndex': colorIndex,
    };
  }
}
