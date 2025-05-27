# SMS Phishing Detection API - Flutter Integration Guide

## Overview
This API provides SMS phishing detection capabilities for Flutter applications. It uses machine learning to analyze text messages and determine if they are legitimate or phishing attempts.

## API Endpoints

### Health Check
```
GET /api/health
```
Returns the API health status and whether the ML model is loaded.

**Response:**
```json
{
  "status": "healthy",
  "message": "SMS Phishing Detection API is running",
  "model_loaded": true
}
```

### Phishing Detection
```
POST /api/predict
```
Analyzes a text message for phishing indicators.

**Request Body:**
```json
{
  "message": "Your SMS message text here"
}
```

**Response:**
```json
{
  "success": true,
  "prediction": 0,
  "is_phishing": false,
  "phishing_probability": 0.15,
  "confidence": "high",
  "message_analyzed": "Your SMS message text here"
}
```

## Flutter Integration

### 1. Add Dependencies
Add to your `pubspec.yaml`:
```yaml
dependencies:
  http: ^1.1.0
```

### 2. Create the Service Class
Create `lib/services/phishing_detection_service.dart` in your Flutter project:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class PhishingDetectionService {
  static const String baseUrl = 'https://phish-detective-470eb265a12b.herokuapp.com';

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
    if (phishingProbability >= 0.8) return 'High Risk';
    if (phishingProbability >= 0.6) return 'Medium Risk';
    if (phishingProbability >= 0.4) return 'Low Risk';
    return 'Safe';
  }
}
```

### 3. Update the Base URL
Use the actual Heroku app URL:
```dart
static const String baseUrl = 'https://phish-detective-470eb265a12b.herokuapp.com';
```

### 4. Usage Example
```dart
// Check if API is healthy
bool isHealthy = await PhishingDetectionService.checkApiHealth();

// Analyze a message
try {
  PhishingResult result = await PhishingDetectionService.detectPhishing(
    "Congratulations! You've won $1000. Click here to claim: http://fake-link.com"
  );
  
  if (result.success) {
    print('Is Phishing: ${result.isPhishing}');
    print('Risk Level: ${result.riskLevel}');
    print('Probability: ${result.phishingProbability}');
  }
} catch (e) {
  print('Error: $e');
}
```

## Response Fields Explained

- `success`: Whether the API call was successful
- `prediction`: 0 for legitimate, 1 for phishing
- `is_phishing`: Boolean indicating if message is phishing
- `phishing_probability`: Probability score (0.0 to 1.0)
- `confidence`: "high" or "medium" based on probability
- `message_analyzed`: First 100 characters of analyzed message

## Error Handling

The API returns structured error responses:
```json
{
  "success": false,
  "error": "Error description here"
}
```

Common error scenarios:
- Model not loaded (500 error)
- Missing message in request (400 error)
- Empty message (400 error)
- Network connectivity issues

## Deployment Status

To check if your API is deployed and accessible:

1. Visit: `https://phish-detective-470eb265a12b.herokuapp.com/api/health`
2. You should see a JSON response with status information

If you see an iframe error, your app needs to be deployed to Heroku:

```bash
# Deploy to Heroku
git add .
git commit -m "Add CORS support for Flutter integration"
git push heroku main
```

## Security Considerations

- The API includes CORS support for cross-origin requests
- No authentication is currently implemented (consider adding for production)
- Rate limiting is not implemented (consider adding for production)
- HTTPS is enforced through Heroku

## Testing the API

You can test the API using curl:

```bash
# Health check
curl https://phish-detective-470eb265a12b.herokuapp.com/api/health

# Prediction
curl -X POST https://phish-detective-470eb265a12b.herokuapp.com/api/predict \
  -H "Content-Type: application/json" \
  -d '{"message": "Test message here"}'
```

## Troubleshooting

1. **CORS Errors**: Ensure `flask-cors` is installed and CORS is enabled
2. **Model Not Loaded**: Check that `phishing_sms_model.joblib` is included in deployment
3. **404 Errors**: Verify your Heroku app name and endpoint URLs
4. **Network Timeouts**: Check your internet connection and Heroku app status

## Features

The ML model analyzes various features:
- URL detection in messages
- Phone number patterns
- Text characteristics (length, word count, special characters)
- Urgent language detection
- Uppercase letter frequency
- Word density calculations

This provides comprehensive phishing detection for SMS messages in your Flutter applications.
