import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/layout.dart';
import '../app/theme.dart';

/// Shows a floating snack bar that clears the floating bottom nav instead of
/// sitting on top of it.
void showAppSnackBar(BuildContext context, String message) {
  final palette = context.palette;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.manrope(color: palette.onSurface),
        ),
        backgroundColor: palette.surfaceContainerHighest,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, kFloatingNavReserved + 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
}
