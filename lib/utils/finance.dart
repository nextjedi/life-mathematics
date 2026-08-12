/// Pure financial maths. No Flutter, no formatting — everything here is
/// directly unit-testable and shared by the calculator screens.
library;

import 'dart:math';

/// Guards runaway amortisation loops (100 years of monthly payments).
const int _maxMonths = 1200;

/// Thrown when inputs describe a loan that never gets repaid.
class LoanNeverAmortisesError implements Exception {
  final String message;
  const LoanNeverAmortisesError(this.message);
  @override
  String toString() => message;
}

// ── EMI ──────────────────────────────────────────────────────────────────────

class EmiResult {
  /// Equated monthly instalment.
  final double emi;
  final double principal;
  final double totalPayment;
  final double totalInterest;
  final int months;

  const EmiResult({
    required this.emi,
    required this.principal,
    required this.totalPayment,
    required this.totalInterest,
    required this.months,
  });

  /// Share of every rupee repaid that is interest, 0–1.
  double get interestShare =>
      totalPayment == 0 ? 0 : totalInterest / totalPayment;
}

/// EMI = P·i·(1+i)^n / ((1+i)^n − 1), with the zero-rate case handled.
EmiResult calculateEmi({
  required double principal,
  required double annualRatePercent,
  required int months,
}) {
  assert(principal > 0 && months > 0 && annualRatePercent >= 0);

  final i = annualRatePercent / 12 / 100;
  final double emi;
  if (i == 0) {
    emi = principal / months;
  } else {
    final growth = pow(1 + i, months).toDouble();
    emi = principal * i * growth / (growth - 1);
  }

  final totalPayment = emi * months;
  return EmiResult(
    emi: emi,
    principal: principal,
    totalPayment: totalPayment,
    totalInterest: totalPayment - principal,
    months: months,
  );
}

// ── Loan payoff with extra payments ──────────────────────────────────────────

enum ExtraPaymentFrequency { monthly, yearly }

class LoanYearRow {
  final int year;
  final double principalPaid;
  final double interestPaid;
  final double extraPaid;
  final double closingBalance;

  const LoanYearRow({
    required this.year,
    required this.principalPaid,
    required this.interestPaid,
    required this.extraPaid,
    required this.closingBalance,
  });
}

class LoanPayoffResult {
  final double emi;
  final double principal;

  /// Months the loan would run with no extra payments.
  final int baselineMonths;
  final double baselineInterest;

  /// Months it actually takes once the extra payments are applied.
  final int payoffMonths;
  final double actualInterest;

  final double totalExtraPaid;
  final List<LoanYearRow> schedule;

  const LoanPayoffResult({
    required this.emi,
    required this.principal,
    required this.baselineMonths,
    required this.baselineInterest,
    required this.payoffMonths,
    required this.actualInterest,
    required this.totalExtraPaid,
    required this.schedule,
  });

  int get monthsSaved => baselineMonths - payoffMonths;
  double get interestSaved => baselineInterest - actualInterest;
  bool get hasExtra => totalExtraPaid > 0;
}

/// Amortises the loan month by month, applying [extraAmount] on top of the
/// EMI, and reports how much sooner it clears.
///
/// The EMI itself is always the one for the *original* tenure — paying extra
/// shortens the loan rather than reducing the instalment.
LoanPayoffResult calculateLoanPayoff({
  required double principal,
  required double annualRatePercent,
  required int months,
  double extraAmount = 0,
  ExtraPaymentFrequency frequency = ExtraPaymentFrequency.yearly,
}) {
  assert(principal > 0 && months > 0 && annualRatePercent >= 0);
  assert(extraAmount >= 0);

  final baseline = calculateEmi(
    principal: principal,
    annualRatePercent: annualRatePercent,
    months: months,
  );

  final i = annualRatePercent / 12 / 100;
  final emi = baseline.emi;

  // With no extra payment an EMI always clears the loan, but a user-supplied
  // rate change could in principle make the instalment too small.
  if (i > 0 && emi <= principal * i && extraAmount == 0) {
    throw const LoanNeverAmortisesError(
      'The instalment does not cover the monthly interest.',
    );
  }

  var balance = principal;
  var totalInterest = 0.0;
  var totalExtra = 0.0;
  var month = 0;

  var yearPrincipal = 0.0;
  var yearInterest = 0.0;
  var yearExtra = 0.0;
  final schedule = <LoanYearRow>[];

  while (balance > 0.005 && month < _maxMonths) {
    month++;

    final interest = balance * i;
    var principalPart = emi - interest;
    if (principalPart <= 0) {
      throw const LoanNeverAmortisesError(
        'The instalment does not cover the monthly interest.',
      );
    }
    if (principalPart > balance) principalPart = balance;

    balance -= principalPart;
    totalInterest += interest;
    yearInterest += interest;
    yearPrincipal += principalPart;

    // Extra payment lands after the instalment for that month.
    if (extraAmount > 0 && balance > 0) {
      final due = frequency == ExtraPaymentFrequency.monthly || month % 12 == 0;
      if (due) {
        final extra = min(extraAmount, balance);
        balance -= extra;
        totalExtra += extra;
        yearExtra += extra;
      }
    }

    if (month % 12 == 0 || balance <= 0.005) {
      schedule.add(LoanYearRow(
        year: (month / 12).ceil(),
        principalPaid: yearPrincipal,
        interestPaid: yearInterest,
        extraPaid: yearExtra,
        closingBalance: balance < 0.005 ? 0 : balance,
      ));
      yearPrincipal = 0;
      yearInterest = 0;
      yearExtra = 0;
    }
  }

  return LoanPayoffResult(
    emi: emi,
    principal: principal,
    baselineMonths: months,
    baselineInterest: baseline.totalInterest,
    payoffMonths: month,
    actualInterest: totalInterest,
    totalExtraPaid: totalExtra,
    schedule: schedule,
  );
}

