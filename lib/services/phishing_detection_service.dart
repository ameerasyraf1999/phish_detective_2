import 'dart:convert';
import 'package:http/http.dart' as http;

class PhishingDetectionService {
  static const String baseUrl =
      'https://phish-detective-470eb265a12b.herokuapp.com';

  static Future<PhishingResult> detectPhishing(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PhishingResult.fromJson(data);
      } else {
        throw Exception('Failed to get prediction: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<bool> checkApiHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/health'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'healthy' && data['model_loaded'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

class PhishingResult {
  final bool success;
  final bool isPhishing;
  final double phishingProbability;
  final String confidence;
  final String? error;

  PhishingResult({
    required this.success,
    required this.isPhishing,
    required this.phishingProbability,
    required this.confidence,
    this.error,
  });

  factory PhishingResult.fromJson(Map<String, dynamic> json) {
    return PhishingResult(
      success: json['success'] ?? false,
      isPhishing: json['is_phishing'] ?? false,
      phishingProbability: (json['phishing_probability'] ?? 0.0).toDouble(),
      confidence: json['confidence'] ?? 'unknown',
      error: json['error'],
    );
  }

  String get riskLevel {
    if (phishingProbability >= 0.5) return 'High Risk';
    if (phishingProbability >= 0.12) return 'Medium Risk';
    if (phishingProbability >= 0.02) return 'Low Risk';
    return 'Safe';
  }
}
