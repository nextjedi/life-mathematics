import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/theme.dart';

/// Shared chrome for the Smart Calc financial tools: hero header, input card,
/// gradient call-to-action, result card and breakdown table.
///
/// Each calculator supplies its own fields and results; everything visual
/// lives here so the screens stay about their own maths.

// ── Screen shell ─────────────────────────────────────────────────────────────

class FinanceScaffold extends StatelessWidget {
  final String title;
  final String heroSubtitle;
  final IconData icon;
  final List<Color> accent;
  final GlobalKey<FormState> formKey;
  final List<Widget> fields;
  final VoidCallback onCalculate;
  final String ctaLabel;

  /// Attached to the first result widget so [FinanceScaffold] can scroll it
  /// into view; null until a calculation has run.
  final Key? resultKey;
  final List<Widget> results;

  const FinanceScaffold({
    super.key,
    required this.title,
    required this.heroSubtitle,
    required this.icon,
    required this.accent,
    required this.formKey,
    required this.fields,
    required this.onCalculate,
    required this.results,
    this.resultKey,
    this.ctaLabel = 'Calculate',
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: palette.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          title,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: palette.onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              _Hero(
                title: title,
                subtitle: heroSubtitle,
                icon: icon,
                accent: accent,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: palette.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(children: fields),
              ),
              const SizedBox(height: 16),
              GradientButton(
                label: ctaLabel,
                colors: accent,
                onTap: onCalculate,
              ),
              if (results.isNotEmpty) ...[
                const SizedBox(height: 20),
                ...results,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> accent;

  const _Hero({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Center(
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: accent,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 34),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: palette.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              color: palette.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Inputs ───────────────────────────────────────────────────────────────────

class MoneyField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? prefix;
  final String? suffix;
  final bool allowDecimal;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  /// Extra validation on top of "must be a positive number".
  final String? Function(double value)? extraValidator;

  const MoneyField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.prefix,
    this.suffix,
    this.allowDecimal = false,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.extraValidator,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
      inputFormatters: [
        FilteringTextInputFormatter.allow(
            RegExp(allowDecimal ? r'[\d.]' : r'\d')),
      ],
      style: GoogleFonts.spaceGrotesk(color: palette.onSurface, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefix != null ? '$prefix  ' : null,
        suffixText: suffix,
        prefixStyle:
            GoogleFonts.manrope(color: palette.onSurfaceVariant, fontSize: 15),
        suffixStyle:
            GoogleFonts.manrope(color: palette.onSurfaceVariant, fontSize: 13),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Required';
        final value = double.tryParse(v.replaceAll(',', ''));
        if (value == null || value <= 0) return 'Enter a valid positive number';
        return extraValidator?.call(value);
      },
    );
  }
}

/// Optional numeric field — blank is allowed and means "none".
class OptionalMoneyField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? prefix;

  const OptionalMoneyField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'\d'))],
      style: GoogleFonts.spaceGrotesk(color: palette.onSurface, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefix != null ? '$prefix  ' : null,
        prefixStyle:
            GoogleFonts.manrope(color: palette.onSurfaceVariant, fontSize: 15),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return null;
        final value = double.tryParse(v.replaceAll(',', ''));
        if (value == null || value < 0) return 'Enter a valid amount';
        return null;
      },
    );
  }
}

/// Pill selector used for compounding frequency, payment frequency, modes.
class SegmentedSelector<T> extends StatelessWidget {
  final String? label;
  final List<({String label, T value})> options;
  final T selected;
  final ValueChanged<T> onChanged;

