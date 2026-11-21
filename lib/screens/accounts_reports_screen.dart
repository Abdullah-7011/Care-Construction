import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/construction_provider.dart';
import '../services/pdf_service.dart';
import '../theme/app_theme.dart';

class AccountsReportsScreen extends StatefulWidget {
  const AccountsReportsScreen({super.key});

  @override
  State<AccountsReportsScreen> createState() => _AccountsReportsScreenState();
}

class _AccountsReportsScreenState extends State<AccountsReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConstructionProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Accounts & Financials'),
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: AppTheme.accentGold,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              tabs: const [
                Tab(text: 'P&L Statement', icon: Icon(Icons.analytics_outlined, size: 18)),
                Tab(text: 'Consolidated Sites', icon: Icon(Icons.table_chart_outlined, size: 18)),
                Tab(text: 'Site Cashflow', icon: Icon(Icons.account_balance_wallet_outlined, size: 18)),
                Tab(text: 'Office Overheads', icon: Icon(Icons.business_center_outlined, size: 18)),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildProfitAndLossTab(context, provider),
              _buildConsolidatedStatementTab(context, provider),
              _buildSiteCashflowTab(context, provider),
              _buildOverheadsTab(context, provider),
            ],
          ),
        );
      },
    );
  }

  // --- SUB-TAB 1: PROFIT & LOSS STATEMENT (Section 8 in Wireframe) ---
  Widget _buildProfitAndLossTab(BuildContext context, ConstructionProvider provider) {
    final currencyFormatter = NumberFormat('#,##,###');

    final totalIncome = provider.totalIncome;
    final totalExpenses = provider.totalDirectExpenses;
    final grossProfit = provider.grossProfit;
    final totalOverheads = provider.totalOverheads;
    final netProfit = provider.netProfit;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // P&L Header Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Corporate P&L Statement',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                  ),
                  Text('Automated Gross & Net Profit Calculation', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryNavy,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                icon: const Icon(Icons.picture_as_pdf, size: 16),
                label: const Text('Export P&L', style: TextStyle(fontSize: 12)),
                onPressed: () {
                  PdfService.exportProfitAndLossPdf(
                    totalRevenue: totalIncome,
                    directSiteCosts: totalExpenses,
                    grossProfit: grossProfit,
                    overheads: provider.overheads,
                    totalOverheads: totalOverheads,
                    netProfit: netProfit,
                    projects: provider.projects,
                    getProjectIncome: provider.getProjectIncome,
                    getProjectExpense: provider.getProjectExpense,
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 14),

          // P&L Card Breakdown (Matches Table 8 in Wireframe)
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildPlRow('Total Income (Revenue)', 'Rs. ${currencyFormatter.format(totalIncome)}', AppTheme.incomeGreen, isBold: true),
                  const Divider(height: 20),
                  _buildPlRow('Total Direct Site Expenses', 'Rs. ${currencyFormatter.format(totalExpenses)}', AppTheme.expenseRed, isBold: true),
                  const Divider(height: 20),
                  _buildPlRow(
                    'Gross Profit (Revenue - Direct Costs)',
                    'Rs. ${currencyFormatter.format(grossProfit)}',
                    AppTheme.profitBlue,
                    isBold: true,
                    highlight: true,
                  ),
                  const Divider(height: 20),
                  _buildPlRow(
                    'Less: Indirect Overheads (Rent, Fuel, Bills)',
                    'Rs. ${currencyFormatter.format(totalOverheads)}',
                    const Color(0xFFD97706),
                    isBold: false,
                  ),
                  const Divider(thickness: 2, height: 26),
                  _buildPlRow(
                    'NET PROFIT',
                    'Rs. ${currencyFormatter.format(netProfit)}',
                    netProfit >= 0 ? const Color(0xFF047857) : AppTheme.expenseRed,
                    isBold: true,
                    fontSize: 18,
                    highlight: true,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Direct Formulas Reference Box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Auditing Mathematical Logic:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                SizedBox(height: 4),
                Text('• Gross Profit = Total Revenue (All Sites) - Total Direct Expenses (All Sites)', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                Text('• Net Profit = Gross Profit - Indirect Head Office Overheads', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlRow(
    String label,
    String val,
    Color col, {
    bool isBold = false,
    double fontSize = 14,
    bool highlight = false,
  }) {
    return Container(
      padding: highlight ? const EdgeInsets.symmetric(horizontal: 10, vertical: 8) : EdgeInsets.zero,
      decoration: highlight
          ? BoxDecoration(
              color: col.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isBold ? fontSize - 1 : 13,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                color: AppTheme.textDark,
              ),
            ),
          ),
          Text(
            val,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: col,
            ),
          ),
        ],
      ),
    );
  }

  // --- SUB-TAB 2: CONSOLIDATED STATEMENT (Section 7 in Wireframe) ---
  Widget _buildConsolidatedStatementTab(BuildContext context, ConstructionProvider provider) {
    final currencyFormatter = NumberFormat('#,##,###');
    final projects = provider.projects;

    final grandTotalIncome = provider.totalIncome;
    final grandTotalExpense = provider.totalDirectExpenses;
    final grandTotalProfit = provider.grossProfit;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Multi-Project Consolidated Statement',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
          ),
          const Text(
            'Side-by-side comparative financial summary with grand totals',
            style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 12),

          // Project Rows (Section 7 Table)
          ...projects.asMap().entries.map((entry) {
            final idx = entry.key + 1;
            final p = entry.value;
            final inc = provider.getProjectIncome(p.projectId);
            final exp = provider.getProjectExpense(p.projectId);
            final prof = inc - exp;

            return Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: AppTheme.primaryNavy,
                          child: Text('$idx', style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            p.projectName,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                          ),
                        ),
                        Text(
                          'Rs. ${currencyFormatter.format(prof)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: prof >= 0 ? AppTheme.profitBlue : AppTheme.expenseRed,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildConsMini('Income', 'Rs. ${currencyFormatter.format(inc)}', AppTheme.incomeGreen),
                        _buildConsMini('Expenses', 'Rs. ${currencyFormatter.format(exp)}', AppTheme.expenseRed),
                        _buildConsMini('Budget', 'Rs. ${currencyFormatter.format(p.totalBudget)}', AppTheme.textMuted),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 12),

          // Grand Total Footer Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D324D), Color(0xFF1E3A8A)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('GRAND TOTALS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('All Active Projects', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
                const Divider(color: Colors.white24, height: 16),
                Row(
                  children: [
                    Expanded(child: _buildGrandTotalCol('Total Income', 'Rs. ${currencyFormatter.format(grandTotalIncome)}', const Color(0xFF6EE7B7))),
                    Expanded(child: _buildGrandTotalCol('Total Expenses', 'Rs. ${currencyFormatter.format(grandTotalExpense)}', const Color(0xFFFCA5A5))),
                    Expanded(child: _buildGrandTotalCol('Net Position', 'Rs. ${currencyFormatter.format(grandTotalProfit)}', Colors.white)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsMini(String lbl, String val, Color col) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(lbl, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
        Text(val, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: col)),
      ],
    );
  }

  Widget _buildGrandTotalCol(String lbl, String val, Color col) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(lbl, style: const TextStyle(fontSize: 10, color: Colors.white70)),
        const SizedBox(height: 2),
        Text(val, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: col)),
      ],
    );
  }

  // --- SUB-TAB 3: SITE CASHFLOW LEDGER (Section 6 in Wireframe) ---
  Widget _buildSiteCashflowTab(BuildContext context, ConstructionProvider provider) {
    final currencyFormatter = NumberFormat('#,##,###');
    final transactions = provider.transactions;
    final projects = provider.projects;

    return Scaffold(
      body: transactions.isEmpty
          ? const Center(child: Text('No transactions recorded yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
                final isIncome = tx.type == 'INCOME';
                final project = projects.firstWhere(
                  (p) => p.projectId == tx.projectId,
                  orElse: () => projects.first,
                );

                return Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: isIncome ? const Color(0xFFDCFCE7) : const Color(0xFFFEF2F2),
                      child: Icon(
                        isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                        size: 18,
                        color: isIncome ? AppTheme.incomeGreen : AppTheme.expenseRed,
                      ),
                    ),
                    title: Text(tx.category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text('${project.projectName} • ${tx.date}\n${tx.description} (${tx.paymentMode})',
                        style: const TextStyle(fontSize: 10)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${isIncome ? '+' : '-'} Rs. ${currencyFormatter.format(tx.amount)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isIncome ? AppTheme.incomeGreen : AppTheme.expenseRed,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 16, color: AppTheme.textMuted),
                          onPressed: () => provider.deleteTransaction(tx.transactionId),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_cashflow',
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Entry'),
        onPressed: () => _showAddTransactionDialog(context, provider),
      ),
    );
  }

  // --- SUB-TAB 4: OFFICE OVERHEADS MANAGER ---
  Widget _buildOverheadsTab(BuildContext context, ConstructionProvider provider) {
    final currencyFormatter = NumberFormat('#,##,###');
    final overheads = provider.overheads;
    final totalOh = provider.totalOverheads;

    return Scaffold(
      body: Column(
        children: [
          // Overheads Header Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Company Overheads', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF92400E))),
                    Text('Head Office Rent, Transport & Utility Bills', style: TextStyle(fontSize: 9, color: Color(0xFFB45309))),
                  ],
                ),
                Text(
                  'Rs. ${currencyFormatter.format(totalOh)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFB45309)),
                ),
              ],
            ),
          ),

          Expanded(
            child: overheads.isEmpty
                ? const Center(child: Text('No overhead expenses recorded yet.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: overheads.length,
                    itemBuilder: (context, index) {
                      final oh = overheads[index];
                      return Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundColor: const Color(0xFFFEF3C7),
                            child: const Icon(Icons.business_center, size: 16, color: Color(0xFFD97706)),
                          ),
                          title: Text(oh.category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          subtitle: Text('${oh.date} • ${oh.remarks}', style: const TextStyle(fontSize: 10)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Rs. ${currencyFormatter.format(oh.amount)}',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.expenseRed),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 16, color: AppTheme.textMuted),
                                onPressed: () => provider.deleteOverhead(oh.overheadId),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_overheads',
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Overhead'),
        onPressed: () => _showAddOverheadDialog(context, provider),
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context, ConstructionProvider provider) {
    final projects = provider.projects;
    if (projects.isEmpty) return;

    String selectedProj = provider.selectedProjectId ?? projects.first.projectId;
    String type = 'INCOME';
    String category = 'Client Advance';
    String payMode = 'Bank Transfer';
    final descCtrl = TextEditingController(text: 'Client Installment');
    final amountCtrl = TextEditingController();
    final dateCtrl = TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now()));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Cashflow Transaction', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedProj,
                  decoration: const InputDecoration(labelText: 'Site / Project *'),
                  items: projects.map((p) => DropdownMenuItem(value: p.projectId, child: Text(p.projectName))).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedProj = val);
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: type,
                        decoration: const InputDecoration(labelText: 'Type'),
                        items: ['INCOME', 'EXPENSE'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              type = val;
                              category = type == 'INCOME' ? 'Client Advance' : 'Direct Site Cost';
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: payMode,
                        decoration: const InputDecoration(labelText: 'Payment Mode'),
                        items: ['Bank Transfer', 'Cheque', 'Cash', 'Online'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                        onChanged: (val) {
                          if (val != null) setDialogState(() => payMode = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description / Purpose *')),
                const SizedBox(height: 10),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount (PKR) *', prefixText: 'Rs. '),
                ),
                const SizedBox(height: 10),
                TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final amt = double.tryParse(amountCtrl.text.replaceAll(',', '')) ?? 0.0;
                if (amt <= 0) return;
                final navigator = Navigator.of(ctx);
                await provider.addTransaction(
                  projectId: selectedProj,
                  date: dateCtrl.text.trim(),
                  type: type,
                  category: category,
                  amount: amt,
                  description: descCtrl.text.trim(),
                  paymentMode: payMode,
                );
                navigator.pop();
              },
              child: const Text('Save Transaction'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddOverheadDialog(BuildContext context, ConstructionProvider provider) {
    String category = 'OFFICE';
    final remarksCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final dateCtrl = TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now()));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Indirect Overhead', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: const InputDecoration(labelText: 'Category *'),
                  items: ['OFFICE', 'TRANSPORT', 'UTILITY', 'MISC'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => category = val);
                  },
                ),
                const SizedBox(height: 10),
                TextField(controller: remarksCtrl, decoration: const InputDecoration(labelText: 'Remarks / Expense Description *')),
                const SizedBox(height: 10),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount (PKR) *', prefixText: 'Rs. '),
                ),
                const SizedBox(height: 10),
                TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final amt = double.tryParse(amountCtrl.text.replaceAll(',', '')) ?? 0.0;
                if (amt <= 0 || remarksCtrl.text.isEmpty) return;
                final navigator = Navigator.of(ctx);
                await provider.addOverhead(
                  date: dateCtrl.text.trim(),
                  category: category,
                  amount: amt,
                  remarks: remarksCtrl.text.trim(),
                );
                navigator.pop();
              },
              child: const Text('Save Overhead'),
            ),
          ],
        ),
      ),
    );
  }
}
