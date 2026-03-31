import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/theme.dart';
import 'providers/history_provider.dart';
import 'screens/calculator_screen.dart';
import 'screens/history_screen.dart';
import 'screens/smart_calculators_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('darkMode') ?? true; // default dark

  runApp(LifeMathematicsApp(isDarkMode: isDarkMode));
}

class LifeMathematicsApp extends StatefulWidget {
  final bool isDarkMode;

  const LifeMathematicsApp({super.key, required this.isDarkMode});

  @override
  State<LifeMathematicsApp> createState() => LifeMathematicsAppState();

  static LifeMathematicsAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<LifeMathematicsAppState>();
  }
}

class LifeMathematicsAppState extends State<LifeMathematicsApp> {
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
  const HomePage({super.key});

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

  static const List<({IconData icon, String label})> _navItems = [
    (icon: Icons.calculate_outlined, label: 'Calculator'),
    (icon: Icons.auto_awesome_outlined, label: 'Smart Calc'),
    (icon: Icons.history_outlined, label: 'History'),
  ];

  @override
  Widget build(BuildContext context) {
    final appState = LifeMathematicsApp.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Life Mathematics',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.onSurface,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => appState?.toggleTheme(),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppTheme.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  size: 20,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
      // No bottomNavigationBar — we use a Stack overlay instead
      body: Stack(
        children: [
          // Screen content with bottom padding for the nav bar
          Padding(
            padding: const EdgeInsets.only(bottom: 80),
            child: _screens[_selectedIndex],
          ),

          // Floating frosted glass bottom nav
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: _FloatingNav(
              selectedIndex: _selectedIndex,
              items: _navItems,
              onTap: (i) => setState(() => _selectedIndex = i),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingNav extends StatelessWidget {
  final int selectedIndex;
  final List<({IconData icon, String label})> items;
  final ValueChanged<int> onTap;

  const _FloatingNav({
    required this.selectedIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerHighest.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final isActive = i == selectedIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.icon,
                        size: 22,
                        color: isActive
                            ? AppTheme.primary
                            : AppTheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isActive
                              ? AppTheme.primary
                              : AppTheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Active dot
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isActive ? 4 : 0,
                        height: isActive ? 4 : 0,
                        decoration: const BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
