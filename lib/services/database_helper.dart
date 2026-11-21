import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/project.dart';
import '../models/labour.dart';
import '../models/attendance.dart';
import '../models/purchase.dart';
import '../models/transaction.dart';
import '../models/overhead.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('care_construction.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String dbPath;
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      final appDocDir = await getApplicationDocumentsDirectory();
      dbPath = join(appDocDir.path, filePath);
    } else {
      final defaultDatabasesPath = await getDatabasesPath();
      dbPath = join(defaultDatabasesPath, filePath);
    }

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Projects table
    await db.execute('''
      CREATE TABLE projects (
        project_id TEXT PRIMARY KEY,
        created_by TEXT,
        project_name TEXT NOT NULL,
        location TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        total_budget REAL NOT NULL,
        status TEXT NOT NULL
      )
    ''');

    // 2. Labours table
    await db.execute('''
      CREATE TABLE labours (
        labour_id TEXT PRIMARY KEY,
        full_name TEXT NOT NULL,
        phone TEXT NOT NULL,
        cnic TEXT NOT NULL,
        skill_category TEXT NOT NULL,
        default_daily_wage REAL NOT NULL
      )
    ''');

    // 3. Labour Attendance table
    await db.execute('''
      CREATE TABLE labour_attendance (
        attendance_id TEXT PRIMARY KEY,
        labour_id TEXT NOT NULL,
        project_id TEXT NOT NULL,
        attendance_date TEXT NOT NULL,
        in_time TEXT NOT NULL,
        out_time TEXT NOT NULL,
        status TEXT NOT NULL,
        daily_wage REAL NOT NULL,
        overtime_hours REAL DEFAULT 0.0,
        overtime_amount REAL DEFAULT 0.0,
        remarks TEXT,
        FOREIGN KEY (labour_id) REFERENCES labours (labour_id) ON DELETE CASCADE,
        FOREIGN KEY (project_id) REFERENCES projects (project_id) ON DELETE CASCADE
      )
    ''');

    // 4. Purchases table
    await db.execute('''
      CREATE TABLE purchases (
        purchase_id TEXT PRIMARY KEY,
        project_id TEXT NOT NULL,
        purchase_date TEXT NOT NULL,
        item_description TEXT NOT NULL,
        category TEXT NOT NULL,
        quantity REAL NOT NULL,
        unit TEXT NOT NULL,
        rate REAL NOT NULL,
        total_amount REAL NOT NULL,
        FOREIGN KEY (project_id) REFERENCES projects (project_id) ON DELETE CASCADE
      )
    ''');

    // 5. Transactions table (Direct Site Income & Expenses)
    await db.execute('''
      CREATE TABLE transactions (
        transaction_id TEXT PRIMARY KEY,
        project_id TEXT NOT NULL,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT NOT NULL,
        payment_mode TEXT NOT NULL,
        FOREIGN KEY (project_id) REFERENCES projects (project_id) ON DELETE CASCADE
      )
    ''');

    // 6. Overhead Expenses table (Indirect Company Overheads)
    await db.execute('''
      CREATE TABLE overhead_expenses (
        overhead_id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        remarks TEXT NOT NULL
      )
    ''');

    // Seed initial data from client wireframe & specification
    await _seedInitialData(db);
  }

  Future<void> _seedInitialData(Database db) async {
    // Seed Projects
    final projects = [
      Project(
        projectId: 'p1',
        projectName: 'DHA Villa B-1 550',
        location: 'DHA Multan',
        startDate: '2026-08-01',
        endDate: '2026-12-30',
        totalBudget: 2450000,
        status: 'In Progress',
      ),
      Project(
        projectId: 'p2',
        projectName: 'DHA Villa B-1 790',
        location: 'DHA Multan',
        startDate: '2026-07-15',
        endDate: '2026-12-31',
        totalBudget: 4200000,
        status: 'In Progress',
      ),
      Project(
        projectId: 'p3',
        projectName: 'Gulberg Residence',
        location: 'Multan',
        startDate: '2026-09-10',
        endDate: '2027-02-28',
        totalBudget: 3100000,
        status: 'In Progress',
      ),
      Project(
        projectId: 'p4',
        projectName: 'Commercial Plaza',
        location: 'Old Multan',
        startDate: '2026-10-01',
        endDate: '2027-04-30',
        totalBudget: 1800000,
        status: 'In Progress',
      ),
      Project(
        projectId: 'p5',
        projectName: 'Farm House Project',
        location: 'Multan',
        startDate: '2026-11-01',
        endDate: '2027-04-30',
        totalBudget: 900000,
        status: 'Planning',
      ),
    ];
    for (var p in projects) {
      await db.insert('projects', p.toMap());
    }

    // Seed Labours
    final labours = [
      Labour(
        labourId: 'l1',
        fullName: 'Muhammad Ali',
        phone: '0300-1234567',
        cnic: '36302-1122334-1',
        skillCategory: 'Mason',
        defaultDailyWage: 1200,
      ),
      Labour(
        labourId: 'l2',
        fullName: 'Rashid Khan',
        phone: '0301-2345678',
        cnic: '36302-2233445-2',
        skillCategory: 'Laborer',
        defaultDailyWage: 1000,
      ),
      Labour(
        labourId: 'l3',
        fullName: 'Imran',
        phone: '0302-3456789',
        cnic: '36302-3344556-3',
        skillCategory: 'Laborer',
        defaultDailyWage: 1000,
      ),
      Labour(
        labourId: 'l4',
        fullName: 'Sajjad',
        phone: '0303-4567890',
        cnic: '36302-4455667-4',
        skillCategory: 'Carpenter',
        defaultDailyWage: 1200,
      ),
      Labour(
        labourId: 'l5',
        fullName: 'Asif',
        phone: '0304-5678901',
        cnic: '36302-5566778-5',
        skillCategory: 'Laborer',
        defaultDailyWage: 1000,
      ),
    ];
    for (var l in labours) {
      await db.insert('labours', l.toMap());
    }

    // Seed Attendance for today
    final today = '2026-10-14';
    final attendances = [
      LabourAttendance(
        attendanceId: 'att1',
        labourId: 'l1',
        projectId: 'p1',
        attendanceDate: today,
        inTime: '08:00 AM',
        outTime: '05:00 PM',
        status: 'Present',
        dailyWage: 1200,
      ),
      LabourAttendance(
        attendanceId: 'att2',
        labourId: 'l2',
        projectId: 'p1',
        attendanceDate: today,
        inTime: '08:10 AM',
        outTime: '05:10 PM',
        status: 'Present',
        dailyWage: 1000,
      ),
      LabourAttendance(
        attendanceId: 'att3',
        labourId: 'l3',
        projectId: 'p1',
        attendanceDate: today,
        inTime: '08:00 AM',
        outTime: '05:00 PM',
        status: 'Present',
        dailyWage: 1000,
      ),
      LabourAttendance(
        attendanceId: 'att4',
        labourId: 'l4',
        projectId: 'p1',
        attendanceDate: today,
        inTime: '08:15 AM',
        outTime: '01:00 PM',
        status: 'Half-Day',
        dailyWage: 600,
        remarks: 'Half Day',
      ),
      LabourAttendance(
        attendanceId: 'att5',
        labourId: 'l5',
        projectId: 'p1',
        attendanceDate: today,
        inTime: '08:00 AM',
        outTime: '05:00 PM',
        status: 'Present',
        dailyWage: 1000,
      ),
    ];
    for (var att in attendances) {
      await db.insert('labour_attendance', att.toMap());
    }

    // Seed Purchases for p1 (DHA Villa B-1 550)
    final purchases = [
      Purchase(
        purchaseId: 'pur1',
        projectId: 'p1',
        purchaseDate: today,
        itemDescription: 'Cement Maple Leaf',
        category: 'Cement',
        quantity: 50,
        unit: 'Bags',
        rate: 1400,
        totalAmount: 70000,
      ),
      Purchase(
        purchaseId: 'pur2',
        projectId: 'p1',
        purchaseDate: today,
        itemDescription: 'Bricks (Awal Quality)',
        category: 'Bricks',
        quantity: 1000,
        unit: 'Pcs',
        rate: 18,
        totalAmount: 18000,
      ),
      Purchase(
        purchaseId: 'pur3',
        projectId: 'p1',
        purchaseDate: today,
        itemDescription: 'Steel Grade 60',
        category: 'Steel',
        quantity: 500,
        unit: 'Kg',
        rate: 217,
        totalAmount: 108500,
      ),
      Purchase(
        purchaseId: 'pur4',
        projectId: 'p1',
        purchaseDate: today,
        itemDescription: 'Sand Chenab',
        category: 'Sand',
        quantity: 4,
        unit: 'Trolley',
        rate: 6500,
        totalAmount: 26000,
      ),
      Purchase(
        purchaseId: 'pur5',
        projectId: 'p1',
        purchaseDate: today,
        itemDescription: 'Electrical Material Pipes & Boxes',
        category: 'Electrical',
        quantity: 1,
        unit: 'Lot',
        rate: 25000,
        totalAmount: 25000,
      ),
    ];
    for (var pur in purchases) {
      await db.insert('purchases', pur.toMap());
    }

    // Seed Transactions (Site Income & Expenses) to match Figure 1.1:
    // P1: Income: 2,450,000 | Expense: 1,780,000
    // P2: Income: 4,200,000 | Expense: 3,150,000
    // P3: Income: 3,100,000 | Expense: 2,340,000
    // P4: Income: 1,800,000 | Expense: 1,420,000
    // P5: Income: 900,000   | Expense: 730,000
    final transactions = [
      // P1
      TransactionModel(
        transactionId: 't1',
        projectId: 'p1',
        date: '2026-10-01',
        type: 'INCOME',
        category: 'Client Advance',
        amount: 500000,
        description: 'Client 1st Installment for Grey Structure',
        paymentMode: 'Bank Transfer',
      ),
      TransactionModel(
        transactionId: 't2',
        projectId: 'p1',
        date: '2026-10-05',
        type: 'EXPENSE',
        category: 'Cement Purchase',
        amount: 70000,
        description: 'Maple leaf cement delivery payment',
        paymentMode: 'Bank Transfer',
      ),
      TransactionModel(
        transactionId: 't3',
        projectId: 'p1',
        date: '2026-10-10',
        type: 'EXPENSE',
        category: 'Labour Payment',
        amount: 140000,
        description: 'Bi-weekly labour contractor settlement',
        paymentMode: 'Cash',
      ),
      TransactionModel(
        transactionId: 't4',
        projectId: 'p1',
        date: '2026-10-12',
        type: 'EXPENSE',
        category: 'Electrical Material Purchase',
        amount: 350000,
        description: 'Conduit pipes, wiring boxes and accessories',
        paymentMode: 'Bank Transfer',
      ),
      TransactionModel(
        transactionId: 't5',
        projectId: 'p1',
        date: '2026-10-14',
        type: 'INCOME',
        category: 'Client Advance',
        amount: 1950000,
        description: 'Client 2nd Installment & foundation completion',
        paymentMode: 'Cheque',
      ),
      TransactionModel(
        transactionId: 't6',
        projectId: 'p1',
        date: '2026-10-14',
        type: 'EXPENSE',
        category: 'Direct Site Operational Cost',
        amount: 1220000,
        description: 'Shuttering rental, excavator & steel supplier batch',
        paymentMode: 'Bank Transfer',
      ),

      // P2 (DHA Villa B-1 790: Income 4,200,000, Expense 3,150,000)
      TransactionModel(
        transactionId: 't7',
        projectId: 'p2',
        date: '2026-10-02',
        type: 'INCOME',
        category: 'Client Advance',
        amount: 4200000,
        description: 'Milestone 2 payment',
        paymentMode: 'Bank Transfer',
      ),
      TransactionModel(
        transactionId: 't8',
        projectId: 'p2',
        date: '2026-10-06',
        type: 'EXPENSE',
        category: 'Direct Site Expense',
        amount: 3150000,
        description: 'Concrete pouring, steel procurement, masonry wages',
        paymentMode: 'Bank Transfer',
      ),

      // P3 (Gulberg Residence: Income 3,100,000, Expense 2,340,000)
      TransactionModel(
        transactionId: 't9',
        projectId: 'p3',
        date: '2026-10-03',
        type: 'INCOME',
        category: 'Client Advance',
        amount: 3100000,
        description: 'Structure advance',
        paymentMode: 'Bank Transfer',
      ),
      TransactionModel(
        transactionId: 't10',
        projectId: 'p3',
        date: '2026-10-08',
        type: 'EXPENSE',
        category: 'Direct Site Expense',
        amount: 2340000,
        description: 'Grey structure materials and shuttering',
        paymentMode: 'Bank Transfer',
      ),

      // P4 (Commercial Plaza: Income 1,800,000, Expense 1,420,000)
      TransactionModel(
        transactionId: 't11',
        projectId: 'p4',
        date: '2026-10-04',
        type: 'INCOME',
        category: 'Client Advance',
        amount: 1800000,
        description: 'Commercial basement advance',
        paymentMode: 'Bank Transfer',
      ),
      TransactionModel(
        transactionId: 't12',
        projectId: 'p4',
        date: '2026-10-09',
        type: 'EXPENSE',
        category: 'Direct Site Expense',
        amount: 1420000,
        description: 'Excavation, retaining wall, RCC works',
        paymentMode: 'Bank Transfer',
      ),

      // P5 (Farm House Project: Income 900,000, Expense 730,000)
      TransactionModel(
        transactionId: 't13',
        projectId: 'p5',
        date: '2026-10-05',
        type: 'INCOME',
        category: 'Client Advance',
        amount: 900000,
        description: 'Boundary wall and gate advance',
        paymentMode: 'Bank Transfer',
      ),
      TransactionModel(
        transactionId: 't14',
        projectId: 'p5',
        date: '2026-10-11',
        type: 'EXPENSE',
        category: 'Direct Site Expense',
        amount: 730000,
        description: 'Boundary wall masonry, earth filling & tractor rental',
        paymentMode: 'Bank Transfer',
      ),
    ];
    for (var t in transactions) {
      await db.insert('transactions', t.toMap());
    }

    // Seed Overhead Expenses (Total = 420,000 to match wireframe exactly)
    final overheads = [
      OverheadExpense(
        overheadId: 'oh1',
        date: '2026-10-01',
        category: 'OFFICE',
        amount: 250000,
        remarks: 'Main Head Office Monthly Rent & Maintenance',
      ),
      OverheadExpense(
        overheadId: 'oh2',
        date: '2026-10-05',
        category: 'TRANSPORT',
        amount: 95000,
        remarks: 'Fleet Fuel, Site Inspection Visits & Trucking Logistics',
      ),
      OverheadExpense(
        overheadId: 'oh3',
        date: '2026-10-10',
        category: 'UTILITY',
        amount: 75000,
        remarks: 'Head Office Electricity, High-speed Internet & Water Bills',
      ),
    ];
    for (var oh in overheads) {
      await db.insert('overhead_expenses', oh.toMap());
    }
  }

  // --- CRUD Operations ---

  // Projects
  Future<List<Project>> getProjects() async {
    final db = await database;
    final res = await db.query('projects', orderBy: 'project_name ASC');
    return res.map((e) => Project.fromMap(e)).toList();
  }

  Future<int> insertProject(Project project) async {
    final db = await database;
    return await db.insert('projects', project.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateProject(Project project) async {
    final db = await database;
    return await db.update('projects', project.toMap(),
        where: 'project_id = ?', whereArgs: [project.projectId]);
  }

  Future<int> deleteProject(String projectId) async {
    final db = await database;
    return await db.delete('projects',
        where: 'project_id = ?', whereArgs: [projectId]);
  }

  // Labours
  Future<List<Labour>> getLabours() async {
    final db = await database;
    final res = await db.query('labours', orderBy: 'full_name ASC');
    return res.map((e) => Labour.fromMap(e)).toList();
  }

  Future<int> insertLabour(Labour labour) async {
    final db = await database;
    return await db.insert('labours', labour.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateLabour(Labour labour) async {
    final db = await database;
    return await db.update('labours', labour.toMap(),
        where: 'labour_id = ?', whereArgs: [labour.labourId]);
  }

  Future<int> deleteLabour(String labourId) async {
    final db = await database;
    return await db.delete('labours',
        where: 'labour_id = ?', whereArgs: [labourId]);
  }

  // Labour Attendance
  Future<List<LabourAttendance>> getAttendance({String? projectId, String? date}) async {
    final db = await database;
    String? whereClause;
    List<dynamic>? whereArgs;

    if (projectId != null && date != null) {
      whereClause = 'project_id = ? AND attendance_date = ?';
      whereArgs = [projectId, date];
    } else if (projectId != null) {
      whereClause = 'project_id = ?';
      whereArgs = [projectId];
    } else if (date != null) {
      whereClause = 'attendance_date = ?';
      whereArgs = [date];
    }

    final res = await db.query(
      'labour_attendance',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'attendance_date DESC',
    );
    return res.map((e) => LabourAttendance.fromMap(e)).toList();
  }

  Future<int> recordAttendance(LabourAttendance attendance) async {
    final db = await database;
    return await db.insert('labour_attendance', attendance.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> deleteAttendance(String attendanceId) async {
    final db = await database;
    return await db.delete('labour_attendance',
        where: 'attendance_id = ?', whereArgs: [attendanceId]);
  }

  // Purchases
  Future<List<Purchase>> getPurchases({String? projectId}) async {
    final db = await database;
    final res = await db.query(
      'purchases',
      where: projectId != null ? 'project_id = ?' : null,
      whereArgs: projectId != null ? [projectId] : null,
      orderBy: 'purchase_date DESC',
    );
    return res.map((e) => Purchase.fromMap(e)).toList();
  }

  Future<int> insertPurchase(Purchase purchase) async {
    final db = await database;
    return await db.insert('purchases', purchase.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> deletePurchase(String purchaseId) async {
    final db = await database;
    return await db.delete('purchases',
        where: 'purchase_id = ?', whereArgs: [purchaseId]);
  }

  // Transactions
  Future<List<TransactionModel>> getTransactions({String? projectId}) async {
    final db = await database;
    final res = await db.query(
      'transactions',
      where: projectId != null ? 'project_id = ?' : null,
      whereArgs: projectId != null ? [projectId] : null,
      orderBy: 'date DESC',
    );
    return res.map((e) => TransactionModel.fromMap(e)).toList();
  }

  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> deleteTransaction(String transactionId) async {
    final db = await database;
    return await db.delete('transactions',
        where: 'transaction_id = ?', whereArgs: [transactionId]);
  }

  // Overhead Expenses
  Future<List<OverheadExpense>> getOverheads() async {
    final db = await database;
    final res = await db.query('overhead_expenses', orderBy: 'date DESC');
    return res.map((e) => OverheadExpense.fromMap(e)).toList();
  }

  Future<int> insertOverhead(OverheadExpense overhead) async {
    final db = await database;
    return await db.insert('overhead_expenses', overhead.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> deleteOverhead(String overheadId) async {
    final db = await database;
    return await db.delete('overhead_expenses',
        where: 'overhead_id = ?', whereArgs: [overheadId]);
  }
}
