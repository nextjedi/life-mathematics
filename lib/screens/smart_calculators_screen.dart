import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/theme.dart';
import 'compound_interest_screen.dart';

class SmartCalculatorsScreen extends StatelessWidget {
  const SmartCalculatorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'Choose a calculator',
              style: GoogleFonts.manrope(
                fontSize: 13,
                color: AppTheme.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ),
          ),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _CalcCard(
                title: 'Compound\nInterest',
                subtitle: 'Grow your wealth',
                gradientColors: const [Color(0xFF00C853), Color(0xFF1B5E20)],
                icon: Icons.trending_up_rounded,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CompoundInterestScreen(),
                  ),
                ),
              ),
              _CalcCard(
                title: 'Loan\nCalculator',
                subtitle: 'Plan your debt',
                gradientColors: const [Color(0xFF2196F3), Color(0xFF0D47A1)],
                icon: Icons.account_balance_outlined,
                onTap: () => _comingSoon(context),
              ),
              _CalcCard(
                title: 'EMI\nCalculator',
                subtitle: 'Monthly payments',
                gradientColors: const [Color(0xFFFF9800), Color(0xFFE65100)],
                icon: Icons.payments_outlined,
                onTap: () => _comingSoon(context),
              ),
              _CalcCard(
                title: 'Investment\nReturns',
                subtitle: 'Track your ROI',
                gradientColors: const [Color(0xFF9C27B0), Color(0xFF4A148C)],
                icon: Icons.show_chart_rounded,
                onTap: () => _comingSoon(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Coming soon!',
          style: GoogleFonts.manrope(color: Colors.white),
        ),
        backgroundColor: AppTheme.surfaceContainerHighest,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _CalcCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final IconData icon;
  final VoidCallback onTap;

  const _CalcCard({
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainer,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gradient icon circle
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const Spacer(),
            Text(
              title,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurface,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    subtitle,
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: AppTheme.onSurfaceVariant,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
