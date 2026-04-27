import 'package:flutter/material.dart';
import '../services/gemini_service.dart'; // Apna sahi path check karlein

class FounderSyncScreen extends StatefulWidget {
  const FounderSyncScreen({super.key});

  @override
  State<FounderSyncScreen> createState() => _FounderSyncScreenState();
}

class _FounderSyncScreenState extends State<FounderSyncScreen> {
  final TextEditingController _paulController = TextEditingController();
  final TextEditingController _samController = TextEditingController();
  final GeminiService _geminiService = GeminiService();
  bool _isLoading = false;

  // AI Logic for Sync Analysis
  Future<void> _analyzeSync() async {
    if (_paulController.text.trim().isEmpty ||
        _samController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter updates for both Paul and Sam'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // AI Prompt
    final String syncPrompt =
        """
      You are a Startup Advisor. Compare these two founder updates:
      
      PAUL'S UPDATES:
      ${_paulController.text}

      SAM'S UPDATES:
      ${_samController.text}

      Please provide a concise analysis:
      1. Potential Conflicts (Are they working on the same thing differently?)
      2. Misalignment (Is one focused on sales while the other is changing the product?)
      3. Action Plan (3 bullet points to get them on the same page).
    """;

    try {
      final result = await _geminiService.generateContent(syncPrompt);
      _showResultBottomSheet(result);
    } catch (e) {
      _showResultBottomSheet("Error connecting to AI: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Result dikhane ke liye behtar tareeka
  void _showResultBottomSheet(String content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.blueAccent),
                SizedBox(width: 10),
                Text(
                  "Sync Analysis",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.all(15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Got it!",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Founder Sync",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Compare progress between founders to ensure everyone is aligned.",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 25),

            // Paul's Section
            _buildInputCard(
              title: "Paul's Updates",
              controller: _paulController,
              icon: Icons.person,
              accentColor: Colors.blueAccent,
            ),

            const SizedBox(height: 20),

            // Sam's Section
            _buildInputCard(
              title: "Sam's Updates",
              controller: _samController,
              icon: Icons.person_outline,
              accentColor: Colors.green,
            ),

            const SizedBox(height: 35),

            // Analyze Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _analyzeSync,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.sync, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            "Run Sync Analysis",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard({
    required String title,
    required TextEditingController controller,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: "What did $title accomplish today?",
              fillColor: accentColor.withOpacity(0.05),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(15),
            ),
          ),
        ],
      ),
    );
  }
}
