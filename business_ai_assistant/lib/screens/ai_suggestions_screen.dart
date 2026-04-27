import 'package:flutter/material.dart';
import '/services/firestore_service.dart';
import '/services/gemini_service.dart';
import '/models/lead.dart';

class AISuggestionsScreen extends StatefulWidget {
  const AISuggestionsScreen({super.key});

  @override
  State<AISuggestionsScreen> createState() => _AISuggestionsScreenState();
}

class _AISuggestionsScreenState extends State<AISuggestionsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final GeminiService _geminiService = GeminiService();

  String _planResult = "";
  bool _isLoading = false;

  Future<void> _generatePlan() async {
    setState(() {
      _isLoading = true;
      _planResult = "";
    });

    try {
      List<Lead> leads = await _firestoreService.getLeadsOnce();

      if (leads.isEmpty) {
        setState(
          () => _planResult =
              "No leads found in your database. Add some leads first to generate a plan.",
        );
        return;
      }

      String leadsText = leads
          .map((l) => "Customer: ${l.name}, Interest/Message: ${l.message}")
          .join("\n---\n");

      final result = await _geminiService.getDailyPlan(leadsText);

      setState(() => _planResult = result);
    } catch (e) {
      setState(() => _planResult = "Error generating plan: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Daily Strategy'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Founder's Action Plan",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "AI will analyze all your leads to suggest the top 3 priorities for today.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: _isLoading
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text("Analyzing your leads..."),
                          ],
                        ),
                      )
                    : _planResult.isEmpty
                    ? const Center(
                        child: Text(
                          "Tap the button below to generate your AI-powered daily priority list.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      )
                    : SingleChildScrollView(
                        child: SelectableText(
                          _planResult,
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _isLoading ? null : _generatePlan,
              icon: const Icon(Icons.bolt),
              label: const Text("Generate Daily Plan"),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
