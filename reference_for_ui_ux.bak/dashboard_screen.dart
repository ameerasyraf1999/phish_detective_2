import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return RefreshIndicator(
            onRefresh: () async {
              await appProvider.refreshSmsData();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusCard(context, appProvider),
                  const SizedBox(height: 20),
                  _buildStatsCards(context, appProvider),
                  const SizedBox(height: 20),
                  _buildChart(context, appProvider),
                  const SizedBox(height: 20),
                  _buildRecentActivity(context, appProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, AppProvider appProvider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  appProvider.isActive
                      ? Icons.security
                      : Icons.security_outlined,
                  size: 32,
                  color: appProvider.isActive ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SMS Phishing Detection',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        appProvider.isActive
                            ? 'Active - Monitoring SMS messages'
                            : 'Inactive - Tap to activate',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: appProvider.isActive
                              ? Colors.green
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: appProvider.isActive,
                  onChanged: appProvider.isLoading
                      ? null
                      : (_) => appProvider.toggleActivation(),
                ),
              ],
            ),
            if (!appProvider.hasPermissions) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'SMS permissions required to monitor messages',
                        style: TextStyle(color: Colors.orange[700]),
                      ),
                    ),
                    TextButton(
                      onPressed: appProvider.requestPermissions,
                      child: const Text('Grant'),
                    ),
                  ],
                ),
              ),
            ],
            if (appProvider.errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        appProvider.errorMessage!,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                    IconButton(
                      onPressed: appProvider.clearError,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
            ],
            if (!appProvider.isDefaultSmsApp) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'For full SMS monitoring, set this app as the default SMS app.',
                            style: TextStyle(color: Colors.blue[700]),
                          ),
                        ),
                        TextButton(
                          onPressed: appProvider.promptSetDefaultSmsApp,
                          child: const Text('Set as Default'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'If the system dialog does not appear, open your device settings and set the default SMS app manually:',
                      style: TextStyle(color: Colors.blue[700], fontSize: 13),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: appProvider.openDefaultAppsSettings,
                          child: const Text('Open Default Apps Settings'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, AppProvider appProvider) {
    final stats = appProvider.stats;
    if (stats == null) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Messages',
                stats.totalMessages.toString(),
                Icons.message,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Phishing Detected',
                stats.phishingMessages.toString(),
                Icons.warning,
                Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Safe Messages',
                stats.safeMessages.toString(),
                Icons.check_circle,
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Pending Analysis',
                stats.pendingAnalysis.toString(),
                Icons.hourglass_empty,
                Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context, AppProvider appProvider) {
    final stats = appProvider.stats;
    if (stats == null || stats.totalMessages == 0) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Message Analysis',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: stats.safeMessages.toDouble(),
                      title: 'Safe\n${stats.safeMessages}',
                      color: Colors.green,
                      radius: 80,
                    ),
                    PieChartSectionData(
                      value: stats.phishingMessages.toDouble(),
                      title: 'Phishing\n${stats.phishingMessages}',
                      color: Colors.red,
                      radius: 80,
                    ),
                    if (stats.pendingAnalysis > 0)
                      PieChartSectionData(
                        value: stats.pendingAnalysis.toDouble(),
                        title: 'Pending\n${stats.pendingAnalysis}',
                        color: Colors.orange,
                        radius: 80,
                      ),
                  ],
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, AppProvider appProvider) {
    final recentMessages = appProvider.smsMessages.take(5).toList();

    if (recentMessages.isEmpty) {
      return Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recent Activity',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'No messages yet\nActivate the detector to start monitoring',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...recentMessages.map((message) => _buildMessageTile(message)),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageTile(dynamic message) {
    final isPhishing = message.isPhishing ?? false;
    final isAnalyzed = message.isAnalyzed;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            isAnalyzed
                ? (isPhishing ? Icons.warning : Icons.check_circle)
                : Icons.pending,
            color: isAnalyzed
                ? (isPhishing ? Colors.red : Colors.green)
                : Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.sender,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  message.message.length > 50
                      ? '${message.message.substring(0, 50)}...'
                      : message.message,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            _formatTime(message.timestamp),
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
