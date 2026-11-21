class Purchase {
  final String purchaseId;
  final String projectId;
  final String purchaseDate; // YYYY-MM-DD
  final String itemDescription;
  final String category; // 'Cement', 'Bricks', 'Steel', 'Sand', 'Electrical', 'Plumbing', 'Other'
  final double quantity;
  final String unit; // 'Bags', 'Pieces', 'Tons', 'Trolley', 'Feet', 'Kg', 'Liters'
  final double rate;
  final double totalAmount;

  Purchase({
    required this.purchaseId,
    required this.projectId,
    required this.purchaseDate,
    required this.itemDescription,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.rate,
    required this.totalAmount,
  });

  Map<String, dynamic> toMap() {
    return {
      'purchase_id': purchaseId,
      'project_id': projectId,
      'purchase_date': purchaseDate,
      'item_description': itemDescription,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'rate': rate,
      'total_amount': totalAmount,
    };
  }

  factory Purchase.fromMap(Map<String, dynamic> map) {
    return Purchase(
      purchaseId: map['purchase_id'] ?? '',
      projectId: map['project_id'] ?? '',
      purchaseDate: map['purchase_date'] ?? '',
      itemDescription: map['item_description'] ?? '',
      category: map['category'] ?? 'Other',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: map['unit'] ?? 'Units',
      rate: (map['rate'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (map['total_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Purchase copyWith({
    String? purchaseId,
    String? projectId,
    String? purchaseDate,
    String? itemDescription,
    String? category,
    double? quantity,
    String? unit,
    double? rate,
    double? totalAmount,
  }) {
    return Purchase(
      purchaseId: purchaseId ?? this.purchaseId,
      projectId: projectId ?? this.projectId,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      itemDescription: itemDescription ?? this.itemDescription,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      rate: rate ?? this.rate,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }
}
