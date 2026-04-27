import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const AIAssistantApp());
}

// Data Model
class Lead {
  final String name;
  final String message;

  Lead({required this.name, required this.message});
}

// Global persistence for the session
List<Lead> globalLeads = [];

class AIAssistantApp extends StatelessWidget {
  const AIAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Founder Stack AI',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blueAccent,
        brightness: Brightness.light,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Founder Stack AI'),
        centerTitle: true,
        elevation: 2,
      ),
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
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, 4),
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

  void _save() {
    if (_name.text.isNotEmpty && _msg.text.isNotEmpty) {
      setState(
        () => globalLeads.add(Lead(name: _name.text, message: _msg.text)),
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lead Stored')));
      _name.clear();
      _msg.clear();
      FocusScope.of(context).unfocus();
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
                labelText: 'Lead Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _msg,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Lead Message/Inquiry',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save Lead Data'),
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

  Future<void> _generateFollowUp(String leadName, String leadMsg) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
      );
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text":
                      "Write a professional, short, and friendly follow-up email/message for $leadName who said: '$leadMsg'",
                },
              ],
            },
          ],
        }),
      );

      Navigator.pop(context); // Close loader

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _showResult(data['candidates'][0]['content']['parts'][0]['text']);
      } else {
        _showResult("Error: Unable to connect to Gemini.");
      }
    } catch (e) {
      Navigator.pop(context);
      _showResult("Error: $e");
    }
  }

  void _showResult(String text) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("AI Follow-up Draft"),
        content: SingleChildScrollView(child: SelectableText(text)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text("Done"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Leads')),
      body: globalLeads.isEmpty
          ? const Center(child: Text('No leads found.'))
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: globalLeads.length,
              itemBuilder: (context, i) => Card(
                margin: const EdgeInsets.only(bottom: 15),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        globalLeads[i].name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        globalLeads[i].message,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const Divider(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => _generateFollowUp(
                            globalLeads[i].name,
                            globalLeads[i].message,
                          ),
                          icon: const Icon(Icons.mail_outline, size: 18),
                          label: const Text("Generate Follow-up"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
  String _response = "Analyze all leads to find your top 3 priorities.";
  bool _loading = false;

  Future<void> _fetchPlan() async {
    if (globalLeads.isEmpty) {
      setState(() => _response = "Add leads first to generate a plan.");
      return;
    }
    setState(() => _loading = true);
    try {
      final contextString = globalLeads
          .map((e) => "${e.name}: ${e.message}")
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
                      "Based on these startup leads: $contextString. Suggest top 3 priorities and specific follow-up actions for a founder today.",
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
              child: const Text("What should I do today?"),
            ),
          ],
        ),
      ),
    );
  }
}
