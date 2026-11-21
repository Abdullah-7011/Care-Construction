import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/purchase.dart';
import '../providers/construction_provider.dart';
import '../theme/app_theme.dart';

class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  String _selectedCategory = 'All';
  String? _selectedProjectId;

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,##,###');

    return Consumer<ConstructionProvider>(
      builder: (context, provider, child) {
        final projects = provider.projects;
        var purchases = provider.purchases;

        if (_selectedProjectId != null && _selectedProjectId != 'ALL') {
          purchases = purchases.where((p) => p.projectId == _selectedProjectId).toList();
        }

        if (_selectedCategory != 'All') {
          purchases = purchases.where((p) => p.category == _selectedCategory).toList();
        }

        // Compute total purchases in current view
        double totalFilteredPurchases = purchases.fold(0.0, (sum, p) => sum + p.totalAmount);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Site Purchases (Materials)'),
          ),
          body: Column(
            children: [
              // Filter Card (Site & Category filter)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.domain, color: AppTheme.primaryNavy, size: 20),
                        const SizedBox(width: 8),
                        const Text('Site: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedProjectId ?? (projects.isNotEmpty ? projects.first.projectId : null),
                              isExpanded: true,
                              items: [
                                const DropdownMenuItem(value: 'ALL', child: Text('All Sites Combined')),
                                ...projects.map((p) => DropdownMenuItem(value: p.projectId, child: Text(p.projectName))),
                              ],
                              onChanged: (val) {
                                setState(() => _selectedProjectId = val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['All', 'Cement', 'Bricks', 'Steel', 'Sand', 'Electrical', 'Plumbing', 'Other']
                            .map((cat) {
                          final isSelected = _selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text(
                                cat,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isSelected ? Colors.white : AppTheme.textDark,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: AppTheme.primaryNavy,
                              backgroundColor: const Color(0xFFF1F5F9),
                              onSelected: (sel) {
                                if (sel) setState(() => _selectedCategory = cat);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // Total Material Procurement Summary Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F3E6D), Color(0xFF1E3A8A)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Purchases Expense',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                        Text(
                          '${purchases.length} Items Procured',
                          style: const TextStyle(color: Colors.white54, fontSize: 10),
                        ),
                      ],
                    ),
                    Text(
                      'Rs. ${currencyFormatter.format(totalFilteredPurchases)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Purchases List (Section 5 Table in Wireframe)
              Expanded(
                child: purchases.isEmpty
                    ? const Center(child: Text('No material purchases found.'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        itemCount: purchases.length,
                        itemBuilder: (context, index) {
                          final p = purchases[index];
                          final project = projects.firstWhere(
                            (proj) => proj.projectId == p.projectId,
                            orElse: () => projects.first,
                          );

                          return Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Category Icon Avatar
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: _getCategoryColor(p.category).withValues(alpha: 0.12),
                                    child: Icon(
                                      _getCategoryIcon(p.category),
                                      color: _getCategoryColor(p.category),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Item Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.itemDescription,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textDark,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${project.projectName} • ${p.purchaseDate}',
                                          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Qty: ${p.quantity} ${p.unit} × Rs. ${currencyFormatter.format(p.rate)}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.textDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Total Amount
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Rs. ${currencyFormatter.format(p.totalAmount)}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.expenseRed,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.textMuted),
                                        onPressed: () => _confirmDeletePurchase(context, provider, p),
                                      ),
                                    ],
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
            heroTag: 'fab_purchases',
            backgroundColor: AppTheme.primaryNavy,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Add Purchase'),
            onPressed: () => _showAddPurchaseDialog(context, provider),
          ),
        );
      },
    );
  }

  Color _getCategoryColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'cement':
        return Colors.blueGrey;
      case 'bricks':
        return Colors.deepOrange;
      case 'steel':
        return Colors.indigo;
      case 'sand':
        return Colors.amber.shade800;
      case 'electrical':
        return Colors.purple;
      case 'plumbing':
        return Colors.teal;
      default:
        return AppTheme.primaryNavy;
    }
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat.toLowerCase()) {
      case 'cement':
        return Icons.layers;
      case 'bricks':
        return Icons.crop_square_sharp;
      case 'steel':
        return Icons.shield_outlined;
      case 'sand':
        return Icons.grain;
      case 'electrical':
        return Icons.bolt;
      case 'plumbing':
        return Icons.water_drop_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  void _showAddPurchaseDialog(BuildContext context, ConstructionProvider provider) {
    final projects = provider.projects;
    if (projects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please register a project first.')),
      );
      return;
    }

    String selectedProject = provider.selectedProjectId ?? projects.first.projectId;
    String category = 'Cement';
    String unit = 'Bags';
    final descCtrl = TextEditingController(text: 'Cement Maple Leaf');
    final qtyCtrl = TextEditingController(text: '50');
    final rateCtrl = TextEditingController(text: '1400');
    final dateCtrl = TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
    double calculatedTotal = 70000;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          void updateCalculatedTotal() {
            final q = double.tryParse(qtyCtrl.text) ?? 0.0;
            final r = double.tryParse(rateCtrl.text) ?? 0.0;
            setDialogState(() {
              calculatedTotal = q * r;
            });
          }

          return AlertDialog(
            title: const Text('Record Material Purchase', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedProject,
                    decoration: const InputDecoration(labelText: 'Construction Site *'),
                    items: projects.map((p) => DropdownMenuItem(value: p.projectId, child: Text(p.projectName))).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedProject = val);
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: category,
                          decoration: const InputDecoration(labelText: 'Category'),
                          items: ['Cement', 'Bricks', 'Steel', 'Sand', 'Electrical', 'Plumbing', 'Paint', 'Other']
                              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                category = val;
                                if (category == 'Cement') {
                                  unit = 'Bags';
                                  descCtrl.text = 'Cement Maple Leaf';
                                } else if (category == 'Bricks') {
                                  unit = 'Pcs';
                                  descCtrl.text = 'Awal Red Bricks';
                                } else if (category == 'Steel') {
                                  unit = 'Kg';
                                  descCtrl.text = 'Steel Grade 60 Deformed';
                                } else if (category == 'Sand') {
                                  unit = 'Trolley';
                                  descCtrl.text = 'Ravi/Chenab Sand';
                                }
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: unit,
                          decoration: const InputDecoration(labelText: 'Unit'),
                          items: ['Bags', 'Pcs', 'Kg', 'Tons', 'Trolley', 'Feet', 'Lot', 'Liters']
                              .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setDialogState(() => unit = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(labelText: 'Item Description *'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: qtyCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Quantity *'),
                          onChanged: (_) => updateCalculatedTotal(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: rateCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Rate (PKR) *', prefixText: 'Rs. '),
                          onChanged: (_) => updateCalculatedTotal(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: dateCtrl,
                    decoration: const InputDecoration(labelText: 'Purchase Date (YYYY-MM-DD)'),
                  ),
                  const SizedBox(height: 14),
                  // Auto-computed Total banner (Formula 3: Quantity × Unit Rate)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Amount:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        Text(
                          'Rs. ${NumberFormat('#,##,###').format(calculatedTotal)}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.expenseRed),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  if (descCtrl.text.isEmpty || qtyCtrl.text.isEmpty || rateCtrl.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all required fields')),
                    );
                    return;
                  }
                  final q = double.tryParse(qtyCtrl.text) ?? 0.0;
                  final messenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(ctx);
                  final r = double.tryParse(rateCtrl.text) ?? 0.0;
                  await provider.addPurchase(
                    projectId: selectedProject,
                    date: dateCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    category: category,
                    quantity: q,
                    unit: unit,
                    rate: r,
                  );
                  navigator.pop();
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Material purchase recorded successfully!')),
                  );
                },
                child: const Text('Save Purchase'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDeletePurchase(BuildContext context, ConstructionProvider provider, Purchase p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Purchase?'),
        content: Text('Are you sure you want to delete purchase "${p.itemDescription}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.expenseRed),
            onPressed: () async {
              final navigator = Navigator.of(ctx);
              await provider.deletePurchase(p.purchaseId);
              navigator.pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
