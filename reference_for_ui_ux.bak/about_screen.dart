import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(context),
            const SizedBox(height: 20),
            _buildFeaturesCard(context),
            const SizedBox(height: 20),
            _buildHowItWorksCard(context),
            const SizedBox(height: 20),
            _buildSecurityCard(context),
            const SizedBox(height: 20),
            _buildActionsCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(
              Icons.security,
              size: 64,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'SMS Phish Detective',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Advanced SMS Phishing Detection',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Version 1.0.0',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesCard(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Features',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildFeatureItem(
              Icons.speed,
              'Real-time Detection',
              'Automatically analyzes incoming SMS messages for phishing attempts',
            ),
            _buildFeatureItem(
              Icons.psychology,
              'AI-Powered Analysis',
              'Uses machine learning models trained on thousands of phishing examples',
            ),
            _buildFeatureItem(
              Icons.history,
              'Message Logging',
              'Keeps a detailed log of all analyzed messages with threat scores',
            ),
            _buildFeatureItem(
              Icons.trending_up,
              'Statistics Dashboard',
              'View comprehensive statistics about detected threats',
            ),
            _buildFeatureItem(
              Icons.privacy_tip,
              'Privacy Focused',
              'All analysis is done securely without storing personal data',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksCard(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How It Works',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildStepItem(
              1,
              'Message Monitoring',
              'The app monitors incoming SMS messages in real-time',
            ),
            _buildStepItem(
              2,
              'AI Analysis',
              'Each message is sent to our secure AI model for analysis',
            ),
            _buildStepItem(
              3,
              'Threat Scoring',
              'Messages receive a threat score from 0-100%',
            ),
            _buildStepItem(
              4,
              'Alert & Log',
              'Suspicious messages are flagged and logged for review',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepItem(int step, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.blue,
            child: Text(
              step.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: Colors.green[700]),
                const SizedBox(width: 8),
                Text(
                  'Security & Privacy',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSecurityItem(
              Icons.lock,
              'End-to-End Encryption',
              'All communications with our analysis server are encrypted',
            ),
            _buildSecurityItem(
              Icons.no_accounts,
              'No Personal Data Storage',
              'We do not store your personal information or message content',
            ),
            _buildSecurityItem(
              Icons.local_police,
              'Local Processing',
              'Message metadata is processed locally on your device',
            ),
            _buildSecurityItem(
              Icons.delete_sweep,
              'Automatic Cleanup',
              'Analysis data is automatically cleaned from our servers',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.green[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Consumer<AppProvider>(
              builder: (context, appProvider, child) {
                return Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.refresh),
                      title: const Text('Sync Messages'),
                      subtitle: const Text('Manually sync recent SMS messages'),
                      onTap: appProvider.isLoading
                          ? null
                          : () => appProvider.refreshSmsData(),
                      trailing: appProvider.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(),
                            )
                          : const Icon(Icons.arrow_forward_ios),
                    ),
                    ListTile(
                      leading: const Icon(Icons.analytics),
                      title: const Text('Analyze Pending'),
                      subtitle: const Text(
                        'Analyze messages waiting for review',
                      ),
                      onTap: appProvider.isLoading
                          ? null
                          : () => appProvider.analyzePendingSms(),
                      trailing: appProvider.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(),
                            )
                          : const Icon(Icons.arrow_forward_ios),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.delete_forever,
                        color: Colors.red[600],
                      ),
                      title: Text(
                        'Clear All Logs',
                        style: TextStyle(color: Colors.red[600]),
                      ),
                      subtitle: const Text('Remove all logged messages'),
                      onTap: () => _showClearDialog(context, appProvider),
                      trailing: const Icon(Icons.arrow_forward_ios),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Text(
                    'Developed with ❤️ for security',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '© 2025 SMS Phish Detective',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearDialog(BuildContext context, AppProvider appProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Logs'),
          content: const Text(
            'Are you sure you want to clear all logged messages? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                appProvider.clearAllSms();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All logs cleared successfully'),
                  ),
                );
              },
              child: const Text(
                'Clear All',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
