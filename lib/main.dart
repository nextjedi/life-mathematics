import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/calculator_screen.dart';
import 'app/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('darkMode') ?? false;

  runApp(LifeMathematicsApp(isDarkMode: isDarkMode));
}

class LifeMathematicsApp extends StatefulWidget {
  final bool isDarkMode;

  const LifeMathematicsApp({Key? key, required this.isDarkMode}) : super(key: key);

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
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _themeMode == ThemeMode.dark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Life Mathematics',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: const CalculatorScreen(),
    );
  }
}
