class Labour {
  final String labourId;
  final String fullName;
  final String phone;
  final String cnic;
  final String skillCategory; // Mason, Helper, Carpenter, Electrician, Plumber, Painter
  final double defaultDailyWage;

  Labour({
    required this.labourId,
    required this.fullName,
    required this.phone,
    required this.cnic,
    required this.skillCategory,
    required this.defaultDailyWage,
  });

  Map<String, dynamic> toMap() {
    return {
      'labour_id': labourId,
      'full_name': fullName,
      'phone': phone,
      'cnic': cnic,
      'skill_category': skillCategory,
      'default_daily_wage': defaultDailyWage,
    };
  }

  factory Labour.fromMap(Map<String, dynamic> map) {
    return Labour(
      labourId: map['labour_id'] ?? '',
      fullName: map['full_name'] ?? '',
      phone: map['phone'] ?? '',
      cnic: map['cnic'] ?? '',
      skillCategory: map['skill_category'] ?? 'Helper',
      defaultDailyWage: (map['default_daily_wage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Labour copyWith({
    String? labourId,
    String? fullName,
    String? phone,
    String? cnic,
    String? skillCategory,
    double? defaultDailyWage,
  }) {
    return Labour(
      labourId: labourId ?? this.labourId,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      cnic: cnic ?? this.cnic,
      skillCategory: skillCategory ?? this.skillCategory,
      defaultDailyWage: defaultDailyWage ?? this.defaultDailyWage,
    );
  }
}
