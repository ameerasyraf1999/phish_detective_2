import 'package:flutter/material.dart';
import 'package:another_telephony/telephony.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'screens/dashboard_screen.dart';
import 'screens/sms_log_screen.dart';
import 'screens/about_us_screen.dart';
import 'services/phishing_detection_service.dart';
import 'services/local_db_service.dart';

List<Map<String, dynamic>> fetchedMessages = [];

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _showNotification(String title, String body) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'sms_phish_channel',
        'SMS Phishing Alerts',
        channelDescription: 'Notifications for SMS Phishing Detector',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
      );
  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );
  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    platformChannelSpecifics,
  );
}

Future<void> _showPersistentNotification() async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'sms_phish_persistent',
        'SMS Phishing Monitoring',
        channelDescription: 'Persistent notification for background monitoring',
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        autoCancel: false,
        showWhen: false,
      );
  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );
  await flutterLocalNotificationsPlugin.show(
    1,
    'SMS Phishing Detector',
    'Monitoring for new SMS messages...',
    platformChannelSpecifics,
  );
}

Future<void> _cancelPersistentNotification() async {
  await flutterLocalNotificationsPlugin.cancel(1);
}

@pragma('vm:entry-point')
Future<void> backgroundMessageHandler(SmsMessage message) async {
  // Do nothing or minimal work here. Do not update fetchedMessages.
}

enum MonitoringState { active, inactive }

class MonitoringController {
  static MonitoringState state = MonitoringState.active;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Load from local DB on startup
  final dbLogs = await LocalDbService.getAllSmsLogs();
  fetchedMessages = dbLogs.map((row) {
    return {
      'sms': {
        'address': row['address'],
        'body': row['body'],
        'date': row['date'],
      },
      'isAnalyzed': row['isAnalyzed'] == 1,
      'isPhishing': row['isPhishing'] == 1,
      'phishingScore': row['phishingScore'],
    };
  }).toList();

  final telephony = Telephony.instance;
  telephony.listenIncomingSms(
    onNewMessage: (SmsMessage message) async {
      if (MonitoringController.state == MonitoringState.inactive) return;
      final msgMap = {
        'sms': message,
        'isAnalyzed': false,
        'isPhishing': false,
        'phishingScore': null,
      };
      fetchedMessages.insert(0, msgMap);
      try {
        final result = await PhishingDetectionService.detectPhishing(
          message.body ?? '',
        );
        msgMap['isAnalyzed'] = true;
        msgMap['isPhishing'] = result.isPhishing;
        msgMap['phishingScore'] = result.phishingProbability;
        // Push notification for phishing or medium/high risk
        if (result.isPhishing || result.phishingProbability >= 0.2) {
          await _showNotification(
            result.isPhishing ? 'Phishing SMS Detected!' : 'Suspicious SMS',
            message.body ?? '',
          );
        }
      } catch (e) {
        msgMap['isAnalyzed'] = true;
        msgMap['isPhishing'] = false;
        msgMap['phishingScore'] = 0.0;
      }
      await LocalDbService.insertSmsLog(msgMap);
    },
    onBackgroundMessage: backgroundMessageHandler,
    listenInBackground: true,
  );

  // Show persistent notification if monitoring is active
  if (MonitoringController.state == MonitoringState.active) {
    await _showPersistentNotification();
  } else {
    await _cancelPersistentNotification();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMS Phishing Detector',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  static const List<Widget> _screens = <Widget>[
    DashboardScreen(),
    SmsLogScreen(),
    AboutUsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.sms), label: 'SMS Log'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'About Us'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
