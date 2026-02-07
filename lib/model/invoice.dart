import 'line_item.dart';

class Invoice {
  final String invoiceNumber;
  final DateTime invoiceDate;
  final DateTime? dueDate;
  final String customerName;
  final String? customerAddress;
  final String? customerContact;
  final String vendorName;
  final String? vendorAddress;
  final String? vendorContact;
  final List<LineItem> lineItems;
  final String? notes;
  final String paymentStatus; // 'paid', 'pending', 'overdue'
  final double additionalDiscount; // flat discount on total

  Invoice({
    required this.invoiceNumber,
    required this.invoiceDate,
    this.dueDate,
    required this.customerName,
    this.customerAddress,
    this.customerContact,
    required this.vendorName,
    this.vendorAddress,
    this.vendorContact,
    required this.lineItems,
    this.notes,
    this.paymentStatus = 'pending',
    this.additionalDiscount = 0.0,
  });

  double get subtotal =>
      lineItems.fold(0.0, (sum, item) => sum + item.subtotal);

  double get totalTax =>
      lineItems.fold(0.0, (sum, item) => sum + item.taxAmount);

  double get totalAmount => subtotal + totalTax - additionalDiscount;

  Map<String, dynamic> toJson() => {
    'invoiceNumber': invoiceNumber,
    'invoiceDate': invoiceDate.toIso8601String(),
    'dueDate': dueDate?.toIso8601String(),
    'customerName': customerName,
    'customerAddress': customerAddress,
    'customerContact': customerContact,
    'vendorName': vendorName,
    'vendorAddress': vendorAddress,
    'vendorContact': vendorContact,
    'lineItems': lineItems.map((item) => item.toJson()).toList(),
    'notes': notes,
    'paymentStatus': paymentStatus,
    'additionalDiscount': additionalDiscount,
    'subtotal': subtotal,
    'totalTax': totalTax,
    'totalAmount': totalAmount,
  };

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
    invoiceNumber: json['invoiceNumber'] as String,
    invoiceDate: DateTime.parse(json['invoiceDate'] as String),
    dueDate: json['dueDate'] != null
        ? DateTime.parse(json['dueDate'] as String)
        : null,
    customerName: json['customerName'] as String,
    customerAddress: json['customerAddress'] as String?,
    customerContact: json['customerContact'] as String?,
    vendorName: json['vendorName'] as String,
    vendorAddress: json['vendorAddress'] as String?,
    vendorContact: json['vendorContact'] as String?,
    lineItems: (json['lineItems'] as List)
        .map((item) => LineItem.fromJson(item as Map<String, dynamic>))
        .toList(),
    notes: json['notes'] as String?,
    paymentStatus: json['paymentStatus'] as String? ?? 'pending',
    additionalDiscount: (json['additionalDiscount'] as num?)?.toDouble() ?? 0.0,
  );

  Invoice copyWith({
    String? invoiceNumber,
    DateTime? invoiceDate,
    DateTime? dueDate,
    String? customerName,
    String? customerAddress,
    String? customerContact,
    String? vendorName,
    String? vendorAddress,
    String? vendorContact,
    List<LineItem>? lineItems,
    String? notes,
    String? paymentStatus,
    double? additionalDiscount,
  }) => Invoice(
    invoiceNumber: invoiceNumber ?? this.invoiceNumber,
    invoiceDate: invoiceDate ?? this.invoiceDate,
    dueDate: dueDate ?? this.dueDate,
    customerName: customerName ?? this.customerName,
    customerAddress: customerAddress ?? this.customerAddress,
    customerContact: customerContact ?? this.customerContact,
    vendorName: vendorName ?? this.vendorName,
    vendorAddress: vendorAddress ?? this.vendorAddress,
    vendorContact: vendorContact ?? this.vendorContact,
    lineItems: lineItems ?? this.lineItems,
    notes: notes ?? this.notes,
    paymentStatus: paymentStatus ?? this.paymentStatus,
    additionalDiscount: additionalDiscount ?? this.additionalDiscount,
  );
}
