import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/project.dart';
import '../models/labour.dart';
import '../models/attendance.dart';
import '../models/purchase.dart';
import '../models/transaction.dart';
import '../models/overhead.dart';
import '../services/database_helper.dart';

class ConstructionProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  List<Project> _projects = [];
  List<Labour> _labours = [];
  List<LabourAttendance> _attendances = [];
  List<Purchase> _purchases = [];
  List<TransactionModel> _transactions = [];
  List<OverheadExpense> _overheads = [];

  bool _isLoading = false;
  String? _selectedProjectId;
  DateTime _selectedDate = DateTime(2026, 10, 14); // Matches client mockup default

  // Getters
  bool get isLoading => _isLoading;
  List<Project> get projects => _projects;
  List<Labour> get labours => _labours;
  List<LabourAttendance> get attendances => _attendances;
  List<Purchase> get purchases => _purchases;
  List<TransactionModel> get transactions => _transactions;
  List<OverheadExpense> get overheads => _overheads;

  String? get selectedProjectId => _selectedProjectId;
  DateTime get selectedDate => _selectedDate;

  Project? get selectedProject {
    if (_selectedProjectId == null) return null;
    try {
      return _projects.firstWhere((p) => p.projectId == _selectedProjectId);
    } catch (_) {
      return null;
    }
  }

  ConstructionProvider() {
    loadAllData();
  }

  void setSelectedProject(String? projectId) {
    _selectedProjectId = projectId;
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  Future<void> loadAllData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _projects = await _dbHelper.getProjects();
      _labours = await _dbHelper.getLabours();
      _attendances = await _dbHelper.getAttendance();
      _purchases = await _dbHelper.getPurchases();
      _transactions = await _dbHelper.getTransactions();
      _overheads = await _dbHelper.getOverheads();

      if (_projects.isNotEmpty && _selectedProjectId == null) {
        _selectedProjectId = _projects.first.projectId;
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Financial Computations ---

  // Site-wise calculations
  double getProjectIncome(String projectId) {
    return _transactions
        .where((t) => t.projectId == projectId && t.type == 'INCOME')
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double getProjectExpense(String projectId) {
    return _transactions
        .where((t) => t.projectId == projectId && t.type == 'EXPENSE')
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double getProjectProfit(String projectId) {
    return getProjectIncome(projectId) - getProjectExpense(projectId);
  }

  double getProjectPurchasesTotal(String projectId) {
    return _purchases
        .where((p) => p.projectId == projectId)
        .fold(0.0, (sum, item) => sum + item.totalAmount);
  }

  double getProjectLabourWagesTotal(String projectId) {
    return _attendances
        .where((a) => a.projectId == projectId)
        .fold(0.0, (sum, item) => sum + item.dailyWage + item.overtimeAmount);
  }

  // Company-wide calculations (Formulas 4 & 5)
  double get totalIncome {
    return _transactions
        .where((t) => t.type == 'INCOME')
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get totalDirectExpenses {
    return _transactions
        .where((t) => t.type == 'EXPENSE')
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  // Gross Profit = Total Revenue (All Sites) - Total Direct Expenses (All Sites)
  double get grossProfit => totalIncome - totalDirectExpenses;

  // Indirect Overheads (Office Rent + Transport + Misc)
  double get totalOverheads {
    return _overheads.fold(0.0, (sum, item) => sum + item.amount);
  }

  // Net Profit = Gross Profit - Indirect Overheads
  double get netProfit => grossProfit - totalOverheads;

  int get totalProjectsCount => _projects.length;

  int get activeProjectsCount =>
      _projects.where((p) => p.status == 'In Progress').length;

  // --- Daily Wage Computation (Formula 1 & 2) ---
  static double computeDailyWage({
    required double baseWage,
    required String status,
    double overtimeAmount = 0.0,
  }) {
    double factor = 0.0;
    if (status == 'Present') {
      factor = 1.0;
    } else if (status == 'Half-Day') {
      factor = 0.5;
    } else {
      factor = 0.0;
    }
    return (baseWage * factor) + overtimeAmount;
  }

  // Monthly aggregated labour summary (Formula 2)
  Map<String, dynamic> getLabourMonthlyPayroll({
    required String labourId,
    required int year,
    required int month,
  }) {
    final labour = _labours.firstWhere(
      (l) => l.labourId == labourId,
      orElse: () => Labour(
        labourId: labourId,
        fullName: 'Unknown',
        phone: '',
        cnic: '',
        skillCategory: '',
        defaultDailyWage: 0.0,
      ),
    );

    int daysWorked = 0;
    int halfDays = 0;
    int absentDays = 0;
    double totalEarned = 0.0;

    for (var att in _attendances) {
      if (att.labourId == labourId) {
        final date = DateTime.tryParse(att.attendanceDate);
        if (date != null && date.year == year && date.month == month) {
          if (att.status == 'Present') {
            daysWorked++;
          } else if (att.status == 'Half-Day') {
            halfDays++;
          } else if (att.status == 'Absent') {
            absentDays++;
          }
          totalEarned += (att.dailyWage + att.overtimeAmount);
        }
      }
    }

    return {
      'labour': labour,
      'daysWorked': daysWorked,
      'halfDays': halfDays,
      'absentDays': absentDays,
      'totalDaysActive': daysWorked + (halfDays * 0.5),
      'rate': labour.defaultDailyWage,
      'totalPayable': totalEarned,
    };
  }

  // --- CRUD Actions ---

  // Project Actions
  Future<void> addProject({
    required String name,
    required String location,
    required String startDate,
    required String endDate,
    required double budget,
    String status = 'In Progress',
  }) async {
    final newProject = Project(
      projectId: _uuid.v4(),
      projectName: name,
      location: location,
      startDate: startDate,
      endDate: endDate,
      totalBudget: budget,
      status: status,
    );
    await _dbHelper.insertProject(newProject);
    await loadAllData();
  }

  Future<void> updateProject(Project project) async {
    await _dbHelper.updateProject(project);
    await loadAllData();
  }

  Future<void> deleteProject(String projectId) async {
    await _dbHelper.deleteProject(projectId);
    if (_selectedProjectId == projectId) {
      _selectedProjectId = _projects.isNotEmpty ? _projects.first.projectId : null;
    }
    await loadAllData();
  }

  // Labour Actions
  Future<void> addLabour({
    required String fullName,
    required String phone,
    required String cnic,
    required String skillCategory,
    required double defaultWage,
  }) async {
    final newLabour = Labour(
      labourId: _uuid.v4(),
      fullName: fullName,
      phone: phone,
      cnic: cnic,
      skillCategory: skillCategory,
      defaultDailyWage: defaultWage,
    );
    await _dbHelper.insertLabour(newLabour);
    await loadAllData();
  }

  Future<void> updateLabour(Labour labour) async {
    await _dbHelper.updateLabour(labour);
    await loadAllData();
  }

  Future<void> deleteLabour(String labourId) async {
    await _dbHelper.deleteLabour(labourId);
    await loadAllData();
  }

  // Attendance Actions
  Future<void> recordOrUpdateAttendance({
    required String labourId,
    required String projectId,
    required String date,
    required String inTime,
    required String outTime,
    required String status,
    required double baseWage,
    double overtimeHours = 0.0,
    double overtimeAmount = 0.0,
    String remarks = '',
  }) async {
    final calculatedWage = computeDailyWage(
      baseWage: baseWage,
      status: status,
      overtimeAmount: overtimeAmount,
    );

    // Check if attendance already exists for this labour on this date
    final existingIndex = _attendances.indexWhere(
      (a) => a.labourId == labourId && a.attendanceDate == date,
    );

    final attendanceId = existingIndex != -1
        ? _attendances[existingIndex].attendanceId
        : _uuid.v4();

    final att = LabourAttendance(
      attendanceId: attendanceId,
      labourId: labourId,
      projectId: projectId,
      attendanceDate: date,
      inTime: inTime,
      outTime: outTime,
      status: status,
      dailyWage: calculatedWage,
      overtimeHours: overtimeHours,
      overtimeAmount: overtimeAmount,
      remarks: remarks,
    );

    await _dbHelper.recordAttendance(att);
    await loadAllData();
  }

  // Purchases Actions
  Future<void> addPurchase({
    required String projectId,
    required String date,
    required String description,
    required String category,
    required double quantity,
    required String unit,
    required double rate,
  }) async {
    final totalAmount = quantity * rate;
    final purchase = Purchase(
      purchaseId: _uuid.v4(),
      projectId: projectId,
      purchaseDate: date,
      itemDescription: description,
      category: category,
      quantity: quantity,
      unit: unit,
      rate: rate,
      totalAmount: totalAmount,
    );

    await _dbHelper.insertPurchase(purchase);

    // Automatically create a corresponding direct site expense transaction
    final transaction = TransactionModel(
      transactionId: _uuid.v4(),
      projectId: projectId,
      date: date,
      type: 'EXPENSE',
      category: '$category Purchase',
      amount: totalAmount,
      description: '$description ($quantity $unit @ Rs $rate)',
      paymentMode: 'Bank Transfer',
    );
    await _dbHelper.insertTransaction(transaction);

    await loadAllData();
  }

  Future<void> deletePurchase(String purchaseId) async {
    await _dbHelper.deletePurchase(purchaseId);
    await loadAllData();
  }

  // Transactions Actions
  Future<void> addTransaction({
    required String projectId,
    required String date,
    required String type,
    required String category,
    required double amount,
    required String description,
    required String paymentMode,
  }) async {
    final transaction = TransactionModel(
      transactionId: _uuid.v4(),
      projectId: projectId,
      date: date,
      type: type,
      category: category,
      amount: amount,
      description: description,
      paymentMode: paymentMode,
    );

    await _dbHelper.insertTransaction(transaction);
    await loadAllData();
  }

  Future<void> deleteTransaction(String transactionId) async {
    await _dbHelper.deleteTransaction(transactionId);
    await loadAllData();
  }

  // Overhead Expenses Actions
  Future<void> addOverhead({
    required String date,
    required String category,
    required double amount,
    required String remarks,
  }) async {
    final overhead = OverheadExpense(
      overheadId: _uuid.v4(),
      date: date,
      category: category,
      amount: amount,
      remarks: remarks,
    );

    await _dbHelper.insertOverhead(overhead);
    await loadAllData();
  }

  Future<void> deleteOverhead(String overheadId) async {
    await _dbHelper.deleteOverhead(overheadId);
    await loadAllData();
  }
}
