import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/construction_provider.dart';
import '../theme/app_theme.dart';
import 'projects_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,##,###');

    return Consumer<ConstructionProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final totalIncome = provider.totalIncome;
        final totalExpense = provider.totalDirectExpenses;
        final netProfit = provider.netProfit;

        return RefreshIndicator(
          onRefresh: () => provider.loadAllData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              children: [
                // Company Header Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryNavy, AppTheme.secondaryNavy],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryNavy.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.apartment_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: pwCross(CrossAxisAlignment.start),
                        children: [
                          const Text(
                            'CARE Construction Pvt Ltd.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Building Today | For a Better Tomorrow',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Super Admin',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 4 Executive KPI Cards (Header KPI Cards)
              Row(
                children: [
                  Expanded(
                    child: _buildKpiCard(
                      title: 'Total Projects',
                      value: '${provider.totalProjectsCount}',
                      subtitle: '${provider.activeProjectsCount} Active Sites',
                      icon: Icons.engineering_rounded,
                      color: const Color(0xFF3B82F6),
                      bgColor: const Color(0xFFEFF6FF),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildKpiCard(
                      title: 'Total Income',
                      value: 'Rs. ${currencyFormatter.format(totalIncome)}',
                      subtitle: 'Direct Advances',
                      icon: Icons.arrow_downward_rounded,
                      color: AppTheme.incomeGreen,
                      bgColor: const Color(0xFFECFDF5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildKpiCard(
                      title: 'Total Expenses',
                      value: 'Rs. ${currencyFormatter.format(totalExpense)}',
                      subtitle: 'Materials + Wages',
                      icon: Icons.arrow_upward_rounded,
                      color: AppTheme.expenseRed,
                      bgColor: const Color(0xFFFEF2F2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildKpiCard(
                      title: 'Net Profit',
                      value: 'Rs. ${currencyFormatter.format(netProfit)}',
                      subtitle: 'After Overheads',
                      icon: Icons.account_balance_wallet_rounded,
                      color: const Color(0xFF8B5CF6),
                      bgColor: const Color(0xFFF5F3FF),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Section: Income vs Expense Chart (Site Comparison)
              _buildSectionHeader(
                title: 'Income vs Expense (By Project)',
                subtitle: 'Comparative site performance in PKR',
                icon: Icons.bar_chart_rounded,
              ),
              const SizedBox(height: 8),
              _buildIncomeExpenseBarChart(provider),

              const SizedBox(height: 18),

              // Section: Progress Cashflow Trend
              _buildSectionHeader(
                title: 'Progress Cashflow Trend',
                subtitle: 'Daily & weekly operational movement',
                icon: Icons.show_chart_rounded,
              ),
              const SizedBox(height: 8),
              _buildCashflowLineChart(provider),

              const SizedBox(height: 18),

              // Section: Project / Site Wise Overview (Section 1 in wireframe)
              _buildSectionHeader(
                title: 'Project / Site Wise Overview',
                subtitle: 'Active site ledger balances & deadlines',
                icon: Icons.domain_rounded,
              ),
              const SizedBox(height: 8),
              ...provider.projects.map((project) {
                final inc = provider.getProjectIncome(project.projectId);
                final exp = provider.getProjectExpense(project.projectId);
                final profit = inc - exp;
                final progress = project.totalBudget > 0
                    ? (exp / project.totalBudget).clamp(0.0, 1.0)
                    : 0.0;

                return Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProjectDetailScreen(project: project),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  project.projectName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: project.status == 'In Progress'
                                      ? const Color(0xFFDCFCE7)
                                      : const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  project.status,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: project.status == 'In Progress'
                                        ? const Color(0xFF166534)
                                        : const Color(0xFF92400E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 12, color: AppTheme.textMuted),
                              const SizedBox(width: 4),
                              Text(
                                project.location,
                                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                              ),
                              const Spacer(),
                              Text(
                                '${project.startDate} to ${project.endDate}',
                                style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildMiniStat('Total Income', 'Rs. ${currencyFormatter.format(inc)}', AppTheme.incomeGreen),
                              _buildMiniStat('Total Expense', 'Rs. ${currencyFormatter.format(exp)}', AppTheme.expenseRed),
                              _buildMiniStat('Profit / Loss', 'Rs. ${currencyFormatter.format(profit)}', AppTheme.profitBlue),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: const Color(0xFFE2E8F0),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                progress > 0.9 ? AppTheme.expenseRed : AppTheme.primaryNavy,
                              ),
                              minHeight: 5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Budget Utilized: ${(progress * 100).toStringAsFixed(1)}% of Rs. ${currencyFormatter.format(project.totalBudget)}',
                              style: const TextStyle(fontSize: 9, color: AppTheme.textMuted),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      );
      },
    );
  }

  static CrossAxisAlignment pwCross(CrossAxisAlignment alignment) => alignment;

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMuted,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppTheme.primaryNavy.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppTheme.primaryNavy),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, color: AppTheme.textMuted)),
        Text(
          value,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildIncomeExpenseBarChart(ConstructionProvider provider) {
    final projects = provider.projects;
    if (projects.isEmpty) {
      return const SizedBox(
        height: 160,
        child: Center(child: Text('No project data available')),
      );
    }

    final barGroups = <BarChartGroupData>[];
    for (int i = 0; i < projects.length && i < 5; i++) {
      final p = projects[i];
      final income = provider.getProjectIncome(p.projectId) / 100000; // In Lakhs
      final expense = provider.getProjectExpense(p.projectId) / 100000;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: income,
              color: AppTheme.incomeGreen,
              width: 10,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            BarChartRodData(
              toY: expense,
              color: AppTheme.expenseRed,
              width: 10,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildLegendItem('Income', AppTheme.incomeGreen),
                const SizedBox(width: 14),
                _buildLegendItem('Expense', AppTheme.expenseRed),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 45, // Max ~45 Lakhs
                  barGroups: barGroups,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (val, meta) => Text(
                          '${val.toInt()}L',
                          style: const TextStyle(fontSize: 9, color: AppTheme.textMuted),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int idx = value.toInt();
                          if (idx >= 0 && idx < projects.length) {
                            String name = projects[idx].projectName;
                            if (name.contains('B-1 550')) return const Text('B-1 550', style: TextStyle(fontSize: 8));
                            if (name.contains('B-1 790')) return const Text('B-1 790', style: TextStyle(fontSize: 8));
                            if (name.contains('Gulberg')) return const Text('Gulberg', style: TextStyle(fontSize: 8));
                            if (name.contains('Plaza')) return const Text('Plaza', style: TextStyle(fontSize: 8));
                            if (name.contains('Farm')) return const Text('Farm', style: TextStyle(fontSize: 8));
                            return Text('P${idx + 1}', style: const TextStyle(fontSize: 8));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 10,
                    getDrawingHorizontalLine: (value) => const FlLine(
                      color: Color(0xFFF1F5F9),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashflowLineChart(ConstructionProvider provider) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daily Cashflow Trajectory (PKR in Lakhs)',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
                Text(
                  'Current Month',
                  style: TextStyle(fontSize: 10, color: AppTheme.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 160,
              child: LineChart(
                LineChartData(
                  minX: 1,
                  maxX: 15,
                  minY: 0,
                  maxY: 45,
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(1, 5),
                        FlSpot(3, 12),
                        FlSpot(5, 8),
                        FlSpot(8, 22),
                        FlSpot(10, 18),
                        FlSpot(12, 35),
                        FlSpot(14, 42),
                      ],
                      isCurved: true,
                      color: AppTheme.profitBlue,
                      barWidth: 3,
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppTheme.profitBlue.withValues(alpha: 0.12),
                      ),
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (val, meta) => Text(
                          '${val.toInt()}L',
                          style: const TextStyle(fontSize: 8, color: AppTheme.textMuted),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, meta) => Text(
                          'Day ${val.toInt()}',
                          style: const TextStyle(fontSize: 8, color: AppTheme.textMuted),
                        ),
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 10,
                    getDrawingHorizontalLine: (val) => const FlLine(
                      color: Color(0xFFF1F5F9),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
      ],
    );
  }
}
