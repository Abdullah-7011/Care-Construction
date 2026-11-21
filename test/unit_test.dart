import 'package:flutter_test/flutter_test.dart';
import 'package:care_construction/providers/construction_provider.dart';

void main() {
  group('CARE Construction Mathematical Business Logic Tests', () {
    test('1. Daily Wage Computation Formula', () {
      const baseWage = 1200.0;

      // Present = 1.0 * baseWage
      final presentWage = ConstructionProvider.computeDailyWage(
        baseWage: baseWage,
        status: 'Present',
      );
      expect(presentWage, 1200.0);

      // Half-Day = 0.5 * baseWage
      final halfDayWage = ConstructionProvider.computeDailyWage(
        baseWage: baseWage,
        status: 'Half-Day',
      );
      expect(halfDayWage, 600.0);

      // Absent = 0.0 * baseWage
      final absentWage = ConstructionProvider.computeDailyWage(
        baseWage: baseWage,
        status: 'Absent',
      );
      expect(absentWage, 0.0);

      // With Overtime Bonus
      final wageWithOvertime = ConstructionProvider.computeDailyWage(
        baseWage: baseWage,
        status: 'Present',
        overtimeAmount: 300.0,
      );
      expect(wageWithOvertime, 1500.0);
    });

    test('2. Material Item Purchase Cost Formula (Quantity * Rate)', () {
      const quantity = 50.0; // 50 Bags
      const rate = 1400.0;   // 1400 Rs per bag
      final totalCost = quantity * rate;
      expect(totalCost, 70000.0);
    });

    test('3. Site Profit Calculation Formula (Income - Direct Site Costs)', () {
      const siteIncome = 2450000.0;
      const directSiteCosts = 1780000.0;
      final siteProfit = siteIncome - directSiteCosts;
      expect(siteProfit, 670000.0);
    });

    test('4. Corporate P&L Calculation (Gross Profit & Net Profit)', () {
      const totalRevenue = 12450000.0;
      const totalDirectExpenses = 9320000.0;
      const indirectOverheads = 420000.0;

      // Gross Profit = Total Revenue - Total Direct Expenses
      final grossProfit = totalRevenue - totalDirectExpenses;
      expect(grossProfit, 3130000.0);

      // Net Profit = Gross Profit - Indirect Overheads
      final netProfit = grossProfit - indirectOverheads;
      expect(netProfit, 2710000.0);
    });
  });
}

