import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/labour.dart';
import '../providers/construction_provider.dart';
import '../services/pdf_service.dart';
import '../theme/app_theme.dart';

class LabourScreen extends StatefulWidget {
  const LabourScreen({super.key});

  @override
  State<LabourScreen> createState() => _LabourScreenState();
}

class _LabourScreenState extends State<LabourScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _currentDate = DateTime(2026, 10, 14); // Matches client mockup default
  final int _selectedMonth = 10;
  final int _selectedYear = 2026;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
            title: const Text('Labour & Wages'),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.accentGold,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: const [
                Tab(text: 'Daily Attendance', icon: Icon(Icons.how_to_reg, size: 20)),
                Tab(text: 'Monthly Payroll', icon: Icon(Icons.receipt_long, size: 20)),
                Tab(text: 'Workers Registry', icon: Icon(Icons.people_alt_outlined, size: 20)),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildDailyAttendanceTab(context, provider),
              _buildMonthlyPayrollTab(context, provider),
              _buildWorkersRegistryTab(context, provider),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'fab_labour',
            backgroundColor: AppTheme.primaryNavy,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.person_add),
            label: const Text('Add Worker'),
            onPressed: () => _showAddWorkerDialog(context, provider),
          ),
        );
      },
    );
  }

  // --- TAB 1: DAILY ATTENDANCE LOGGING ---
  Widget _buildDailyAttendanceTab(BuildContext context, ConstructionProvider provider) {
    final currencyFormat = NumberFormat('#,##,###');
    final formattedDate = DateFormat('yyyy-MM-dd').format(_currentDate);
    final projects = provider.projects;
    final labours = provider.labours;

    if (projects.isEmpty) {
      return const Center(child: Text('Please register a project first.'));
    }

    final selectedProjectId = provider.selectedProjectId ?? projects.first.projectId;

    // Get attendance for current date and project
    final dayAttendance = provider.attendances.where((a) =>
        a.attendanceDate == formattedDate && a.projectId == selectedProjectId).toList();

    double totalDailyWageLiabilities = 0.0;
    for (var a in dayAttendance) {
      totalDailyWageLiabilities += (a.dailyWage + a.overtimeAmount);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Bar: Site & Date Selector
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.domain, color: AppTheme.primaryNavy, size: 20),
                      const SizedBox(width: 8),
                      const Text('Site: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedProjectId,
                            isExpanded: true,
                            items: projects.map((p) {
                              return DropdownMenuItem(
                                value: p.projectId,
                                child: Text(p.projectName, style: const TextStyle(fontSize: 13)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) provider.setSelectedProject(val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_month, color: AppTheme.primaryNavy, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('dd MMM yyyy').format(_currentDate),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          side: const BorderSide(color: AppTheme.primaryNavy),
                        ),
                        icon: const Icon(Icons.edit_calendar, size: 16),
                        label: const Text('Change Date', style: TextStyle(fontSize: 11)),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _currentDate,
                            firstDate: DateTime(2025),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setState(() => _currentDate = picked);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Daily Wage Liability Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.primaryNavy.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.primaryNavy.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daily Site Wage Liabilities:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                ),
                Text(
                  'Rs. ${currencyFormat.format(totalDailyWageLiabilities)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppTheme.expenseRed,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Labour Attendance List
          ...labours.map((labour) {
            // Find if this worker already has logged attendance for today
            final attIndex = dayAttendance.indexWhere((a) => a.labourId == labour.labourId);
            final loggedAtt = attIndex != -1 ? dayAttendance[attIndex] : null;
            final currentStatus = loggedAtt?.status ?? 'Present';
            final inTime = loggedAtt?.inTime ?? '08:00 AM';
            final outTime = loggedAtt?.outTime ?? '05:00 PM';
            final wage = loggedAtt?.dailyWage ??
                ConstructionProvider.computeDailyWage(
                  baseWage: labour.defaultDailyWage,
                  status: currentStatus,
                );

            return Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: AppTheme.primaryNavy.withValues(alpha: 0.12),
                              child: Text(
                                labour.fullName.isNotEmpty ? labour.fullName[0] : 'W',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  labour.fullName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark),
                                ),
                                Text(
                                  '${labour.skillCategory} • Base Rate: Rs. ${currencyFormat.format(labour.defaultDailyWage)}',
                                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Daily Calculated Wage Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: currentStatus == 'Absent' ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Rs. ${currencyFormat.format(wage)}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: currentStatus == 'Absent' ? AppTheme.expenseRed : AppTheme.incomeGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.schedule, size: 13, color: AppTheme.textMuted),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  '$inTime - $outTime',
                                  style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Status toggle chips (Present, Half-Day, Absent)
                        _buildStatusToggle(
                          context,
                          provider,
                          labour: labour,
                          selectedProjectId: selectedProjectId,
                          date: formattedDate,
                          currentStatus: currentStatus,
                          inTime: inTime,
                          outTime: outTime,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatusToggle(
    BuildContext context,
    ConstructionProvider provider, {
    required Labour labour,
    required String selectedProjectId,
    required String date,
    required String currentStatus,
    required String inTime,
    required String outTime,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: ['Present', 'Half-Day', 'Absent'].map((status) {
        final isSelected = currentStatus == status;
        Color col;
        if (status == 'Present') {
          col = AppTheme.incomeGreen;
        } else if (status == 'Half-Day') {
          col = AppTheme.accentGold;
        } else {
          col = AppTheme.expenseRed;
        }

        return Padding(
          padding: const EdgeInsets.only(left: 4),
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () async {
              await provider.recordOrUpdateAttendance(
                labourId: labour.labourId,
                projectId: selectedProjectId,
                date: date,
                inTime: status == 'Absent' ? '--:--' : inTime,
                outTime: status == 'Absent' ? '--:--' : outTime,
                status: status,
                baseWage: labour.defaultDailyWage,
                remarks: status == 'Half-Day' ? 'Half Day' : '',
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: isSelected ? col : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: isSelected ? col : const Color(0xFFCBD5E1)),
              ),
              child: Text(
                status == 'Half-Day' ? 'Half' : status,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : AppTheme.textDark,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // --- TAB 2: MONTHLY AGGREGATED PAYROLL SHEET ---
  Widget _buildMonthlyPayrollTab(BuildContext context, ConstructionProvider provider) {
    final currencyFormat = NumberFormat('#,##,###');
    final labours = provider.labours;

    final payrollRows = labours.map((l) {
      return provider.getLabourMonthlyPayroll(
        labourId: l.labourId,
        year: _selectedYear,
        month: _selectedMonth,
      );
    }).toList();

    double grandTotalPayable = 0.0;
    for (var r in payrollRows) {
      grandTotalPayable += (r['totalPayable'] as double);
    }

    final monthTitle = DateFormat('MMMM yyyy').format(DateTime(_selectedYear, _selectedMonth));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month Selector & Export Action
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Payroll Period', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                      Text(monthTitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                    ],
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryNavy,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    icon: const Icon(Icons.picture_as_pdf, size: 16),
                    label: const Text('Export PDF', style: TextStyle(fontSize: 12)),
                    onPressed: () {
                      PdfService.exportMonthlyLabourPayrollPdf(
                        monthYearTitle: monthTitle,
                        payrollRows: payrollRows,
                        grandTotalPayable: grandTotalPayable,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Total Disbursement Summary Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF0D324D)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Monthly Payable', style: TextStyle(color: Colors.white70, fontSize: 11)),
                    Text('Formula: Days Worked × Rate', style: TextStyle(color: Colors.white54, fontSize: 9)),
                  ],
                ),
                Text(
                  'Rs. ${currencyFormat.format(grandTotalPayable)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Individual Payment Sheet Cards (Section 4 in wireframe)
          ...payrollRows.map((row) {
            final labour = row['labour'] as Labour;
            final days = row['totalDaysActive'];
            final rate = row['rate'];
            final payable = row['totalPayable'];

            return Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppTheme.primaryNavy.withValues(alpha: 0.1),
                      child: Text(
                        labour.fullName.isNotEmpty ? labour.fullName[0] : 'W',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            labour.fullName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark),
                          ),
                          Text(
                            '${labour.skillCategory} • Rate: Rs. ${currencyFormat.format(rate)}/day',
                            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Present: ${row['daysWorked']} | Half: ${row['halfDays']} | Absent: ${row['absentDays']}',
                            style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('$days Days', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted)),
                        const SizedBox(height: 2),
                        Text(
                          'Rs. ${currencyFormat.format(payable)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryNavy,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // --- TAB 3: WORKERS REGISTRY ---
  Widget _buildWorkersRegistryTab(BuildContext context, ConstructionProvider provider) {
    final currencyFormat = NumberFormat('#,##,###');
    final labours = provider.labours;

    if (labours.isEmpty) {
      return const Center(child: Text('No workers registered yet.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: labours.length,
      itemBuilder: (context, index) {
        final labour = labours[index];
        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryNavy,
              foregroundColor: Colors.white,
              child: Text(labour.fullName.isNotEmpty ? labour.fullName[0] : 'W'),
            ),
            title: Text(labour.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text(
              '${labour.skillCategory} • ${labour.phone}\nCNIC: ${labour.cnic}',
              style: const TextStyle(fontSize: 11),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Daily Wage', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                Text(
                  'Rs. ${currencyFormat.format(labour.defaultDailyWage)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.incomeGreen),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddWorkerDialog(BuildContext context, ConstructionProvider provider) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final cnicCtrl = TextEditingController();
    final wageCtrl = TextEditingController();
    String skill = 'Mason';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Register New Worker', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name *')),
                const SizedBox(height: 10),
                TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone Number *')),
                const SizedBox(height: 10),
                TextField(controller: cnicCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'CNIC * (e.g. 36302-1234567-1)')),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: skill,
                  decoration: const InputDecoration(labelText: 'Skill Category'),
                  items: ['Mason', 'Laborer', 'Carpenter', 'Electrician', 'Plumber', 'Steel Fixer', 'Painter', 'Foreman']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => skill = val);
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: wageCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Default Daily Wage (PKR) *', prefixText: 'Rs. '),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isEmpty || phoneCtrl.text.isEmpty || wageCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all required fields')),
                  );
                  return;
                }
                final messenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(ctx);
                final wage = double.tryParse(wageCtrl.text.replaceAll(',', '')) ?? 0.0;
                await provider.addLabour(
                  fullName: nameCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  cnic: cnicCtrl.text.trim(),
                  skillCategory: skill,
                  defaultWage: wage,
                );
                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Worker registered successfully!')),
                );
              },
              child: const Text('Add Worker'),
            ),
          ],
        ),
      ),
    );
  }
}
