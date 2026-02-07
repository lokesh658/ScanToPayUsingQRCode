import 'package:flutter/material.dart';
import '../model/invoice.dart';

class PaymentVerificationPage extends StatefulWidget {
  final Invoice invoice;

  const PaymentVerificationPage({super.key, required this.invoice});

  @override
  State<PaymentVerificationPage> createState() =>
      _PaymentVerificationPageState();
}

class _PaymentVerificationPageState extends State<PaymentVerificationPage> {
  bool _isProcessing = false;

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });

    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 8),
            Text('Payment Successful'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amount Paid: ₹${widget.invoice.totalAmount.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 8),
            Text('Invoice: ${widget.invoice.invoiceNumber}'),
            const SizedBox(height: 8),
            Text('Date: ${_formatDate(widget.invoice.invoiceDate)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to scanner
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Payment'), elevation: 2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Invoice Header Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invoice Details',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      'Invoice Number',
                      widget.invoice.invoiceNumber,
                    ),
                    _buildDetailRow(
                      'Date',
                      _formatDate(widget.invoice.invoiceDate),
                    ),
                    if (widget.invoice.dueDate != null)
                      _buildDetailRow(
                        'Due Date',
                        _formatDate(widget.invoice.dueDate!),
                      ),
                    _buildDetailRow(
                      'Status',
                      widget.invoice.paymentStatus.toUpperCase(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Vendor & Customer Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vendor',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(widget.invoice.vendorName),
                    if (widget.invoice.vendorAddress != null)
                      Text(
                        widget.invoice.vendorAddress!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    if (widget.invoice.vendorContact != null)
                      Text(
                        widget.invoice.vendorContact!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    const Divider(height: 24),
                    Text(
                      'Customer',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(widget.invoice.customerName),
                    if (widget.invoice.customerAddress != null)
                      Text(
                        widget.invoice.customerAddress!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    if (widget.invoice.customerContact != null)
                      Text(
                        widget.invoice.customerContact!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Line Items Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Items',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 24),
                    ...widget.invoice.lineItems.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.description,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Text(
                                  '₹${item.total.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  '${item.quantity} ${item.unit ?? 'unit'}(s) × ₹${item.unitPrice.toStringAsFixed(2)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                if (item.taxRate > 0) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    '+ ${(item.taxRate * 100).toStringAsFixed(0)}% tax',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: Colors.orange),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Summary Card
            Card(
              elevation: 2,
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildSummaryRow('Subtotal', widget.invoice.subtotal),
                    const SizedBox(height: 8),
                    _buildSummaryRow('Tax', widget.invoice.totalTax),
                    if (widget.invoice.additionalDiscount > 0) ...[
                      const SizedBox(height: 8),
                      _buildSummaryRow(
                        'Discount',
                        -widget.invoice.additionalDiscount,
                        color: Colors.green,
                      ),
                    ],
                    const Divider(height: 24),
                    _buildSummaryRow(
                      'Total Amount',
                      widget.invoice.totalAmount,
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Notes (if any)
            if (widget.invoice.notes != null &&
                widget.invoice.notes!.isNotEmpty)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notes',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(widget.invoice.notes!),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _processPayment,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: _isProcessing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Confirm Payment - ₹${widget.invoice.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double amount, {
    bool isTotal = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}
