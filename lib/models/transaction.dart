class TransactionModel {
  final String transactionId;
  final String projectId;
  final String date; // YYYY-MM-DD
  final String type; // 'INCOME', 'EXPENSE'
  final String category; // 'Client Advance', 'Direct Site Expense', 'Equipment Rental', 'Fuel', etc.
  final double amount;
  final String description;
  final String paymentMode; // 'Cash', 'Bank Transfer', 'Cheque', 'Online'

  TransactionModel({
    required this.transactionId,
    required this.projectId,
    required this.date,
    required this.type,
    required this.category,
    required this.amount,
    required this.description,
    this.paymentMode = 'Bank Transfer',
  });

  Map<String, dynamic> toMap() {
    return {
      'transaction_id': transactionId,
      'project_id': projectId,
      'date': date,
      'type': type,
      'category': category,
      'amount': amount,
      'description': description,
      'payment_mode': paymentMode,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      transactionId: map['transaction_id'] ?? '',
      projectId: map['project_id'] ?? '',
      date: map['date'] ?? '',
      type: map['type'] ?? 'EXPENSE',
      category: map['category'] ?? 'General',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      description: map['description'] ?? '',
      paymentMode: map['payment_mode'] ?? 'Bank Transfer',
    );
  }

  TransactionModel copyWith({
    String? transactionId,
    String? projectId,
    String? date,
    String? type,
    String? category,
    double? amount,
    String? description,
    String? paymentMode,
  }) {
    return TransactionModel(
      transactionId: transactionId ?? this.transactionId,
      projectId: projectId ?? this.projectId,
      date: date ?? this.date,
      type: type ?? this.type,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      paymentMode: paymentMode ?? this.paymentMode,
    );
  }
}