  const SegmentedSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: GoogleFonts.manrope(
                fontSize: 12, color: palette.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: palette.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            children: options.map((option) {
              final isActive = option.value == selected;
              return Expanded(
                child: Semantics(
                  button: true,
                  selected: isActive,
                  child: GestureDetector(
                    onTap: () => onChanged(option.value),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        gradient: isActive
                            ? LinearGradient(
                                colors: [palette.primary, palette.primaryDim],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            option.label,
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              fontWeight:
                                  isActive ? FontWeight.w700 : FontWeight.w400,
                              color: isActive
                                  ? Colors.white
                                  : palette.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class GradientButton extends StatelessWidget {
  final String label;
  final List<Color> colors;
  final VoidCallback onTap;

  const GradientButton({
    super.key,
    required this.label,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: colors.first.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '$label  →',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
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

// ── Results ──────────────────────────────────────────────────────────────────

/// The headline answer, with up to four supporting stats beneath it.
class HeadlineResult extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final List<({String label, String value, Color? color})> stats;
  final String? footnote;

  const HeadlineResult({
    super.key,
    required this.label,
    required this.value,
    this.stats = const [],
    this.valueColor,
    this.footnote,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = valueColor ?? palette.primary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF13121F)
            : palette.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.manrope(
                fontSize: 12, color: palette.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: accent,
                letterSpacing: -0.5,
              ),
            ),
          ),
          if (stats.isNotEmpty) ...[
            const SizedBox(height: 16),
            for (var row = 0; row < stats.length; row += 2) ...[
              if (row > 0) const SizedBox(height: 8),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    StatChip(
                      label: stats[row].label,
                      value: stats[row].value,
                      color: stats[row].color ?? palette.onSurfaceVariant,
                    ),
                    if (row + 1 < stats.length) ...[
                      const SizedBox(width: 8),
                      StatChip(
                        label: stats[row + 1].label,
                        value: stats[row + 1].value,
                        color: stats[row + 1].color ?? palette.onSurfaceVariant,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
          if (footnote != null) ...[
            const SizedBox(height: 12),
            Center(
              child: Text(
                footnote!,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                    fontSize: 12, color: palette.onSurfaceVariant),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const StatChip({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: palette.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: GoogleFonts.manrope(
                    fontSize: 10, color: palette.onSurfaceVariant)),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal bar showing how a total splits between two parts.
class SplitBar extends StatelessWidget {
  final String leftLabel;
  final String rightLabel;
  final double leftFraction;
  final Color leftColor;
  final Color rightColor;

  const SplitBar({
    super.key,
    required this.leftLabel,
    required this.rightLabel,
    required this.leftFraction,
    required this.leftColor,
    required this.rightColor,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final left = leftFraction.clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 12,
              child: Row(
                // The height is already bounded at 12, so stretch is safe here
                // and is what gives the bars a height at all — the Row's
                // default centre alignment would collapse them to nothing.
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: (left * 1000).round().clamp(1, 1000),
                    child: ColoredBox(color: leftColor),
                  ),
                  Expanded(
                    flex: ((1 - left) * 1000).round().clamp(1, 1000),
                    child: ColoredBox(color: rightColor),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Legend(color: leftColor, text: leftLabel),
              const Spacer(),
              _Legend(color: rightColor, text: rightLabel),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String text;

  const _Legend({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.manrope(
              fontSize: 11, color: palette.onSurfaceVariant),
        ),
      ],
    );
  }
}

/// Year-by-year table. [columns] are the header labels; [rows] must match.
class BreakdownTable extends StatelessWidget {
  final String title;
  final List<({String label, int flex})> columns;
  final List<List<String>> rows;

  /// Column index tinted with the accent colour, if any.
  final int? accentColumn;
  final Color? accentColor;
  final String? footnote;

  const BreakdownTable({
    super.key,
    required this.title,
    required this.columns,
    required this.rows,
    this.accentColumn,
    this.accentColor,
    this.footnote,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: palette.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (final column in columns)
                _cell(context, column.label,
                    flex: column.flex, isHeader: true),
            ],
          ),
          const SizedBox(height: 8),
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  for (var i = 0; i < row.length; i++)
                    _cell(
                      context,
                      row[i],
                      flex: columns[i].flex,
                      color: i == accentColumn ? accentColor : null,
                    ),
                ],
              ),
            ),
          if (footnote != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                footnote!,
                style: GoogleFonts.manrope(
                    fontSize: 11, color: palette.onSurfaceVariant),
              ),
            ),
        ],
      ),
    );
  }

  Widget _cell(BuildContext context, String text,
      {required int flex, bool isHeader = false, Color? color}) {
    final palette = context.palette;
    return Expanded(
      flex: flex,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: GoogleFonts.spaceGrotesk(
            fontSize: isHeader ? 12 : 13,
            fontWeight: isHeader ? FontWeight.w700 : FontWeight.w400,
            color: color ??
                (isHeader ? palette.onSurfaceVariant : palette.onSurface),
          ),
        ),
      ),
    );
  }
}
