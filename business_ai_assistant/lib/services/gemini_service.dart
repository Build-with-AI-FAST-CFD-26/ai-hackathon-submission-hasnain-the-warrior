import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String _apiKey = "-EdyDfY";
  static const String _baseUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent";

  /// Core function to communicate with Gemini API (Made public for FounderSync)
  Future<String> generateContent(String prompt) async {
    try {
      final url = Uri.parse("$_baseUrl?key=$_apiKey");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt},
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        return "Error: Received status ${response.statusCode} from AI service.";
      }
    } catch (e) {
      return "Error: Connection failed. $e";
    }
  }

  /// Categorizes lead as hot, warm, or cold with a reason
  Future<String> analyzeLead(String name, String message) async {
    final prompt =
        """
      Analyze this startup lead: 
      Name: $name
      Message: $message
      
      Determine if this is a 'Hot', 'Warm', or 'Cold' lead. 
      Provide a brief explanation of why.
    """;
    return await generateContent(prompt);
  }

  /// Generates a professional follow-up draft
  Future<String> generateFollowUp(String name, String message) async {
    final prompt =
        """
      Write a professional, concise, and friendly follow-up message 
      for a lead named $name who reached out with: '$message'.
      The goal is to move the conversation forward.
    """;
    return await generateContent(prompt);
  }

  /// Provides a founder's daily plan based on all aggregated leads
  Future<String> getDailyPlan(String allLeadsText) async {
    final prompt =
        """
      You are an AI Chief of Staff for a startup founder. 
      Review the following list of leads and interactions:
      $allLeadsText
      
      Suggest the top 3 priorities for today and specific follow-up 
      actions to ensure no high-value opportunities are missed.
    """;
    return await generateContent(prompt);
  }
}
