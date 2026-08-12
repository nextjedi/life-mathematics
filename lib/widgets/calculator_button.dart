import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/theme.dart';

enum ButtonType { number, operator, equal, clear, function }

class CalculatorButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonType type;

  /// Spoken label, when the glyph alone would not read well.
  final String? semanticLabel;

  const CalculatorButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.number,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    if (type == ButtonType.equal) {
      return _GradientButton(
        text: text,
        onPressed: onPressed,
        semanticLabel: semanticLabel,
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      button: true,
      label: semanticLabel ?? text,
      excludeSemantics: true,
      child: Material(
        color: _bgColor(palette),
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onPressed();
          },
          borderRadius: BorderRadius.circular(999),
          splashColor: palette.primary.withValues(alpha: 0.15),
          highlightColor: (isDark ? Colors.white : Colors.black)
              .withValues(alpha: 0.05),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  text,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: _fgColor(palette),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _bgColor(AppPalette palette) {
    switch (type) {
      case ButtonType.number:
        return palette.btnNumber;
      case ButtonType.operator:
        return palette.btnOperator;
      case ButtonType.clear:
        return palette.btnClear;
      case ButtonType.function:
        return palette.btnFunction;
      case ButtonType.equal:
        return palette.primary; // fallback, never used
    }
  }

  Color _fgColor(AppPalette palette) {
    switch (type) {
      case ButtonType.operator:
        return palette.primary;
      case ButtonType.clear:
        return palette.error;
      default:
        return palette.onSurface;
    }
  }
}

/// The = button with indigo→purple gradient
class _GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final String? semanticLabel;

  const _GradientButton({
    required this.text,
    required this.onPressed,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      button: true,
      label: semanticLabel ?? text,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          onPressed();
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: LinearGradient(
              colors: [palette.primary, palette.primaryDim],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: palette.primary.withValues(alpha: 0.3),
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
      ),
    );
  }
}
