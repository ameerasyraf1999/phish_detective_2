import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../main.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();
    final recentMessages = fetchedMessages.take(5).toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(context),
          const SizedBox(height: 20),
          _buildStatsCards(stats),
          const SizedBox(height: 20),
          _buildChart(context, stats),
          const SizedBox(height: 20),
          _buildRecentActivity(context, recentMessages),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.security, size: 32, color: Colors.green),
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
                    'Active - Monitoring SMS messages',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.green),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(_Stats stats) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total',
            stats.total.toString(),
            Icons.message,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Phishing',
            stats.phishing.toString(),
            Icons.warning,
            Colors.red,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Safe',
            stats.safe.toString(),
            Icons.check_circle,
            Colors.green,
          ),
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

  Widget _buildChart(BuildContext context, _Stats stats) {
    if (stats.total == 0) return const SizedBox.shrink();
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
                      value: stats.safe.toDouble(),
                      title: 'Safe\n${stats.safe}',
                      color: Colors.green,
                      radius: 80,
                    ),
                    PieChartSectionData(
                      value: stats.phishing.toDouble(),
                      title: 'Phishing\n${stats.phishing}',
                      color: Colors.red,
                      radius: 80,
                    ),
                    if (stats.pending > 0)
                      PieChartSectionData(
                        value: stats.pending.toDouble(),
                        title: 'Pending\n${stats.pending}',
                        color: Colors.orange,
                        radius: 80,
                      ),
                    if (stats.medium > 0)
                      PieChartSectionData(
                        value: stats.medium.toDouble(),
                        title: 'Medium\n${stats.medium}',
                        color: Colors.amber,
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

  Widget _buildRecentActivity(BuildContext context, List recent) {
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
            if (recent.isEmpty)
              const Center(
                child: Text(
                  'No messages yet\nActivate the detector to start monitoring',
                  textAlign: TextAlign.center,
                ),
              ),
            ...recent.map((msgMap) => _buildMessageTile(msgMap)),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageTile(Map<String, dynamic> msgMap) {
    final sms = msgMap['sms'];
    String address, body;
    dynamic date;
    if (sms is Map) {
      address = sms['address'] ?? 'Unknown';
      body = sms['body'] ?? '';
      date = sms['date'];
    } else {
      address = sms.address ?? 'Unknown';
      body = sms.body ?? '';
      date = sms.date;
    }
    final isAnalyzed = msgMap['isAnalyzed'] ?? false;
    final isPhishing = msgMap['isPhishing'] ?? false;
    Color iconColor;
    IconData icon;
    if (!isAnalyzed) {
      iconColor = Colors.orange;
      icon = Icons.pending;
    } else if (isPhishing) {
      iconColor = Colors.red;
      icon = Icons.warning;
    } else {
      iconColor = Colors.green;
      icon = Icons.check_circle;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  body.length > 50 ? '${body.substring(0, 50)}...' : body,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            _formatTime(date),
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  String _formatTime(int? timestamp) {
    if (timestamp == null) return '';
    final now = DateTime.now();
    final msgTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final diff = now.difference(msgTime);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  _Stats _calculateStats() {
    int total = fetchedMessages.length;
    int phishing = fetchedMessages.where((m) => m['isPhishing'] == true).length;
    int safe = fetchedMessages
        .where(
          (m) =>
              m['isAnalyzed'] == true &&
              m['isPhishing'] == false &&
              ((m['phishingScore'] ?? 0) < 0.2),
        )
        .length;
    int medium = fetchedMessages
        .where(
          (m) =>
              m['isAnalyzed'] == true &&
              m['isPhishing'] == false &&
              (m['phishingScore'] ?? 0) >= 0.2 &&
              (m['phishingScore'] ?? 0) < 0.8,
        )
        .length;
    int pending = fetchedMessages
        .where((m) => !(m['isAnalyzed'] ?? false))
        .length;
    return _Stats(
      total: total,
      phishing: phishing,
      safe: safe,
      medium: medium,
      pending: pending,
    );
  }
}

class _Stats {
  final int total;
  final int phishing;
  final int safe;
  final int medium;
  final int pending;
  _Stats({
    required this.total,
    required this.phishing,
    required this.safe,
    required this.medium,
    required this.pending,
  });
}
