import '../model/line_item.dart';

class InventoryItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String unit;
  final double taxRate;
  final String category;

  InventoryItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.unit,
    this.taxRate = 0.18,
    required this.category,
  });

  LineItem toLineItem({double quantity = 1}) => LineItem(
        id: id,
        description: description,
        quantity: quantity,
        unitPrice: price,
        taxRate: taxRate,
        unit: unit,
      );
}

class SampleInventory {
  static final List<InventoryItem> items = [
    // Electronics
    InventoryItem(
      id: 'ELEC001',
      name: 'Wireless Mouse',
      description: 'Logitech M185 Wireless Mouse',
      price: 599.00,
      unit: 'pcs',
      category: 'Electronics',
    ),
    InventoryItem(
      id: 'ELEC002',
      name: 'USB Cable',
      description: 'USB Type-C Cable 1.5m',
      price: 199.00,
      unit: 'pcs',
      category: 'Electronics',
    ),
    InventoryItem(
      id: 'ELEC003',
      name: 'Power Bank',
      description: '10000mAh Fast Charging Power Bank',
      price: 1299.00,
      unit: 'pcs',
      category: 'Electronics',
    ),
    InventoryItem(
      id: 'ELEC004',
      name: 'Bluetooth Earbuds',
      description: 'True Wireless Earbuds with Charging Case',
      price: 2499.00,
      unit: 'pcs',
      category: 'Electronics',
    ),
    InventoryItem(
      id: 'ELEC005',
      name: 'HDMI Cable',
      description: 'HDMI 2.1 Cable 4K 60Hz 2m',
      price: 399.00,
      unit: 'pcs',
      category: 'Electronics',
    ),

    // Office Supplies
    InventoryItem(
      id: 'OFF001',
      name: 'A4 Paper',
      description: 'Premium A4 Paper 500 Sheets',
      price: 299.00,
      unit: 'ream',
      taxRate: 0.12,
      category: 'Office Supplies',
    ),
    InventoryItem(
      id: 'OFF002',
      name: 'Gel Pen',
      description: 'Blue Gel Pen Pack of 10',
      price: 150.00,
      unit: 'pack',
      taxRate: 0.12,
      category: 'Office Supplies',
    ),
    InventoryItem(
      id: 'OFF003',
      name: 'Notebook',
      description: 'Spiral Notebook 200 Pages',
      price: 120.00,
      unit: 'pcs',
      taxRate: 0.12,
      category: 'Office Supplies',
    ),
    InventoryItem(
      id: 'OFF004',
      name: 'Stapler',
      description: 'Heavy Duty Stapler with 1000 Staples',
      price: 250.00,
      unit: 'pcs',
      taxRate: 0.12,
      category: 'Office Supplies',
    ),

    // Services
    InventoryItem(
      id: 'SRV001',
      name: 'Web Development',
      description: 'Frontend Development Service',
      price: 2000.00,
      unit: 'hr',
      category: 'Services',
    ),
    InventoryItem(
      id: 'SRV002',
      name: 'Graphic Design',
      description: 'Logo and Brand Design',
      price: 1500.00,
      unit: 'hr',
      category: 'Services',
    ),
    InventoryItem(
      id: 'SRV003',
      name: 'Consulting',
      description: 'Business Strategy Consulting',
      price: 3000.00,
      unit: 'hr',
      category: 'Services',
    ),
    InventoryItem(
      id: 'SRV004',
      name: 'Data Entry',
      description: 'Data Entry and Processing',
      price: 500.00,
      unit: 'hr',
      category: 'Services',
    ),

    // Food Items
    InventoryItem(
      id: 'FOOD001',
      name: 'Coffee Beans',
      description: 'Arabica Coffee Beans 500g',
      price: 899.00,
      unit: 'pack',
      taxRate: 0.05,
      category: 'Food',
    ),
    InventoryItem(
      id: 'FOOD002',
      name: 'Green Tea',
      description: 'Premium Green Tea 100 Bags',
      price: 399.00,
      unit: 'box',
      taxRate: 0.05,
      category: 'Food',
    ),
    InventoryItem(
      id: 'FOOD003',
      name: 'Cookies',
      description: 'Assorted Cookies 500g Pack',
      price: 299.00,
      unit: 'pack',
      taxRate: 0.05,
      category: 'Food',
    ),
  ];

  static InventoryItem? findById(String id) {
    try {
      return items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<InventoryItem> findByCategory(String category) {
    return items.where((item) => item.category == category).toList();
  }

  static List<String> get categories {
    return items.map((item) => item.category).toSet().toList();
  }
}
