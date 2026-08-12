import 'package:flutter_test/flutter_test.dart';
import 'package:life_mathematics/utils/finance.dart';
import 'package:life_mathematics/utils/money.dart';

void main() {
  group('EMI', () {
    test('matches the standard bank figure for ₹10L @ 9% over 5 years', () {
      final result = calculateEmi(
        principal: 1000000,
        annualRatePercent: 9,
        months: 60,
      );

      // P·i·(1+i)^n / ((1+i)^n − 1) with i = 0.0075, n = 60.
      expect(result.emi, closeTo(20758.36, 0.01));
      expect(result.totalPayment, closeTo(1245501.40, 0.5));
      expect(result.totalInterest, closeTo(245501.40, 0.5));
      expect(result.months, 60);
    });

    test('a 20-year home loan at 8.5%', () {
      final result = calculateEmi(
        principal: 5000000,
        annualRatePercent: 8.5,
        months: 240,
      );
      expect(result.emi, closeTo(43391.16, 0.5));
    });

    test('a zero-rate loan is just the principal split evenly', () {
      final result = calculateEmi(
        principal: 120000,
        annualRatePercent: 0,
        months: 12,
      );
      expect(result.emi, closeTo(10000, 0.001));
      expect(result.totalInterest, closeTo(0, 0.001));
    });

    test('interest share is the fraction of repayments that is interest', () {
      final result = calculateEmi(
        principal: 1000000,
        annualRatePercent: 9,
        months: 60,
      );
      expect(result.interestShare, closeTo(0.1971, 0.001));
    });
  });

  group('loan payoff', () {
    test('with no extra payment it runs the full tenure', () {
      final result = calculateLoanPayoff(
        principal: 1000000,
        annualRatePercent: 9,
        months: 60,
      );

      expect(result.payoffMonths, 60);
      expect(result.monthsSaved, 0);
      expect(result.interestSaved, closeTo(0, 1));
      expect(result.hasExtra, isFalse);
      // Amortising month by month must agree with the closed-form total.
      expect(result.actualInterest, closeTo(result.baselineInterest, 1));
    });

    test('an extra yearly payment clears the loan early', () {
      final result = calculateLoanPayoff(
        principal: 1000000,
        annualRatePercent: 9,
        months: 60,
        extraAmount: 50000,
        frequency: ExtraPaymentFrequency.yearly,
      );

      expect(result.payoffMonths, lessThan(60));
      expect(result.monthsSaved, greaterThan(0));
      expect(result.interestSaved, greaterThan(0));
      expect(result.totalExtraPaid, greaterThan(0));
    });

    test('paying extra every month clears it sooner than every year', () {
      LoanPayoffResult run(ExtraPaymentFrequency frequency, double amount) =>
          calculateLoanPayoff(
            principal: 1000000,
            annualRatePercent: 9,
            months: 60,
            extraAmount: amount,
            frequency: frequency,
          );

      // ₹5,000 a month is ₹60,000 a year, so it must beat ₹60,000 once a year.
      final monthly = run(ExtraPaymentFrequency.monthly, 5000);
      final yearly = run(ExtraPaymentFrequency.yearly, 60000);

      expect(monthly.payoffMonths, lessThanOrEqualTo(yearly.payoffMonths));
      expect(monthly.actualInterest, lessThan(yearly.actualInterest));
    });

    test('the balance actually reaches zero', () {
      final result = calculateLoanPayoff(
        principal: 2500000,
        annualRatePercent: 8.5,
        months: 240,
        extraAmount: 100000,
      );
      expect(result.schedule.last.closingBalance, closeTo(0, 0.01));
    });

    test('principal repaid plus extra equals the loan', () {
      final result = calculateLoanPayoff(
        principal: 1000000,
        annualRatePercent: 9,
        months: 60,
        extraAmount: 50000,
      );

      final repaid = result.schedule.fold<double>(
        0,
        (sum, row) => sum + row.principalPaid + row.extraPaid,
      );
      expect(repaid, closeTo(1000000, 1));
    });

    test('a big enough extra payment ends it in the first year', () {
      final result = calculateLoanPayoff(
        principal: 500000,
        annualRatePercent: 10,
        months: 120,
        extraAmount: 200000,
        frequency: ExtraPaymentFrequency.monthly,
      );
      expect(result.payoffMonths, lessThanOrEqualTo(12));
    });
  });

  group('SIP', () {
    test('₹10,000/mo at 12% for 10 years', () {
      final result = calculateSip(
        monthly: 10000,
        annualRatePercent: 12,
        years: 10,
      );

      // Annuity due: P·(((1+i)^n − 1)/i)·(1+i), i = 0.01, n = 120.
      expect(result.maturity, closeTo(2323391, 50));
      expect(result.invested, closeTo(1200000, 0.01));
      expect(result.gain, closeTo(1123391, 50));
      expect(result.months, 120);
    });

    test('a zero-return SIP returns exactly what went in', () {
      final result = calculateSip(
        monthly: 5000,
        annualRatePercent: 0,
        years: 3,
      );
      expect(result.maturity, closeTo(180000, 0.01));
      expect(result.gain, closeTo(0, 0.01));
    });

    test('the schedule ends at the maturity value', () {
      final result = calculateSip(
        monthly: 10000,
        annualRatePercent: 12,
        years: 10,
      );
      expect(result.schedule.length, 10);
      expect(result.schedule.last.value, closeTo(result.maturity, 0.01));
      expect(result.schedule.last.invested, closeTo(result.invested, 0.01));
    });

    test('value never falls below the amount invested at a positive rate', () {
      final result = calculateSip(
        monthly: 2000,
        annualRatePercent: 8,
        years: 5,
      );
      for (final row in result.schedule) {
        expect(row.value, greaterThanOrEqualTo(row.invested));
      }
    });
  });

  group('realised return', () {
    test('₹1L growing to ₹2.5L over 5 years is 20.11% CAGR', () {
      final result = calculateRoi(
        invested: 100000,
        currentValue: 250000,
        years: 5,
      );

      expect(result.cagr, closeTo(0.201126, 0.00001));
      expect(result.absoluteReturn, closeTo(1.5, 0.00001));
      expect(result.profit, closeTo(150000, 0.01));
      expect(result.isLoss, isFalse);
    });

    test('a doubling in one year is 100% CAGR', () {
      final result =
          calculateRoi(invested: 50000, currentValue: 100000, years: 1);
      expect(result.cagr, closeTo(1.0, 0.00001));
    });

    test('a loss reports negative return', () {
      final result =
          calculateRoi(invested: 100000, currentValue: 60000, years: 2);

      expect(result.isLoss, isTrue);
      expect(result.profit, closeTo(-40000, 0.01));
      expect(result.absoluteReturn, closeTo(-0.4, 0.00001));
      expect(result.cagr, lessThan(0));
    });

    test('no change is zero return', () {
      final result =
          calculateRoi(invested: 100000, currentValue: 100000, years: 7);
      expect(result.cagr, closeTo(0, 0.00001));
      expect(result.absoluteReturn, closeTo(0, 0.00001));
    });
  });

  group('formatMonths', () {
    test('renders years and months', () {
      expect(formatMonths(0), '0 mo');
      expect(formatMonths(8), '8 mo');
      expect(formatMonths(12), '1 yr');
      expect(formatMonths(40), '3 yr 4 mo');
      expect(formatMonths(60), '5 yr');
    });
  });

  group('money formatting', () {
    test('uses Indian digit grouping', () {
      expect(money(1200000), '12,00,000.00');
      expect(money(100000), '1,00,000.00');
      expect(money(999), '999.00');
      expect(moneyWhole(12345678), '1,23,45,678');
    });

    test('percentages', () {
      expect(percent(0.201126), '20.11%');
      expect(signedPercent(1.5), '+150.0%');
      expect(signedPercent(-0.4), '-40.0%');
    });

    test('whole-number durations drop the trailing .0', () {
      expect(years(5.0), '5');
      expect(years(2.5), '2.5');
      expect(years('10'), '10');
      expect(years('7.5'), '7.5');
    });
  });
}
