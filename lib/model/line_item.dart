class LineItem {
  final String id;
  final String description;
  final double quantity;
  final double unitPrice;
  final double taxRate; // e.g., 0.18 for 18%
  final String? unit; // e.g., 'kg', 'pcs', 'hrs'

  LineItem({
    required this.id,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    this.taxRate = 0.0,
    this.unit,
  });

  double get subtotal => quantity * unitPrice;
  double get taxAmount => subtotal * taxRate;
  double get total => subtotal + taxAmount;

  Map<String, dynamic> toJson() => {
    'id': id,
    'description': description,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'taxRate': taxRate,
    'unit': unit,
    'subtotal': subtotal,
    'taxAmount': taxAmount,
    'total': total,
  };

  factory LineItem.fromJson(Map<String, dynamic> json) => LineItem(
    id: json['id'] as String,
    description: json['description'] as String,
    quantity: (json['quantity'] as num).toDouble(),
    unitPrice: (json['unitPrice'] as num).toDouble(),
    taxRate: (json['taxRate'] as num?)?.toDouble() ?? 0.0,
    unit: json['unit'] as String?,
  );

  LineItem copyWith({
    String? id,
    String? description,
    double? quantity,
    double? unitPrice,
    double? taxRate,
    String? unit,
  }) => LineItem(
    id: id ?? this.id,
    description: description ?? this.description,
    quantity: quantity ?? this.quantity,
    unitPrice: unitPrice ?? this.unitPrice,
    taxRate: taxRate ?? this.taxRate,
    unit: unit ?? this.unit,
  );
}
