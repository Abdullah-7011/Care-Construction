import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/project.dart';
import '../providers/construction_provider.dart';
import '../services/pdf_service.dart';
import '../theme/app_theme.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,##,###');

    return Consumer<ConstructionProvider>(
      builder: (context, provider, child) {
        var projects = provider.projects;

        if (_selectedFilter != 'All') {
          projects = projects.where((p) => p.status == _selectedFilter).toList();
        }

        if (_searchQuery.isNotEmpty) {
          projects = projects.where((p) =>
              p.projectName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              p.location.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
        }

        return Scaffold(
          body: RefreshIndicator(
            onRefresh: () => provider.loadAllData(),
            child: Column(
              children: [
                // Search and Filter Bar
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Search site or location...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val),
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: ['All', 'In Progress', 'Planning', 'Completed'].map((filter) {
                            final isSelected = _selectedFilter == filter;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(
                                  filter,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected ? Colors.white : AppTheme.textDark,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor: AppTheme.primaryNavy,
                                backgroundColor: const Color(0xFFF1F5F9),
                                onSelected: (sel) {
                                  if (sel) setState(() => _selectedFilter = filter);
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                // Projects List
                Expanded(
                  child: projects.isEmpty
                      ? const Center(child: Text('No projects found'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          itemCount: projects.length,
                          itemBuilder: (context, index) {
                            final project = projects[index];
                            final income = provider.getProjectIncome(project.projectId);
                            final expense = provider.getProjectExpense(project.projectId);
                            final profit = income - expense;
                            final progress = project.totalBudget > 0
                                ? (expense / project.totalBudget).clamp(0.0, 1.0)
                                : 0.0;

                            return Card(
                              elevation: 1.5,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              margin: const EdgeInsets.only(bottom: 12),
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
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
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
                                          const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textMuted),
                                          const SizedBox(width: 4),
                                          Text(
                                            project.location,
                                            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                          ),
                                          const Spacer(),
                                          const Icon(Icons.calendar_today_outlined, size: 12, color: AppTheme.textMuted),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${project.startDate} ~ ${project.endDate}',
                                            style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 18),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(child: _buildDetailCol('Budget', 'Rs. ${currencyFormatter.format(project.totalBudget)}', AppTheme.textDark)),
                                          Expanded(child: _buildDetailCol('Income', 'Rs. ${currencyFormatter.format(income)}', AppTheme.incomeGreen)),
                                          Expanded(child: _buildDetailCol('Expenses', 'Rs. ${currencyFormatter.format(expense)}', AppTheme.expenseRed)),
                                          Expanded(child: _buildDetailCol('Profit', 'Rs. ${currencyFormatter.format(profit)}', AppTheme.profitBlue)),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: progress,
                                          backgroundColor: const Color(0xFFE2E8F0),
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            progress > 0.9 ? AppTheme.expenseRed : AppTheme.primaryNavy,
                                          ),
                                          minHeight: 6,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'fab_projects',
            backgroundColor: AppTheme.primaryNavy,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Add Site'),
            onPressed: () => _showAddProjectDialog(context, provider),
          ),
        );
      },
    );
  }

  Widget _buildDetailCol(String title, String val, Color col) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 9, color: AppTheme.textMuted)),
        Text(val, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: col)),
      ],
    );
  }

  void _showAddProjectDialog(BuildContext context, ConstructionProvider provider) {
    final nameCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    final budgetCtrl = TextEditingController();
    final startCtrl = TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
    final endCtrl = TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 120))));
    String status = 'In Progress';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Register New Project / Site', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Project / Site Name *'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: locationCtrl,
                  decoration: const InputDecoration(labelText: 'Location / City *'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: budgetCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Total Budget (PKR) *', prefixText: 'Rs. '),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: startCtrl,
                        decoration: const InputDecoration(labelText: 'Start Date (YYYY-MM-DD)'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: endCtrl,
                        decoration: const InputDecoration(labelText: 'End Date (YYYY-MM-DD)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: status,
                  decoration: const InputDecoration(labelText: 'Project Status'),
                  items: ['Planning', 'In Progress', 'Completed', 'On Hold']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => status = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isEmpty || locationCtrl.text.isEmpty || budgetCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all required fields')),
                  );
                  return;
                }
                final budget = double.tryParse(budgetCtrl.text.replaceAll(',', '')) ?? 0.0;
                final messenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(ctx);
                await provider.addProject(
                  name: nameCtrl.text.trim(),
                  location: locationCtrl.text.trim(),
                  startDate: startCtrl.text.trim(),
                  endDate: endCtrl.text.trim(),
                  budget: budget,
                  status: status,
                );
                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Site registered successfully!')),
                );
              },
              child: const Text('Create Site'),
            ),
          ],
        ),
      ),
    );
  }
}

// Detailed Project View with Site Financial Ledger
class ProjectDetailScreen extends StatelessWidget {
  final Project project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,##,###');

