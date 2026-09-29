import 'package:flutter/material.dart';
import 'screens/match_screen.dart';
import 'screens/squad_screen.dart';
import 'screens/masia_screen.dart';
import 'screens/finance_screen.dart';

void main() {
  runApp(const CulesHubApp());
}

class CulesHubApp extends StatelessWidget {
  const CulesHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Culés Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFF004D98),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    BarcaMatchScreen(),
    SquadScreen(),
    MasiaScreen(),
    FinanceScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_soccer),
            label: 'Матчи',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: 'Состав 26/27',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'La Masia',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Финансы',
          ),
        ],
      ),
    );
  }
}