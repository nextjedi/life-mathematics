import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ButtonType {
  number,
  operator,
  equal,
  clear,
  function,
}

class CalculatorButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonType type;
  final Color? customColor;

  const CalculatorButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.number,
    this.customColor,
  }) : super(key: key);

  Color _getButtonColor(BuildContext context) {
    if (customColor != null) return customColor!;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (type) {
      case ButtonType.number:
        return isDark
            ? const Color(0xFF4A4458)
            : const Color(0xFFE8DEF8);
      case ButtonType.operator:
        return isDark
            ? const Color(0xFFD0BCFF)
            : const Color(0xFF6750A4);
      case ButtonType.equal:
        return isDark
            ? const Color(0xFFD0BCFF)
            : const Color(0xFF6750A4);
      case ButtonType.clear:
        return isDark
            ? const Color(0xFFFF5252)
            : const Color(0xFFEF5350);
      case ButtonType.function:
        return isDark
            ? const Color(0xFF625B71)
            : const Color(0xFFCCC2DC);
    }
  }

  Color _getTextColor(BuildContext context) {
    if (type == ButtonType.operator || type == ButtonType.equal) {
      return Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1C1B1F)
          : Colors.white;
    }
    if (type == ButtonType.clear) {
      return Colors.white;
    }
    return Theme.of(context).colorScheme.onSurface;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _getButtonColor(context),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: type == ButtonType.equal ? 32 : 24,
                fontWeight: type == ButtonType.operator || type == ButtonType.equal
                    ? FontWeight.bold
                    : FontWeight.w500,
                color: _getTextColor(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
