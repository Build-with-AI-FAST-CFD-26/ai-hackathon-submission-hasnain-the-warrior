import 'package:flutter/material.dart';
import 'add_lead_screen.dart';
import 'view_leads_screen.dart';
import 'ai_suggestions_screen.dart';
import 'founder_sync_screen.dart'; // Isay import karna zaroori hai

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Founder AI Assistant',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        // ScrollView add kiya taake screen se bahar na jaye card
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _menuCard(
              context,
              "Add New Lead",
              Icons.person_add_alt_1,
              const AddLeadScreen(),
            ),
            const SizedBox(height: 16),
            _menuCard(
              context,
              "View All Leads",
              Icons.people_outline,
              const ViewLeadsScreen(),
            ),
            const SizedBox(height: 16),
            _menuCard(
              context,
              "AI Suggestions",
              Icons.auto_awesome,
              const AISuggestionsScreen(),
            ),
            const SizedBox(height: 16),

            // Naya Founder Sync Card yahan add kiya gaya hai
            _menuCard(
              context,
              "Founder Sync",
              Icons.sync_alt,
              const FounderSyncScreen(),
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
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Row(
          children: [
            Icon(icon, size: 28, color: Colors.blueAccent),
            const SizedBox(width: 20),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
