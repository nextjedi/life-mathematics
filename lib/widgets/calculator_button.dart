import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/theme.dart';

enum ButtonType { number, operator, equal, clear, function }

class CalculatorButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonType type;

  const CalculatorButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.number,
  });

  @override
  Widget build(BuildContext context) {
    if (type == ButtonType.equal) {
      return _GradientButton(text: text, onPressed: onPressed);
    }

    final bg = _bgColor();
    final fg = _fgColor();

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        borderRadius: BorderRadius.circular(999),
        splashColor: AppTheme.primary.withValues(alpha: 0.15),
        highlightColor: Colors.white.withValues(alpha: 0.05),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }

  Color _bgColor() {
    switch (type) {
      case ButtonType.number:
        return AppTheme.btnNumber;
      case ButtonType.operator:
        return AppTheme.btnOperator;
      case ButtonType.clear:
        return AppTheme.btnClear;
      case ButtonType.function:
        return AppTheme.btnFunction;
      case ButtonType.equal:
        return AppTheme.primary; // fallback, never used
    }
  }

  Color _fgColor() {
    switch (type) {
      case ButtonType.operator:
        return AppTheme.primary;
      case ButtonType.clear:
        return AppTheme.error;
      default:
        return AppTheme.onSurface;
    }
  }
}

/// The = button with indigo→purple gradient
class _GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _GradientButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onPressed();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: const LinearGradient(
            colors: [AppTheme.primary, AppTheme.primaryDim],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
