class LabourAttendance {
  final String attendanceId;
  final String labourId;
  final String projectId;
  final String attendanceDate; // YYYY-MM-DD
  final String inTime;
  final String outTime;
  final String status; // 'Present', 'Half-Day', 'Absent'
  final double dailyWage;
  final double overtimeHours;
  final double overtimeAmount;
  final String remarks;

  LabourAttendance({
    required this.attendanceId,
    required this.labourId,
    required this.projectId,
    required this.attendanceDate,
    required this.inTime,
    required this.outTime,
    required this.status,
    required this.dailyWage,
    this.overtimeHours = 0.0,
    this.overtimeAmount = 0.0,
    this.remarks = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'attendance_id': attendanceId,
      'labour_id': labourId,
      'project_id': projectId,
      'attendance_date': attendanceDate,
      'in_time': inTime,
      'out_time': outTime,
      'status': status,
      'daily_wage': dailyWage,
      'overtime_hours': overtimeHours,
      'overtime_amount': overtimeAmount,
      'remarks': remarks,
    };
  }

  factory LabourAttendance.fromMap(Map<String, dynamic> map) {
    return LabourAttendance(
      attendanceId: map['attendance_id'] ?? '',
      labourId: map['labour_id'] ?? '',
      projectId: map['project_id'] ?? '',
      attendanceDate: map['attendance_date'] ?? '',
      inTime: map['in_time'] ?? '',
      outTime: map['out_time'] ?? '',
      status: map['status'] ?? 'Present',
      dailyWage: (map['daily_wage'] as num?)?.toDouble() ?? 0.0,
      overtimeHours: (map['overtime_hours'] as num?)?.toDouble() ?? 0.0,
      overtimeAmount: (map['overtime_amount'] as num?)?.toDouble() ?? 0.0,
      remarks: map['remarks'] ?? '',
    );
  }

  LabourAttendance copyWith({
    String? attendanceId,
    String? labourId,
    String? projectId,
    String? attendanceDate,
    String? inTime,
    String? outTime,
    String? status,
    double? dailyWage,
    double? overtimeHours,
    double? overtimeAmount,
    String? remarks,
  }) {
    return LabourAttendance(
      attendanceId: attendanceId ?? this.attendanceId,
      labourId: labourId ?? this.labourId,
      projectId: projectId ?? this.projectId,
      attendanceDate: attendanceDate ?? this.attendanceDate,
      inTime: inTime ?? this.inTime,
      outTime: outTime ?? this.outTime,
      status: status ?? this.status,
      dailyWage: dailyWage ?? this.dailyWage,
      overtimeHours: overtimeHours ?? this.overtimeHours,
      overtimeAmount: overtimeAmount ?? this.overtimeAmount,
      remarks: remarks ?? this.remarks,
    );
  }
}
