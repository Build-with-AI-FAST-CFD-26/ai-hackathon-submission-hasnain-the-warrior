import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/firestore_service.dart';
import '/services/gemini_service.dart';
import '/models/lead.dart';
import '/widgets/lead_card.dart';

class ViewLeadsScreen extends StatefulWidget {
  const ViewLeadsScreen({super.key});

  @override
  State<ViewLeadsScreen> createState() => _ViewLeadsScreenState();
}

class _ViewLeadsScreenState extends State<ViewLeadsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final GeminiService _geminiService = GeminiService();

  void _showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _showAIResult(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: SelectableText(content)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Future<void> _analyzeLead(Lead lead) async {
    _showLoading(context);
    final result = await _geminiService.analyzeLead(lead.name, lead.message);
    if (!mounted) return;
    Navigator.pop(context);
    _showAIResult(context, "AI Lead Analysis", result);
  }

  Future<void> _generateFollowUp(Lead lead) async {
    _showLoading(context);
    final result = await _geminiService.generateFollowUp(
      lead.name,
      lead.message,
    );
    if (!mounted) return;
    Navigator.pop(context);
    _showAIResult(context, "Professional Follow-up Draft", result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Leads'), centerTitle: true),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getLeadsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No leads added yet.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final lead = Lead.fromFirestore(docs[index]);
              return LeadCard(
                lead: lead,
                onAnalyze: () => _analyzeLead(lead),
                onFollowUp: () => _generateFollowUp(lead),
              );
            },
          );
        },
      ),
    );
  }
}
