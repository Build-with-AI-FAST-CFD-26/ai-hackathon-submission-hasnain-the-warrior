import 'package:business_ai_assistant/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const AIAssistantApp());
}

// Data Model updated for Firestore
class Lead {
  final String id;
  final String name;
  final String message;

  Lead({required this.id, required this.name, required this.message});

  // Convert Firestore Document to Lead object
  factory Lead.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Lead(
      id: doc.id,
      name: data['name'] ?? '',
      message: data['message'] ?? '',
    );
  }

  // Convert Lead to Map for saving
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'message': message,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

class AIAssistantApp extends StatelessWidget {
  const AIAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Founder Stack AI',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blueAccent),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Founder Stack AI'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _menuCard(
              context,
              "Add New Lead",
              Icons.person_add_alt_1,
              const AddLeadScreen(),
            ),
            const SizedBox(height: 20),
            _menuCard(
              context,
              "View All Leads",
              Icons.people_outline,
              const ViewLeadsScreen(),
            ),
            const SizedBox(height: 20),
            _menuCard(
              context,
              "AI Daily Priorities",
              Icons.auto_awesome,
              const AISuggestionsScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuCard(
    BuildContext context,
    String title,
    IconData icon,
    Widget target,
  ) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => target),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            const BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 30, color: Colors.blueAccent),
            const SizedBox(width: 20),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class AddLeadScreen extends StatefulWidget {
  const AddLeadScreen({super.key});

  @override
  State<AddLeadScreen> createState() => _AddLeadScreenState();
}

class _AddLeadScreenState extends State<AddLeadScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _msg = TextEditingController();

  Future<void> _saveToFirestore() async {
    if (_name.text.isNotEmpty && _msg.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('leads').add({
        'name': _name.text,
        'message': _msg.text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lead Saved to Firestore')));
      _name.clear();
      _msg.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Lead')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _msg,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveToFirestore,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save Lead'),
            ),
          ],
        ),
      ),
    );
  }
}

class ViewLeadsScreen extends StatefulWidget {
  const ViewLeadsScreen({super.key});

  @override
  State<ViewLeadsScreen> createState() => _ViewLeadsScreenState();
}

class _ViewLeadsScreenState extends State<ViewLeadsScreen> {
  final String apiKey = "YOUR_API_KEY";

  Future<void> _generateFollowUp(String name, String msg) async {
    showDialog(
      context: context,
      builder: (c) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
      );
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text":
                      "Write a professional follow-up message for $name regarding: '$msg'",
                },
              ],
            },
          ],
        }),
      );
      Navigator.pop(context);
      final data = jsonDecode(res.body);
      _showResult(data['candidates'][0]['content']['parts'][0]['text']);
    } catch (e) {
      Navigator.pop(context);
      _showResult("Error: $e");
    }
  }

  void _showResult(String text) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("AI Follow-up"),
        content: SingleChildScrollView(child: SelectableText(text)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Leads (Real-time)')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('leads')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text("No leads in database."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final lead = Lead.fromFirestore(docs[i]);
              return Card(
                child: ListTile(
                  title: Text(
                    lead.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(lead.message),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.mail_outline,
                      color: Colors.blueAccent,
                    ),
                    onPressed: () => _generateFollowUp(lead.name, lead.message),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AISuggestionsScreen extends StatefulWidget {
  const AISuggestionsScreen({super.key});

  @override
  State<AISuggestionsScreen> createState() => _AISuggestionsScreenState();
}

class _AISuggestionsScreenState extends State<AISuggestionsScreen> {
  final String apiKey = "YOUR_API_KEY";
  String _response = "Click to analyze database and get your plan.";
  bool _loading = false;

  Future<void> _fetchPlan() async {
    setState(() => _loading = true);
    try {
      // Fetch data from Firestore
      final snapshot = await FirebaseFirestore.instance
          .collection('leads')
          .get();
      if (snapshot.docs.isEmpty) {
        setState(() => _response = "No leads found in Firestore.");
        return;
      }

      final contextString = snapshot.docs
          .map((doc) => "${doc['name']}: ${doc['message']}")
          .join(" | ");

      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
      );
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text":
                      "Based on these startup leads: $contextString. Suggest top 3 priorities and specific follow-up actions for today.",
                },
              ],
            },
          ],
        }),
      );

      if (res.statusCode == 200) {
        setState(
          () => _response = jsonDecode(
            res.body,
          )['candidates'][0]['content']['parts'][0]['text'],
        );
      }
    } catch (e) {
      setState(() => _response = "Error: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Daily Priorities')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Text(
                          _response,
                          style: const TextStyle(fontSize: 16, height: 1.6),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _fetchPlan,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
              child: const Text("Analyze Firestore Data"),
            ),
          ],
        ),
      ),
    );
  }
}
