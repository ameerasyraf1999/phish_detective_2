import 'package:flutter/material.dart';
import 'package:another_telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';

List<SmsMessage> fetchedMessages = [];

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sms, size: 64, color: Colors.deepPurple),
          SizedBox(height: 16),
          Text('Listening for incoming SMS...', style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}

class SmsLogScreen extends StatelessWidget {
  const SmsLogScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return fetchedMessages.isEmpty
        ? const Center(child: Text('No SMS messages loaded.'))
        : ListView.builder(
            itemCount: fetchedMessages.length,
            itemBuilder: (context, index) {
              final sms = fetchedMessages[index];
              return ListTile(
                title: Text(sms.address ?? 'Unknown'),
                subtitle: Text(sms.body ?? ''),
                trailing: const Icon(Icons.sms),
              );
            },
          );
  }
}

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('About Us'));
  }
}

@pragma('vm:entry-point')
Future<void> backgroundMessageHandler(SmsMessage message) async {
  // Do nothing or minimal work here. Do not update fetchedMessages.
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final telephony = Telephony.instance;
  telephony.listenIncomingSms(
    onNewMessage: (SmsMessage message) {
      fetchedMessages.insert(0, message);
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
