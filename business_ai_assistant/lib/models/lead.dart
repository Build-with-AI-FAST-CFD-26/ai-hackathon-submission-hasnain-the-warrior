import 'package:cloud_firestore/cloud_firestore.dart';

class Lead {
  final String id;
  final String name;
  final String message;
  final DateTime createdAt;

  Lead({
    required this.id,
    required this.name,
    required this.message,
    required this.createdAt,
  });

  factory Lead.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    return Lead(
      id: doc.id,
      name: data?['name'] ?? '',
      message: data?['message'] ?? '',
      createdAt: (data?['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'message': message,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
