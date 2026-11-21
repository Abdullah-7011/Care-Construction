class OverheadExpense {
  final String overheadId;
  final String date; // YYYY-MM-DD
  final String category; // 'OFFICE', 'TRANSPORT', 'UTILITY', 'MISC'
  final double amount;
  final String remarks;

  OverheadExpense({
    required this.overheadId,
    required this.date,
    required this.category,
    required this.amount,
    required this.remarks,
  });

  Map<String, dynamic> toMap() {
    return {
      'overhead_id': overheadId,
      'date': date,
      'category': category,
      'amount': amount,
      'remarks': remarks,
    };
  }

  factory OverheadExpense.fromMap(Map<String, dynamic> map) {
    return OverheadExpense(
      overheadId: map['overhead_id'] ?? '',
      date: map['date'] ?? '',
      category: map['category'] ?? 'OFFICE',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      remarks: map['remarks'] ?? '',
    );
  }

  OverheadExpense copyWith({
    String? overheadId,
    String? date,
    String? category,
    double? amount,
    String? remarks,
  }) {
    return OverheadExpense(
      overheadId: overheadId ?? this.overheadId,
      date: date ?? this.date,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      remarks: remarks ?? this.remarks,
    );
  }
}
