import 'package:flutter/material.dart';
import 'package:another_telephony/telephony.dart';
import 'screens/dashboard_screen.dart';
import 'screens/sms_log_screen.dart';
import 'screens/about_us_screen.dart';
import 'services/phishing_detection_service.dart';
import 'services/local_db_service.dart';

List<Map<String, dynamic>> fetchedMessages = [];

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
      } catch (e) {
        msgMap['isAnalyzed'] = true;
        msgMap['isPhishing'] = false;
        msgMap['phishingScore'] = 0.0;
      }
      await LocalDbService.insertSmsLog(msgMap);
    },
    onBackgroundMessage: backgroundMessageHandler,
  );
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
