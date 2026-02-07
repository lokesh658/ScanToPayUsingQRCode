import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:zxing2/qrcode.dart';
import 'package:image/image.dart';

class QrCodeProcess {
  Future<String> processQRcode(XFile xFile) async {
    Uint8List bytes = await xFile.readAsBytes();
    final decoded = decodeImage(bytes);
    if (decoded == null) {
      print("Failed to decode image");
      return " ";
    }
    // Convert to ARGB int list for RGBLuminanceSource
    final pixels = decoded.getBytes(order: ChannelOrder.argb);
    final int width = decoded.width;
    final int height = decoded.height;

    final intList = Int32List(width * height);
    for (int i = 0, p = 0; i < intList.length; i++) {
      final a = pixels[p++];
      final r = pixels[p++];
      final g = pixels[p++];
      final b = pixels[p++];
      intList[i] = (a << 24) | (r << 16) | (g << 8) | b;
    }

    final source = RGBLuminanceSource(width, height, intList);
    final bitmap = BinaryBitmap(HybridBinarizer(source));

    final result = QRCodeReader().decode(bitmap);
    return result.text;
  }
}