    return Consumer<ConstructionProvider>(
      builder: (context, provider, child) {
        final currentProject = provider.projects.firstWhere(
          (p) => p.projectId == project.projectId,
          orElse: () => project,
        );

        final totalIncome = provider.getProjectIncome(currentProject.projectId);
        final totalExpense = provider.getProjectExpense(currentProject.projectId);
        final profit = totalIncome - totalExpense;
        final sitePurchases = provider.purchases
            .where((p) => p.projectId == currentProject.projectId)
            .toList();
        final siteTransactions = provider.transactions
            .where((t) => t.projectId == currentProject.projectId)
            .toList();
        final progress = currentProject.totalBudget > 0
            ? (totalExpense / currentProject.totalBudget).clamp(0.0, 1.0)
            : 0.0;

        return Scaffold(
          appBar: AppBar(
            title: Text(currentProject.projectName),
            actions: [
              IconButton(
                icon: const Icon(Icons.picture_as_pdf_outlined),
                tooltip: 'Export Site Ledger PDF',
                onPressed: () {
                  PdfService.exportSiteLedgerPdf(
                    project: currentProject,
                    transactions: siteTransactions,
                    purchases: sitePurchases,
                    totalIncome: totalIncome,
                    totalExpense: totalExpense,
                    netBalance: profit,
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete Project',
                onPressed: () => _confirmDelete(context, provider, currentProject),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Header Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          currentProject.projectName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: currentProject.status == 'In Progress'
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            currentProject.status,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: currentProject.status == 'In Progress'
                                  ? const Color(0xFF166534)
                                  : const Color(0xFF92400E),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: AppTheme.textMuted),
                        const SizedBox(width: 4),
                        Text(currentProject.location, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                        const Spacer(),
                        Text('${currentProject.startDate} to ${currentProject.endDate}',
                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      children: [
                        Expanded(child: _buildDetailKpi('Budget', 'Rs. ${currencyFormatter.format(currentProject.totalBudget)}', AppTheme.textDark)),
                        Expanded(child: _buildDetailKpi('Income', 'Rs. ${currencyFormatter.format(totalIncome)}', AppTheme.incomeGreen)),
                        Expanded(child: _buildDetailKpi('Expenses', 'Rs. ${currencyFormatter.format(totalExpense)}', AppTheme.expenseRed)),
                        Expanded(child: _buildDetailKpi('Net Profit', 'Rs. ${currencyFormatter.format(profit)}', AppTheme.profitBlue)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress > 0.9 ? AppTheme.expenseRed : AppTheme.primaryNavy,
                      ),
                      minHeight: 8,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Expense vs Budget: ${(progress * 100).toStringAsFixed(1)}% utilized',
                      style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Export PDF Banner Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryNavy,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  minimumSize: const Size(double.infinity, 48),
                ),
                icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                label: const Text('Export Official Site Ledger (PDF)'),
                onPressed: () {
                  PdfService.exportSiteLedgerPdf(
                    project: currentProject,
                    transactions: siteTransactions,
                    purchases: sitePurchases,
                    totalIncome: totalIncome,
                    totalExpense: totalExpense,
                    netBalance: profit,
                  );
                },
              ),

              const SizedBox(height: 18),

              // Direct Site Transactions Ledger (Section 6)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Site Income & Expenses Ledger',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  Text(
                    '${siteTransactions.length} records',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (siteTransactions.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: Text('No transactions recorded for this site yet.')),
                  ),
                )
              else
                ...siteTransactions.map((tx) {
                  final isIncome = tx.type == 'INCOME';
                  return Card(
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor: isIncome ? const Color(0xFFDCFCE7) : const Color(0xFFFEF2F2),
                        child: Icon(
                          isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                          size: 16,
                          color: isIncome ? AppTheme.incomeGreen : AppTheme.expenseRed,
                        ),
                      ),
                      title: Text(tx.category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text('${tx.date} • ${tx.description}\nMode: ${tx.paymentMode}', style: const TextStyle(fontSize: 10)),
                      trailing: Text(
                        '${isIncome ? '+' : '-'} Rs. ${currencyFormatter.format(tx.amount)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: isIncome ? AppTheme.incomeGreen : AppTheme.expenseRed,
                        ),
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 16),

              // Site Purchases (Section 5)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Site Material Procurements',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  Text(
                    '${sitePurchases.length} items',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (sitePurchases.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: Text('No material purchases recorded for this site yet.')),
                  ),
                )
              else
                ...sitePurchases.map((pur) {
                  return Card(
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor: AppTheme.accentGold.withValues(alpha: 0.15),
                        child: const Icon(Icons.inventory_2_outlined, size: 16, color: AppTheme.accentGold),
                      ),
                      title: Text(pur.itemDescription, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text('${pur.purchaseDate} • ${pur.quantity} ${pur.unit} @ Rs. ${pur.rate}', style: const TextStyle(fontSize: 10)),
                      trailing: Text(
                        'Rs. ${currencyFormatter.format(pur.totalAmount)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.expenseRed),
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

  Widget _buildDetailKpi(String label, String val, Color col) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
        const SizedBox(height: 2),
        Text(val, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: col)),
      ],
    );
  }

  void _confirmDelete(BuildContext context, ConstructionProvider provider, Project project) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Project?'),
        content: Text('Are you sure you want to delete "${project.projectName}" and all its records?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.expenseRed),
            onPressed: () async {
              final rootNav = Navigator.of(context);
              final dialogNav = Navigator.of(ctx);
              await provider.deleteProject(project.projectId);
              dialogNav.pop();
              rootNav.pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