// ── SIP ──────────────────────────────────────────────────────────────────────

class SipYearRow {
  final int year;
  final double invested;
  final double value;

  const SipYearRow({
    required this.year,
    required this.invested,
    required this.value,
  });

  double get gain => value - invested;
}

class SipResult {
  final double monthly;
  final double maturity;
  final double invested;
  final int months;
  final List<SipYearRow> schedule;

  const SipResult({
    required this.monthly,
    required this.maturity,
    required this.invested,
    required this.months,
    required this.schedule,
  });

  double get gain => maturity - invested;

  /// Gain as a fraction of the amount invested, 0–1+.
  double get gainRatio => invested == 0 ? 0 : gain / invested;
}

/// Future value of a monthly SIP, contributions made at the start of each
/// month (annuity-due): M = P · (((1+i)^n − 1) / i) · (1+i).
SipResult calculateSip({
  required double monthly,
  required double annualRatePercent,
  required double years,
}) {
  assert(monthly > 0 && years > 0 && annualRatePercent >= 0);

  final months = (years * 12).round();
  final i = annualRatePercent / 12 / 100;

  double futureValue(int n) {
    if (n <= 0) return 0;
    if (i == 0) return monthly * n;
    return monthly * ((pow(1 + i, n) - 1) / i) * (1 + i);
  }

  final schedule = <SipYearRow>[];
  final wholeYears = (months / 12).ceil();
  for (var y = 1; y <= wholeYears; y++) {
    final n = min(y * 12, months);
    schedule.add(SipYearRow(
      year: y,
      invested: monthly * n,
      value: futureValue(n),
    ));
  }

  return SipResult(
    monthly: monthly,
    maturity: futureValue(months),
    invested: monthly * months,
    months: months,
    schedule: schedule,
  );
}

// ── Realised return ──────────────────────────────────────────────────────────

class RoiResult {
  final double invested;
  final double currentValue;
  final double years;

  const RoiResult({
    required this.invested,
    required this.currentValue,
    required this.years,
  });

  double get profit => currentValue - invested;

  /// Total return over the whole holding period, as a fraction.
  double get absoluteReturn => invested == 0 ? 0 : profit / invested;

  /// Compound annual growth rate, as a fraction. Undefined for a holding
  /// that went to zero.
  double get cagr {
    if (invested <= 0 || currentValue <= 0 || years <= 0) return 0;
    return pow(currentValue / invested, 1 / years) - 1;
  }

  bool get isLoss => profit < 0;
}

RoiResult calculateRoi({
  required double invested,
  required double currentValue,
  required double years,
}) {
  assert(invested > 0 && years > 0);
  return RoiResult(
    invested: invested,
    currentValue: currentValue,
    years: years,
  );
}

/// "3 yr 4 mo" / "8 mo" / "5 yr" — used for tenures and time saved.
String formatMonths(int months) {
  if (months <= 0) return '0 mo';
  final years = months ~/ 12;
  final rest = months % 12;
  if (years == 0) return '$rest mo';
  if (rest == 0) return '$years yr';
  return '$years yr $rest mo';
}
