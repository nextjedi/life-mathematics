/// Shared layout metrics for the app shell.
library;

/// Height of the floating bottom nav pill.
const double kFloatingNavHeight = 64;

/// Gap between the nav pill and the bottom of the screen.
const double kFloatingNavInset = 16;

/// Vertical space screens must reserve so content never sits under the nav.
const double kFloatingNavReserved = kFloatingNavHeight + kFloatingNavInset;
