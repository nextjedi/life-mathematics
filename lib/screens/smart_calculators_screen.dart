import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/theme.dart';
import 'compound_interest_screen.dart';
import 'emi_calculator_screen.dart';
import 'investment_returns_screen.dart';
import 'loan_calculator_screen.dart';

class SmartCalculatorsScreen extends StatelessWidget {
  const SmartCalculatorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'Choose a calculator',
              style: GoogleFonts.manrope(
                fontSize: 13,
                color: palette.onSurfaceVariant,
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
                title: 'Loan\nPayoff',
                subtitle: 'Finish early',
                gradientColors: LoanCalculatorScreen.accent,
                icon: Icons.account_balance_outlined,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoanCalculatorScreen(),
                  ),
                ),
              ),
              _CalcCard(
                title: 'EMI\nCalculator',
                subtitle: 'Monthly payments',
                gradientColors: EmiCalculatorScreen.accent,
                icon: Icons.payments_outlined,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EmiCalculatorScreen(),
                  ),
                ),
              ),
              _CalcCard(
                title: 'Investment\nReturns',
                subtitle: 'SIP and ROI',
                gradientColors: InvestmentReturnsScreen.accent,
                icon: Icons.show_chart_rounded,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const InvestmentReturnsScreen(),
                  ),
                ),
              ),
            ],
          ),
        ],
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
    final palette = context.palette;

    return Semantics(
      button: true,
      label: title.replaceAll('\n', ' '),
      child: Material(
        color: palette.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(18),
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
                    color: palette.onSurface,
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
                          color: palette.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: palette.onSurfaceVariant,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
