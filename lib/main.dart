import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/theme.dart';
import 'screens/calculator_screen.dart';
import 'screens/smart_calculators_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';
import 'providers/history_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('darkMode') ?? false;

  runApp(LifeMathematicsApp(isDarkMode: isDarkMode));
}

class LifeMathematicsApp extends StatefulWidget {
  final bool isDarkMode;

  const LifeMathematicsApp({Key? key, required this.isDarkMode})
      : super(key: key);

  @override
  State<LifeMathematicsApp> createState() => _LifeMathematicsAppState();

  static _LifeMathematicsAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<_LifeMathematicsAppState>();
  }
}

class _LifeMathematicsAppState extends State<LifeMathematicsApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleTheme() async {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _themeMode == ThemeMode.dark);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
      ],
      child: MaterialApp(
        title: 'Life Mathematics',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _themeMode,
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    CalculatorScreen(),
    SmartCalculatorsScreen(),
    HistoryScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = LifeMathematicsApp.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Life Mathematics'),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () => appState?.toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Calculator',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy),
            label: 'Smart Calc',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
