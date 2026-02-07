import 'package:flutter/material.dart';
import 'dart:convert';
import '../data/sample_inventory.dart';
import '../model/invoice.dart';
import '../model/line_item.dart';
import '../core/text_to_qr_code_process.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage>
    with SingleTickerProviderStateMixin {
  final Map<String, double> _selectedQuantities = {};
  final TextToQrCodeProcess _qrGenerator = TextToQrCodeProcess();
  String _selectedCategory = 'All';

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Electronics':
        return Icons.devices;
      case 'Office Supplies':
        return Icons.business_center;
      case 'Services':
        return Icons.construction;
      case 'Food':
        return Icons.restaurant;
      default:
        return Icons.shopping_bag;
    }
  }

  double _getQuantity(String itemId) {
    return _selectedQuantities[itemId] ?? 0;
  }

  void _incrementQuantity(String itemId) {
    setState(() {
      _selectedQuantities[itemId] = _getQuantity(itemId) + 1;
    });
  }

  void _decrementQuantity(String itemId) {
    setState(() {
      final current = _getQuantity(itemId);
      if (current > 0) {
        _selectedQuantities[itemId] = current - 1;
      }
    });
  }

  List<LineItem> _getSelectedLineItems() {
    final lineItems = <LineItem>[];
    _selectedQuantities.forEach((itemId, quantity) {
      if (quantity > 0) {
        final inventoryItem = SampleInventory.findById(itemId);
        if (inventoryItem != null) {
          lineItems.add(inventoryItem.toLineItem(quantity: quantity));
        }
      }
    });
    return lineItems;
  }

  double _getTotalAmount() {
    final lineItems = _getSelectedLineItems();
    return lineItems.fold(0.0, (sum, item) => sum + item.total);
  }

  int get _totalItemsCount {
    return _selectedQuantities.values.fold(0, (sum, qty) => sum + qty.toInt());
  }

  void _generateAndShowQR() {
    final lineItems = _getSelectedLineItems();
    if (lineItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select at least one item'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    final invoice = Invoice(
      invoiceNumber: 'INV-${DateTime.now().millisecondsSinceEpoch}',
      invoiceDate: DateTime.now(),
      customerName: 'Walk-in Customer',
      vendorName: 'My Store',
      lineItems: lineItems,
    );

    // Create minimal JSON for QR code to reduce size
    final minimalData = {
      'inv': invoice.invoiceNumber,
      'date': invoice.invoiceDate.toIso8601String(),
      'total': invoice.totalAmount,
      'items': lineItems
          .map(
            (item) => {
              'desc': item.description,
              'qty': item.quantity,
              'price': item.unitPrice,
              'tax': item.taxRate,
            },
          )
          .toList(),
    };

    final jsonData = jsonEncode(minimalData);
    print(
      'Minimal JSON length: ${jsonData.length} characters (reduced from full invoice)',
    );

    final qrImageBytes = _qrGenerator.encodeQrToJpg(jsonData, size: 400);

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.blue.shade500],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.qr_code_2, color: Colors.white, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'Scan to Pay',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Image.memory(qrImageBytes, width: 280, height: 280),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '₹${_getTotalAmount().toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Invoice: ${invoice.invoiceNumber}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _selectedQuantities.clear();
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.white),
                                SizedBox(width: 12),
                                Text('Payment initiated successfully!'),
                              ],
                            ),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['All', ...SampleInventory.categories];
    final displayItems = _selectedCategory == 'All'
        ? SampleInventory.items
        : SampleInventory.findByCategory(_selectedCategory);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Store Inventory',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue.shade700, Colors.blue.shade500],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Cart Summary Card
                if (_selectedQuantities.values.any((q) => q > 0))
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade400, Colors.green.shade600],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Cart Total',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${_getTotalAmount().toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.shopping_cart,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$_totalItemsCount items',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                // Category Filter Chips
                Container(
                  height: 50,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = category == _selectedCategory;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: isSelected,
                          label: Row(
                            children: [
                              Icon(
                                _getCategoryIcon(category),
                                size: 18,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey.shade700,
                              ),
                              const SizedBox(width: 6),
                              Text(category),
                            ],
                          ),
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          selectedColor: Colors.blue.shade700,
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                          elevation: isSelected ? 4 : 1,
                          shadowColor: Colors.blue.shade200,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Product Grid
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = displayItems[index];
                final quantity = _getQuantity(item.id);
                return _buildProductCard(item, quantity);
              }, childCount: displayItems.length),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: _selectedQuantities.values.any((q) => q > 0)
          ? FloatingActionButton.extended(
              onPressed: _generateAndShowQR,
              icon: const Icon(Icons.qr_code_2),
              label: const Text(
                'Generate QR',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.blue.shade700,
              elevation: 6,
            )
          : null,
    );
  }

  Widget _buildProductCard(item, double quantity) {
    return Card(
      elevation: quantity > 0 ? 8 : 2,
      shadowColor: quantity > 0 ? Colors.blue.shade200 : Colors.grey.shade200,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: quantity > 0
              ? Border.all(color: Colors.blue.shade700, width: 2)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and category badge
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    _getCategoryIcon(item.category),
                    color: Colors.blue.shade700,
                    size: 24,
                  ),
                  if (quantity > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade700,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${quantity.toInt()}x',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Product details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          '₹${item.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                        Text(
                          '/${item.unit}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tax: ${(item.taxRate * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Add/Remove buttons
            Container(
              padding: const EdgeInsets.all(8),
              child: quantity > 0
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle),
                          color: Colors.red.shade400,
                          iconSize: 28,
                          onPressed: () => _decrementQuantity(item.id),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade700,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${quantity.toInt()}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle),
                          color: Colors.green.shade600,
                          iconSize: 28,
                          onPressed: () => _incrementQuantity(item.id),
                        ),
                      ],
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _incrementQuantity(item.id),
                        icon: const Icon(Icons.add_shopping_cart, size: 18),
                        label: const Text(
                          'Add',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
