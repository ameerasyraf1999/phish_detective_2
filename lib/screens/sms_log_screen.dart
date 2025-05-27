import 'package:flutter/material.dart';
import '../main.dart';

class SmsLogScreen extends StatefulWidget {
  const SmsLogScreen({super.key});
  @override
  State<SmsLogScreen> createState() => _SmsLogScreenState();
}

class _SmsLogScreenState extends State<SmsLogScreen> {
  String _filter = 'all';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredMessages = _getFilteredMessages();
    return Column(
      children: [
        _buildFilterAndSearch(),
        Expanded(
          child: filteredMessages.isEmpty
              ? _buildEmptyState(context)
              : _buildMessagesList(filteredMessages),
        ),
      ],
    );
  }

  Widget _buildFilterAndSearch() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search messages...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildFilterChip('All', 'all')),
                const SizedBox(width: 8),
                Expanded(child: _buildFilterChip('Safe', 'safe')),
                const SizedBox(width: 8),
                Expanded(child: _buildFilterChip('Phishing', 'phishing')),
                const SizedBox(width: 8),
                Expanded(child: _buildFilterChip('Pending', 'pending')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _filter = value;
        });
      },
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.message_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No messages found',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Messages will appear here when detected',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(List messages) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msgMap = messages[index];
        return _buildMessageCard(msgMap);
      },
    );
  }

  Widget _buildMessageCard(Map<String, dynamic> msgMap) {
    final sms = msgMap['sms'];
    final isAnalyzed = msgMap['isAnalyzed'] ?? false;
    final isPhishing = msgMap['isPhishing'] ?? false;
    final phishingScore = msgMap['phishingScore'];
    Color borderColor;
    Color iconColor;
    IconData icon;
    String status;
    if (!isAnalyzed) {
      borderColor = Colors.orange;
      iconColor = Colors.orange;
      icon = Icons.pending;
      status = 'Pending Analysis';
    } else if (isPhishing) {
      borderColor = Colors.red;
      iconColor = Colors.red;
      icon = Icons.warning;
      status = 'Phishing Detected';
    } else {
      borderColor = Colors.green;
      iconColor = Colors.green;
      icon = Icons.check_circle;
      status = 'Safe';
    }
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: borderColor, width: 4)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: iconColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    status,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: iconColor,
                    ),
                  ),
                  const Spacer(),
                  if (phishingScore != null && isAnalyzed)
                    Text(
                      'Score: ${(phishingScore * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'From: ${sms.address ?? sms.sender ?? "Unknown"}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                (sms.body ?? sms.message ?? '').toString(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    _formatDateTime(sms.date ?? sms.timestamp),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List _getFilteredMessages() {
    var filtered = List.from(fetchedMessages);
    // Apply filter
    switch (_filter) {
      case 'safe':
        filtered = filtered
            .where(
              (m) => (m['isAnalyzed'] ?? false) && !(m['isPhishing'] ?? false),
            )
            .toList();
        break;
      case 'phishing':
        filtered = filtered
            .where(
              (m) => (m['isAnalyzed'] ?? false) && (m['isPhishing'] ?? false),
            )
            .toList();
        break;
      case 'pending':
        filtered = filtered.where((m) => !(m['isAnalyzed'] ?? false)).toList();
        break;
    }
    // Apply search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((m) {
        final sms = m['sms'];
        final sender = (sms.address ?? sms.sender ?? '')
            .toString()
            .toLowerCase();
        final body = (sms.body ?? sms.message ?? '').toString().toLowerCase();
        return sender.contains(_searchQuery) || body.contains(_searchQuery);
      }).toList();
    }
    return filtered;
  }

  String _formatDateTime(dynamic timestamp) {
    if (timestamp == null) return '';
    DateTime dt;
    if (timestamp is int) {
      dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    } else if (timestamp is DateTime) {
      dt = timestamp;
    } else {
      return '';
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDate = DateTime(dt.year, dt.month, dt.day);
    if (msgDate == today) {
      return 'Today ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } else if (msgDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
  }
}
