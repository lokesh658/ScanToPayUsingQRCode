import 'package:flutter/material.dart';
import 'package:qr_code_scanner/di/dependency_injection.dart';
import 'package:qr_code_scanner/controller/camera_image_controller.dart';
import 'package:qr_code_scanner/ui/inventory_page.dart';
import 'package:qr_code_scanner/ui/payment_verification_page.dart';
import 'package:qr_code_scanner/core/qr_code_decoder.dart';
import 'package:qr_code_scanner/model/invoice.dart';
import 'package:qr_code_scanner/model/line_item.dart';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'dart:convert';

void main() {
  DependencyInjection.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Code Scanner',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [const InventoryPage(), const ScannerPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.shopping_cart),
            label: 'Inventory',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scanner',
          ),
        ],
      ),
    );
  }
}

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final CameraImageController cameraImageController =
      Get.find<CameraImageController>();
  final QrCodeDecoder _qrDecoder = QrCodeDecoder();
  CameraPreview? cameraPreview;
  CameraController? cameraController;
  bool _isProcessing = false;

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  Future<void> scanQrCode() async {
    try {
      CameraController controller = await cameraImageController
          .getCameraController();
      if (!mounted) return;
      setState(() {
        cameraController = controller;
        cameraPreview = CameraPreview(controller);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Camera error: $e')));
    }
  }

  Future<void> captureAndDecodeQr() async {
    if (cameraController == null || _isProcessing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please start camera first')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      print('Capturing image...');
      // Capture photo
      final file = await cameraController!.takePicture();
      print('Image captured: ${file.path}');

      final bytes = await file.readAsBytes();
      print('Image size: ${bytes.length} bytes');

      // Decode QR
      print('Attempting to decode QR...');
      final qrData = _qrDecoder.decodeFromBytes(bytes);

      if (!mounted) return;

      if (qrData == null || qrData.isEmpty) {
        print('No QR code detected in image');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No QR code found. Try:\n• Better lighting\n• Hold camera steady\n• Get closer to QR code',
            ),
            duration: Duration(seconds: 4),
          ),
        );
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      print('QR decoded, data length: ${qrData.length}');

      // Parse invoice JSON
      try {
        final jsonData = jsonDecode(qrData);

        // Handle both full and minimal JSON formats
        Invoice invoice;
        if (jsonData.containsKey('inv')) {
          // Minimal format from QR code
          invoice = Invoice(
            invoiceNumber: jsonData['inv'],
            invoiceDate: DateTime.parse(jsonData['date']),
            customerName: 'Walk-in Customer',
            vendorName: 'My Store',
            lineItems: (jsonData['items'] as List)
                .map(
                  (item) => LineItem(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    description: item['desc'],
                    quantity: (item['qty'] as num).toDouble(),
                    unitPrice: (item['price'] as num).toDouble(),
                    taxRate: (item['tax'] as num).toDouble(),
                  ),
                )
                .toList(),
          );
        } else {
          // Full format
          invoice = Invoice.fromJson(jsonData);
        }
        print('Invoice parsed successfully: ${invoice.invoiceNumber}');

        // Navigate to payment verification
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentVerificationPage(invoice: invoice),
          ),
        );
      } catch (e) {
        print('JSON parsing error: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid QR code data: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('Capture/decode error: $e');
      print('Stack trace: $stackTrace');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error scanning QR: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code'), elevation: 2),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.black,
              child: Center(
                child:
                    cameraPreview ??
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          size: 80,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tap "Start Camera" to begin',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (cameraPreview != null) ...[
                  const Text(
                    'Position the QR code within the camera view',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (cameraPreview == null)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isProcessing ? null : scanQrCode,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Start Camera'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      )
                    else ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isProcessing ? null : captureAndDecodeQr,
                          icon: _isProcessing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.qr_code_scanner),
                          label: Text(
                            _isProcessing ? 'Processing...' : 'Scan QR Code',
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _isProcessing
                            ? null
                            : () async {
                                await cameraController?.dispose();
                                setState(() {
                                  cameraController = null;
                                  cameraPreview = null;
                                });
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 20,
                          ),
                        ),
                        child: const Icon(Icons.close),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
