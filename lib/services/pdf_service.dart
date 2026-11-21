import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/project.dart';
import '../models/purchase.dart';
import '../models/transaction.dart';
import '../models/overhead.dart';

class PdfService {
  static final currencyFormat = NumberFormat('#,##,###');

  // 1. Generate & Share/Print Monthly Labour Payment Sheet PDF
  static Future<void> exportMonthlyLabourPayrollPdf({
    required String monthYearTitle,
    required List<Map<String, dynamic>> payrollRows,
    required double grandTotalPayable,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'CARE Construction Pvt Ltd',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.Text(
                        'Building Today | For a Better Tomorrow',
                        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'MONTHLY LABOUR PAYROLL',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue800,
                        ),
                      ),
                      pw.Text('Period: $monthYearTitle', style: const pw.TextStyle(fontSize: 10)),
                      pw.Text(
                        'Generated: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
                        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                      ),
                    ],
                  ),
                ],
              ),
              pw.Divider(thickness: 1.5, color: PdfColors.blue900),
              pw.SizedBox(height: 12),

              // Table
              pw.TableHelper.fromTextArray(
                headers: [
                  'Sr',
                  'Worker Name',
                  'Skill / Role',
                  'Days Worked',
                  'Daily Rate (Rs)',
                  'Total Payable (Rs)',
                ],
                data: payrollRows.asMap().entries.map((entry) {
                  final index = entry.key + 1;
                  final row = entry.value;
                  final labour = row['labour'];
                  return [
                    '$index',
                    labour.fullName ?? '',
                    labour.skillCategory ?? '',
                    '${row['totalDaysActive']}',
                    currencyFormat.format(row['rate']),
                    currencyFormat.format(row['totalPayable']),
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                  fontSize: 10,
                ),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
                cellStyle: const pw.TextStyle(fontSize: 9),
                cellAlignment: pw.Alignment.centerLeft,
                cellAlignments: {
                  0: pw.Alignment.center,
                  3: pw.Alignment.center,
                  4: pw.Alignment.centerRight,
                  5: pw.Alignment.centerRight,
                },
                cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
              ),

              pw.SizedBox(height: 14),

              // Summary Box
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.blue900, width: 1),
                      borderRadius: pw.BorderRadius.circular(4),
                      color: PdfColors.grey100,
                    ),
                    child: pw.Row(
                      children: [
                        pw.Text(
                          'Total Labour Disbursement: ',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
                        ),
                        pw.Text(
                          'Rs. ${currencyFormat.format(grandTotalPayable)}',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 12,
                            color: PdfColors.blue900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.Spacer(),

              // Signatures
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    children: [
                      pw.Container(width: 140, height: 1, color: PdfColors.grey700),
                      pw.SizedBox(height: 4),
                      pw.Text('Site Supervisor (Munshi)', style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Container(width: 140, height: 1, color: PdfColors.grey700),
                      pw.SizedBox(height: 4),
                      pw.Text('Accountant Verified', style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Container(width: 140, height: 1, color: PdfColors.grey700),
                      pw.SizedBox(height: 4),
                      pw.Text('Owner / Contractor Approval', style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Labour_Payroll_$monthYearTitle.pdf',
    );
  }

  // 2. Generate Profit & Loss (P&L) Statement PDF
  static Future<void> exportProfitAndLossPdf({
    required double totalRevenue,
    required double directSiteCosts,
    required double grossProfit,
    required List<OverheadExpense> overheads,
    required double totalOverheads,
    required double netProfit,
    required List<Project> projects,
    required Function(String) getProjectIncome,
    required Function(String) getProjectExpense,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'CARE Construction Pvt Ltd',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.Text('Financial Accounts & Audit Division',
                          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'PROFIT & LOSS STATEMENT',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.Text(
                        'Statement Date: ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ],
                  ),
                ],
              ),
              pw.Divider(thickness: 1.5, color: PdfColors.blue900),
              pw.SizedBox(height: 12),

              // Executive P&L Summary Table
              pw.Text(
                '1. Corporate P&L Breakdown',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.blue900),
              ),
              pw.SizedBox(height: 6),
              pw.TableHelper.fromTextArray(
                headers: ['Particulars', 'Amount (PKR)'],
                data: [
                  ['Total Direct Site Revenue (Client Advances & Billings)', currencyFormat.format(totalRevenue)],
                  ['Total Direct Site Operational Expenses (Labor + Materials + Machinery)', currencyFormat.format(directSiteCosts)],
                  ['GROSS PROFIT (Revenue - Direct Site Costs)', currencyFormat.format(grossProfit)],
                  ['Less: Indirect Head Office Overheads & Administrative Costs', currencyFormat.format(totalOverheads)],
                  ['NET PROFIT (Gross Profit - Indirect Overheads)', currencyFormat.format(netProfit)],
                ],
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
                cellStyle: const pw.TextStyle(fontSize: 9),
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerRight,
                },
              ),

              pw.SizedBox(height: 16),

              // Multi-Project Breakdown Table
              pw.Text(
                '2. Multi-Project Site-Wise Contribution',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.blue900),
              ),
              pw.SizedBox(height: 6),
              pw.TableHelper.fromTextArray(
                headers: ['Site / Project Name', 'Location', 'Revenue (Rs)', 'Expenses (Rs)', 'Net Profit (Rs)'],
                data: projects.map((p) {
                  final inc = getProjectIncome(p.projectId);
                  final exp = getProjectExpense(p.projectId);
                  final prof = inc - exp;
                  return [
                    p.projectName,
                    p.location,
                    currencyFormat.format(inc),
                    currencyFormat.format(exp),
                    currencyFormat.format(prof),
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
                cellStyle: const pw.TextStyle(fontSize: 8.5),
                cellAlignments: {
                  2: pw.Alignment.centerRight,
                  3: pw.Alignment.centerRight,
                  4: pw.Alignment.centerRight,
                },
              ),

              pw.SizedBox(height: 16),

              // Indirect Overheads Breakdown
              pw.Text(
                '3. Indirect Head Office Overheads Ledger',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.blue900),
              ),
              pw.SizedBox(height: 6),
              pw.TableHelper.fromTextArray(
                headers: ['Date', 'Category', 'Description / Remarks', 'Amount (Rs)'],
                data: overheads.map((oh) {
                  return [
                    oh.date,
                    oh.category,
                    oh.remarks,
                    currencyFormat.format(oh.amount),
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey800),
                cellStyle: const pw.TextStyle(fontSize: 8.5),
                cellAlignments: {
                  3: pw.Alignment.centerRight,
                },
              ),

              pw.Spacer(),

              // Signature footer
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    children: [
                      pw.Container(width: 140, height: 1, color: PdfColors.grey700),
                      pw.SizedBox(height: 4),
                      pw.Text('Prepared By (Accountant)', style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Container(width: 140, height: 1, color: PdfColors.grey700),
                      pw.SizedBox(height: 4),
                      pw.Text('Super Admin / Contractor Approval', style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Profit_and_Loss_Statement_${DateFormat('yyyy_MM_dd').format(DateTime.now())}.pdf',
    );
  }

  // 3. Generate Site Financial Ledger PDF
  static Future<void> exportSiteLedgerPdf({
    required Project project,
    required List<TransactionModel> transactions,
    required List<Purchase> purchases,
    required double totalIncome,
    required double totalExpense,
    required double netBalance,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'CARE Construction Pvt Ltd',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.Text('Site Operational & Financial Ledger',
                          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        project.projectName,
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.Text('Location: ${project.location}', style: const pw.TextStyle(fontSize: 9)),
                      pw.Text('Budget: Rs. ${currencyFormat.format(project.totalBudget)}',
                          style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                ],
              ),
              pw.Divider(thickness: 1.5, color: PdfColors.blue900),
              pw.SizedBox(height: 10),

              // KPI Row
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _pdfKpiBox('Total Site Income', 'Rs. ${currencyFormat.format(totalIncome)}', PdfColors.green800),
                  _pdfKpiBox('Total Direct Costs', 'Rs. ${currencyFormat.format(totalExpense)}', PdfColors.red800),
                  _pdfKpiBox('Site Net Balance', 'Rs. ${currencyFormat.format(netBalance)}', PdfColors.blue900),
                ],
              ),
              pw.SizedBox(height: 14),

              // Site Transactions Table
              pw.Text('Direct Cashflow & Ledger Transactions',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.blue900)),
              pw.SizedBox(height: 6),
              pw.TableHelper.fromTextArray(
                headers: ['Date', 'Type', 'Category', 'Description', 'Amount (Rs)'],
                data: transactions.map((t) {
                  return [
                    t.date,
                    t.type,
                    t.category,
                    t.description,
                    currencyFormat.format(t.amount),
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
                cellStyle: const pw.TextStyle(fontSize: 8.5),
                cellAlignments: {
                  4: pw.Alignment.centerRight,
                },
              ),

              pw.Spacer(),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Munshi (Site Supervisor) Signature: _________________',
                      style: const pw.TextStyle(fontSize: 9)),
                  pw.Text('Accountant Signature: _________________',
                      style: const pw.TextStyle(fontSize: 9)),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: '${project.projectName.replaceAll(' ', '_')}_Ledger.pdf',
    );
  }

  static pw.Widget _pdfKpiBox(String title, String val, PdfColor col) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: col, width: 1),
        borderRadius: pw.BorderRadius.circular(4),
        color: PdfColors.grey100,
      ),
      child: pw.Column(
        children: [
          pw.Text(title, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
          pw.SizedBox(height: 2),
          pw.Text(val, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: col)),
        ],
      ),
    );
  }
}
