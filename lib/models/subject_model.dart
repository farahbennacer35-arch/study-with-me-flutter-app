class SubjectModel {
  final String id;
  final String name;
  final int colorIndex;

  SubjectModel({
    required this.id,
    required this.name,
    required this.colorIndex,
  });

  factory SubjectModel.fromDoc(String id, Map<String, dynamic> data) {
    return SubjectModel(
      id: id,
      name: data['name'] ?? '',
      colorIndex: data['colorIndex'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'colorIndex': colorIndex,
    };
  }
}
