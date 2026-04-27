import 'package:business_ai_assistant/models/lead.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference _leadsCollection = FirebaseFirestore.instance
      .collection('leads');

  Future<void> addLead(String name, String message) async {
    await _leadsCollection.add({
      'name': name,
      'message': message,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getLeadsStream() {
    return _leadsCollection.orderBy('createdAt', descending: true).snapshots();
  }

  Future<List<Lead>> getLeadsOnce() async {
    final querySnapshot = await _leadsCollection
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs.map((doc) => Lead.fromFirestore(doc)).toList();
  }
}
